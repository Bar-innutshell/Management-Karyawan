const prisma = require('../config/prismaClient');

/**
 * CLOCK IN (Semua user yang login)
 * User absen masuk dengan shift yang dipilih
 */
exports.clockIn = async (req, res) => {
  try {
    const { shift } = req.body;
    const userId = req.user.userId;

    // Validasi shift
    const validShifts = ['Siang', 'Sore'];
    if (!validShifts.includes(shift)) {
      return res.status(400).json({
        message: `Shift harus salah satu dari: ${validShifts.join(', ')}`,
      });
    }

    // Cek apakah user sudah clock in hari ini
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const existingAbsensi = await prisma.absensi.findFirst({
      where: {
        userId: userId,
        tanggal: {
          gte: today,
          lt: tomorrow,
        },
        shift: shift,
      },
    });

    if (existingAbsensi) {
      return res.status(400).json({
        message: `Anda sudah clock in untuk shift ${shift} hari ini`,
      });
    }

    // Get user data untuk gaji per jam
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        nama: true,
        gajiPerJam: true,
      },
    });

    if (!user) {
      return res.status(404).json({
        message: 'User tidak ditemukan',
      });
    }

    if (user.gajiPerJam === 0) {
      return res.status(400).json({
        message: 'Gaji per jam belum diatur. Hubungi admin untuk mengatur gaji Anda.',
      });
    }

    // Tentukan jam mulai dan selesai shift
    const now = new Date();
    let jamMulaiShift, jamSelesaiShift;

    if (shift === 'Siang') {
      // Shift Siang: 09:00 - 15:00
      jamMulaiShift = new Date(now);
      jamMulaiShift.setHours(9, 0, 0, 0);
      jamSelesaiShift = new Date(now);
      jamSelesaiShift.setHours(15, 0, 0, 0);
    } else if (shift === 'Sore') {
      // Shift Sore: 15:00 - 21:00
      jamMulaiShift = new Date(now);
      jamMulaiShift.setHours(15, 0, 0, 0);
      jamSelesaiShift = new Date(now);
      jamSelesaiShift.setHours(21, 0, 0, 0);
    }

    // Hitung keterlambatan (dalam menit)
    const jamMasuk = new Date();
    const diffMs = jamMasuk - jamMulaiShift;
    const diffMinutes = Math.floor(diffMs / 1000 / 60);
    
    const menitTerlambat = diffMinutes > 0 ? diffMinutes : 0;
    
    // Tentukan status: Hadir atau Telat
    // Toleransi 10 menit
    let status = 'Hadir';
    let potonganGaji = 0;

    if (menitTerlambat > 10) {
      status = 'Telat';
      // Potongan: (menit telat - 10 toleransi) / 60 * gaji per jam
      const menitPotongan = menitTerlambat - 10;
      potonganGaji = (menitPotongan / 60) * user.gajiPerJam;
    }

    // Buat record absensi
    const absensi = await prisma.absensi.create({
      data: {
        userId: userId,
        tanggal: today,
        shift: shift,
        jamMasuk: jamMasuk,
        jamMulaiShift: jamMulaiShift,
        jamSelesaiShift: jamSelesaiShift,
        menitTerlambat: menitTerlambat,
        potonganGaji: potonganGaji,
        status: status,
        // jamKerja dan totalGaji akan dihitung saat clock out
      },
      include: {
        user: {
          select: {
            id: true,
            nama: true,
            email: true,
            gajiPerJam: true,
          },
        },
      },
    });

    res.status(201).json({
      message: `Clock in berhasil untuk shift ${shift}`,
      data: {
        absensi: {
          id: absensi.id,
          tanggal: absensi.tanggal,
          shift: absensi.shift,
          jamMasuk: absensi.jamMasuk,
          jamMulaiShift: absensi.jamMulaiShift,
          status: absensi.status,
          menitTerlambat: absensi.menitTerlambat,
          potonganGaji: absensi.potonganGaji,
        },
        user: {
          nama: absensi.user.nama,
          gajiPerJam: absensi.user.gajiPerJam,
        },
        info: menitTerlambat > 10 
          ? `Anda terlambat ${menitTerlambat} menit. Potongan gaji: Rp ${potonganGaji.toFixed(2)}`
          : menitTerlambat > 0 
            ? `Anda terlambat ${menitTerlambat} menit (masih dalam toleransi 10 menit)`
            : 'Anda tepat waktu!',
      },
    });
  } catch (error) {
    res.status(500).json({
      message: 'Terjadi kesalahan pada server',
      error: error.message,
    });
  }
};

