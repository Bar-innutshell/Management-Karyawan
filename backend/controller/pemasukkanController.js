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
  
  const { userId, jumlahPemasukkan, shift } = req.body;

  if (userId === undefined || jumlahPemasukkan === undefined || !shift) {
    return res.status(400).json({
      message:
        'Data tidak lengkap. Pastikan userId, jumlahPemasukkan, dan shift terisi.',
    });
  }

  try {
    const parsedUserId = parseInt(userId, 10);
    const parsedJumlah = parseFloat(jumlahPemasukkan);

    if (isNaN(parsedUserId)) {
      return res.status(400).json({ message: 'userId harus berupa angka.' });
    }
    if (isNaN(parsedJumlah) || parsedJumlah < 0) {
      return res.status(400).json({
        message: 'jumlahPemasukkan harus berupa angka yang valid.',
      });
    }

    if (parsedUserId !== 2) {
      return res.status(403).json({
        message: `Aksi ditolak. Hanya user dengan ID 2 yang diizinkan membuat laporan.`,
      });
    }


    const newPemasukkan = await prisma.LaporanPemasukan.create({
      data: {
        userId: parsedUserId,
        jumlahPemasukan: parsedJumlah,
        shift: shift,
        tanggalLaporan: new Date(),
      },
    });

    res.status(201).json({
      message: 'Data pemasukkan berhasil ditambahkan',
      data: newPemasukkan,
    });
    
  } catch (error) {
    if (error.code === 'P2003') {
      return res
        .status(404)
        .json({ message: `Gagal: User dengan ID ${userId} tidak ditemukan.` });
    }

    res
      .status(500)
      .json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};