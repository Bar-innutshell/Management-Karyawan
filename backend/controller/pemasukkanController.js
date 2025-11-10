const prisma = require('../config/prismaClient');


exports.showPemasukan = async (req, res) => {
  try {
    const pemasukkan = await prisma.LaporanPemasukan.findMany({
      select: {
        id: true,
        jumlahPemasukan: true,
        tanggalLaporan: true,
        shift: true,
        userId: true,
        
        user: {
          select: {
            id: true,
            nama: true, 
            email: true,
          },
        },
      },
      orderBy: {
        tanggalLaporan: 'desc', 
      },
    });

    res.json({
      message: 'Daftar pemasukkan berhasil diambil',
      data: pemasukkan,
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};


exports.createPemasukkan = async (req, res) => {
  
  const { jumlahPemasukkan, shift } = req.body;

  // Cashier otomatis dari user yang login (dari middleware)
  const userId = req.user.userId;

  if (jumlahPemasukkan === undefined || !shift) {
    return res.status(400).json({
      message: 'Data tidak lengkap. Pastikan jumlahPemasukkan dan shift terisi.',
    });
  }

  try {
    const parsedJumlah = parseFloat(jumlahPemasukkan);

    if (isNaN(parsedJumlah) || parsedJumlah < 0) {
      return res.status(400).json({
        message: 'jumlahPemasukkan harus berupa angka yang valid.',
      });
    }

    // Validasi shift
    const validShifts = ['Pagi', 'Siang', 'Sore', 'Malam'];
    if (!validShifts.includes(shift)) {
      return res.status(400).json({
        message: `Shift harus salah satu dari: ${validShifts.join(', ')}`,
      });
    }

    const newPemasukkan = await prisma.laporanPemasukan.create({
      data: {
        userId: userId,
        jumlahPemasukan: parsedJumlah,
        shift: shift,
        tanggalLaporan: new Date(),
      },
      include: {
        user: {
          select: {
            id: true,
            nama: true,
            email: true,
            role: {
              select: {
                nama: true
              }
            }
          }
        }
      }
    });

    res.status(201).json({
      message: 'Data pemasukkan berhasil ditambahkan',
      data: newPemasukkan,
    });
    
  } catch (error) {
    res
      .status(500)
      .json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};