/**
 * CLOCK OUT (Semua user yang login)
 * User absen keluar dan gaji dihitung
 */
exports.clockOut = async (req, res) => {
  try {
    const { absensiId } = req.body;
    const userId = req.user.userId;

    if (!absensiId) {
      return res.status(400).json({
        message: 'absensiId harus diisi',
      });
    }

    // Get absensi record
    const absensi = await prisma.absensi.findUnique({
      where: { id: parseInt(absensiId) },
      include: {
        user: {
          select: {
            id: true,
            nama: true,
            gajiPerJam: true,
          },
        },
      },
    });

    if (!absensi) {
      return res.status(404).json({
        message: 'Data absensi tidak ditemukan',
      });
    }

    // Validasi: user hanya bisa clock out absensi sendiri
    if (absensi.userId !== userId) {
      return res.status(403).json({
        message: 'Anda tidak bisa clock out absensi user lain',
      });
    }

    // Cek apakah sudah clock out
    if (absensi.jamKeluar) {
      return res.status(400).json({
        message: 'Anda sudah clock out sebelumnya',
        data: {
          jamKeluar: absensi.jamKeluar,
          totalGaji: absensi.totalGaji,
        },
      });
    }

    const jamKeluar = new Date();

    // Hitung jam kerja (dalam jam, decimal)
    const diffMs = jamKeluar - absensi.jamMasuk;
    const jamKerja = diffMs / 1000 / 60 / 60; // Convert ms to hours

    // Hitung total gaji
    // Total Gaji = (Jam Kerja × Gaji Per Jam) - Potongan
    const gajiKotor = jamKerja * absensi.user.gajiPerJam;
    const totalGaji = gajiKotor - absensi.potonganGaji;

    // Update absensi
    const updatedAbsensi = await prisma.absensi.update({
      where: { id: absensi.id },
      data: {
        jamKeluar: jamKeluar,
        jamKerja: parseFloat(jamKerja.toFixed(2)),
        totalGaji: parseFloat(totalGaji.toFixed(2)),
      },
      include: {
        user: {
          select: {
            id: true,
            nama: true,
            email: true,
            gajiPerJam: true,
          },
        },
      },
    });

    res.json({
      message: 'Clock out berhasil',
      data: {
        absensi: {
          id: updatedAbsensi.id,
          tanggal: updatedAbsensi.tanggal,
          shift: updatedAbsensi.shift,
          jamMasuk: updatedAbsensi.jamMasuk,
          jamKeluar: updatedAbsensi.jamKeluar,
          jamKerja: updatedAbsensi.jamKerja,
          status: updatedAbsensi.status,
          menitTerlambat: updatedAbsensi.menitTerlambat,
        },
        gaji: {
          gajiPerJam: updatedAbsensi.user.gajiPerJam,
          gajiKotor: parseFloat(gajiKotor.toFixed(2)),
          potonganGaji: updatedAbsensi.potonganGaji,
          totalGaji: updatedAbsensi.totalGaji,
          formula: `(${updatedAbsensi.jamKerja} jam × Rp ${updatedAbsensi.user.gajiPerJam}) - Rp ${updatedAbsensi.potonganGaji} = Rp ${updatedAbsensi.totalGaji}`,
        },
        user: {
          nama: updatedAbsensi.user.nama,
        },
      },
    });
  } catch (error) {
    res.status(500).json({
      message: 'Terjadi kesalahan pada server',
      error: error.message,
    });
  }
};

/**
 * GET MY ABSENSI (User yang login)
 * Lihat riwayat absensi sendiri
 */
exports.getMyAbsensi = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { startDate, endDate, shift } = req.query;

    const whereCondition = { userId: userId };

    if (startDate || endDate) {
      whereCondition.tanggal = {};
      if (startDate) {
        whereCondition.tanggal.gte = new Date(startDate);
      }
      if (endDate) {
        whereCondition.tanggal.lte = new Date(endDate);
      }
    }

    if (shift) {
      whereCondition.shift = shift;
    }

    const absensiList = await prisma.absensi.findMany({
      where: whereCondition,
      orderBy: {
        tanggal: 'desc',
      },
      select: {
        id: true,
        tanggal: true,
        shift: true,
        jamMasuk: true,
        jamKeluar: true,
        jamKerja: true,
        menitTerlambat: true,
        potonganGaji: true,
        totalGaji: true,
        status: true,
      },
    });

    const summary = {
      totalHariKerja: absensiList.length,
      totalJamKerja: absensiList.reduce((sum, item) => sum + item.jamKerja, 0),
      totalGaji: absensiList.reduce((sum, item) => sum + item.totalGaji, 0),
      totalPotongan: absensiList.reduce((sum, item) => sum + item.potonganGaji, 0),
      totalTelat: absensiList.filter((item) => item.status === 'Telat').length,
    };

    res.json({
      message: 'Riwayat absensi berhasil diambil',
      data: absensiList,
      summary: summary,
    });
  } catch (error) {
    res.status(500).json({
      message: 'Terjadi kesalahan pada server',
      error: error.message,
    });
  }
};

/**
 * GET ALL ABSENSI (Admin only)
 * Lihat semua absensi semua user
 */
exports.getAllAbsensi = async (req, res) => {
  try {
    const { startDate, endDate, shift, userId } = req.query;

    const whereCondition = {};

    if (startDate || endDate) {
      whereCondition.tanggal = {};
      if (startDate) {
        whereCondition.tanggal.gte = new Date(startDate);
      }
      if (endDate) {
        whereCondition.tanggal.lte = new Date(endDate);
      }
    }

    if (shift) {
      whereCondition.shift = shift;
    }

    if (userId) {
      whereCondition.userId = parseInt(userId);
    }

    const absensiList = await prisma.absensi.findMany({
      where: whereCondition,
      orderBy: [
        { tanggal: 'desc' },
        { userId: 'asc' },
      ],
      include: {
        user: {
          select: {
            id: true,
            nama: true,
            email: true,
            gajiPerJam: true,
            role: {
              select: {
                nama: true,
              },
            },
          },
        },
      },
    });

    const summary = {
      totalRecords: absensiList.length,
      totalJamKerja: absensiList.reduce((sum, item) => sum + item.jamKerja, 0),
      totalGaji: absensiList.reduce((sum, item) => sum + item.totalGaji, 0),
      totalPotongan: absensiList.reduce((sum, item) => sum + item.potonganGaji, 0),
      totalTelat: absensiList.filter((item) => item.status === 'Telat').length,
    };

    res.json({
      message: 'Data absensi berhasil diambil',
      data: absensiList,
      summary: summary,
    });
  } catch (error) {
    res.status(500).json({
      message: 'Terjadi kesalahan pada server',
      error: error.message,
    });
  }
};

/**
 * GET ABSENSI TODAY (User yang login)
 * Lihat absensi hari ini untuk clock out
 */
exports.getAbsensiToday = async (req, res) => {
  try {
    const userId = req.user.userId;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const absensiToday = await prisma.absensi.findMany({
      where: {
        userId: userId,
        tanggal: {
          gte: today,
          lt: tomorrow,
        },
      },
      orderBy: {
        jamMasuk: 'desc',
      },
    });

    res.json({
      message: 'Absensi hari ini berhasil diambil',
      data: absensiToday,
    });
  } catch (error) {
    res.status(500).json({
      message: 'Terjadi kesalahan pada server',
      error: error.message,
    });
  }
};
