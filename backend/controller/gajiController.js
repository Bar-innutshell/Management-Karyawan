const prisma = require('../config/prismaClient');

/**
 * SET GAJI PER JAM (Admin only)
 * Admin mengatur gaji per jam untuk user tertentu
 */
exports.setGajiPerJam = async (req, res) => {
  try {
    const { userId, gajiPerJam } = req.body;

    if (!userId || gajiPerJam === undefined) {
      return res.status(400).json({
        message: 'userId dan gajiPerJam harus diisi',
      });
    }

    const parsedGajiPerJam = parseFloat(gajiPerJam);
    if (isNaN(parsedGajiPerJam) || parsedGajiPerJam < 0) {
      return res.status(400).json({
        message: 'gajiPerJam harus berupa angka positif',
      });
    }

    // Update gaji per jam user
    const updatedUser = await prisma.user.update({
      where: { id: parseInt(userId) },
      data: { gajiPerJam: parsedGajiPerJam },
      include: {
        role: {
          select: {
            nama: true,
            gajiPokok: true,
          },
        },
      },
    });

    // Hitung gaji bulanan (gajiPerJam × 6 jam × 20 hari)
    const gajiBulanan = parsedGajiPerJam * 6 * 20;

    res.json({
      message: 'Gaji per jam berhasil diatur',
      data: {
        user: {
          id: updatedUser.id,
          nama: updatedUser.nama,
          email: updatedUser.email,
          role: updatedUser.role.nama,
        },
        gaji: {
          gajiPerJam: updatedUser.gajiPerJam,
          gajiHarian: updatedUser.gajiPerJam * 6, // 6 jam per shift
          gajiBulanan: gajiBulanan, // 20 hari kerja
          formula: `${updatedUser.gajiPerJam} × 6 jam × 20 hari = ${gajiBulanan}`,
        },
      },
    });
  } catch (error) {
    if (error.code === 'P2025') {
      return res.status(404).json({
        message: 'User tidak ditemukan',
      });
    }
    res.status(500).json({
      message: 'Terjadi kesalahan pada server',
      error: error.message,
    });
  }
};

/**
 * HITUNG GAJI DARI GAJI POKOK (Admin only)
 * Menghitung gaji per jam dari gaji pokok role
 * Formula: Gaji Pokok ÷ 20 hari ÷ 6 jam = Gaji Per Jam
 */
exports.hitungGajiDariGajiPokok = async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        message: 'userId harus diisi',
      });
    }

    // Get user dengan role
    const user = await prisma.user.findUnique({
      where: { id: parseInt(userId) },
      include: {
        role: true,
      },
    });

    if (!user) {
      return res.status(404).json({
        message: 'User tidak ditemukan',
      });
    }

    // Hitung gaji per jam dari gaji pokok role
    const gajiPerJam = user.role.gajiPokokBulanan / 20 / 6;

    // Update gaji per jam user
    const updatedUser = await prisma.user.update({
      where: { id: user.id },
      data: { gajiPerJam: gajiPerJam },
    });

    res.json({
      message: 'Gaji per jam berhasil dihitung dari gaji pokok',
      data: {
        user: {
          id: updatedUser.id,
          nama: updatedUser.nama,
          email: updatedUser.email,
          role: user.role.nama,
        },
        gaji: {
          gajiPokokBulanan: user.role.gajiPokokBulanan,
          gajiPerJam: gajiPerJam,
          gajiHarian: gajiPerJam * 6,
          gajiBulanan: user.role.gajiPokokBulanan,
          formula: `${user.role.gajiPokokBulanan} ÷ 20 hari ÷ 6 jam = ${gajiPerJam.toFixed(2)} per jam`,
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
 * GET USER GAJI (Admin only)
 * Melihat detail gaji user
 */
exports.getUserGaji = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await prisma.user.findUnique({
      where: { id: parseInt(userId) },
      select: {
        id: true,
        nama: true,
        email: true,
        gajiPerJam: true,
        role: {
          select: {
            nama: true,
            gajiPokok: true,
          },
        },
      },
    });

    if (!user) {
      return res.status(404).json({
        message: 'User tidak ditemukan',
      });
    }

    res.json({
      message: 'Data gaji user berhasil diambil',
      data: {
        user: {
          id: user.id,
          nama: user.nama,
          email: user.email,
          role: user.role.nama,
        },
        gaji: {
          gajiPokokBulanan: user.role.gajiPokokBulanan,
          gajiPerJam: user.gajiPerJam,
          gajiHarian: user.gajiPerJam * 6, // 6 jam per shift
          gajiBulanan: user.gajiPerJam * 6 * 20, // 20 hari kerja
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
 * GET ALL USER GAJI (Admin only)
 * Melihat daftar gaji semua user
 */
exports.getAllUserGaji = async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      select: {
        id: true,
        nama: true,
        email: true,
        gajiPerJam: true,
        role: {
          select: {
            nama: true,
            gajiPokok: true,
          },
        },
      },
      orderBy: {
        nama: 'asc',
      },
    });

    const userGajiList = users.map((user) => ({
      user: {
        id: user.id,
        nama: user.nama,
        email: user.email,
        role: user.role.nama,
      },
      gaji: {
        gajiPokokBulanan: user.role.gajiPokokBulanan,
        gajiPerJam: user.gajiPerJam,
        gajiHarian: user.gajiPerJam * 6,
        gajiBulanan: user.gajiPerJam * 6 * 20,
      },
    }));

    res.json({
      message: 'Daftar gaji user berhasil diambil',
      data: userGajiList,
      summary: {
        totalUser: users.length,
        totalGajiBulanan: userGajiList.reduce((sum, item) => sum + item.gaji.gajiBulanan, 0),
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
 * GENERATE SLIP GAJI (Admin only)
 * Generate slip gaji bulanan untuk user berdasarkan absensi
 */
exports.generateSlipGaji = async (req, res) => {
  try {
    const { userId, bulan, tahun, bonusKehadiran = 0, bonusLainnya = 0, potonganLainnya = 0, keterangan } = req.body;

    // Validasi input
    if (!userId || !bulan || !tahun) {
      return res.status(400).json({
        message: 'userId, bulan, dan tahun harus diisi',
      });
    }

    const bulanInt = parseInt(bulan);
    const tahunInt = parseInt(tahun);

    if (bulanInt < 1 || bulanInt > 12) {
      return res.status(400).json({
        message: 'Bulan harus antara 1-12',
      });
    }

    // Get user data
    const user = await prisma.user.findUnique({
      where: { id: parseInt(userId) },
      include: { role: true },
    });

    if (!user) {
      return res.status(404).json({
        message: 'User tidak ditemukan',
      });
    }

    // Check if slip gaji already exists
    const existingSlip = await prisma.slipGaji.findFirst({
      where: {
        userId: user.id,
        bulan: bulanInt,
        tahun: tahunInt,
      },
    });

    if (existingSlip) {
      return res.status(400).json({
        message: `Slip gaji untuk ${user.nama} bulan ${bulanInt}/${tahunInt} sudah ada`,
        data: existingSlip,
      });
    }

    // Get all absensi for this month
    const startDate = new Date(tahunInt, bulanInt - 1, 1);
    const endDate = new Date(tahunInt, bulanInt, 0, 23, 59, 59);

    const absensiList = await prisma.absensi.findMany({
      where: {
        userId: user.id,
        tanggal: {
          gte: startDate,
          lte: endDate,
        },
      },
    });

    // Hitung total dari absensi
    let totalGajiDariAbsensi = 0;
    let totalPotonganTelat = 0;
    let jumlahAlpha = 0;
    let jumlahHadir = 0;

    absensiList.forEach((absensi) => {
      if (absensi.status === 'Hadir') {
        totalGajiDariAbsensi += absensi.totalGaji;
        totalPotonganTelat += absensi.potonganGaji;
        jumlahHadir++;
      } else if (absensi.status === 'Alpha') {
        jumlahAlpha++;
      }
    });

    // Hitung potongan alpha (1 hari alpha = gaji harian hilang)
    const gajiHarian = user.gajiPerJam * 6;
    const potonganAlpha = jumlahAlpha * gajiHarian;

    // Total gaji kotor
    const totalGajiKotor = totalGajiDariAbsensi + parseFloat(bonusKehadiran) + parseFloat(bonusLainnya);

    // Total potongan
    const totalPotongan = totalPotonganTelat + potonganAlpha + parseFloat(potonganLainnya);

    // Total gaji bersih
    const totalGajiBersih = totalGajiKotor - totalPotongan;

    // Create slip gaji
    const slipGaji = await prisma.slipGaji.create({
      data: {
        userId: user.id,
        bulan: bulanInt,
        tahun: tahunInt,
        gajiBulanan: totalGajiDariAbsensi,
        bonusKehadiran: parseFloat(bonusKehadiran),
        bonusLainnya: parseFloat(bonusLainnya),
        potonganAlpha: potonganAlpha,
        potonganTelat: totalPotonganTelat,
        potonganLainnya: parseFloat(potonganLainnya),
        totalGajiKotor: totalGajiKotor,
        totalPotongan: totalPotongan,
        totalGajiBersih: totalGajiBersih,
        keterangan: keterangan || `Gaji bulan ${bulanInt}/${tahunInt}`,
      },
      include: {
        user: {
          select: {
            nama: true,
            email: true,
            role: {
              select: {
                nama: true,
              },
            },
          },
        },
      },
    });

    res.json({
      message: 'Slip gaji berhasil dibuat',
      data: {
        slipGaji: slipGaji,
        detail: {
          periode: `${bulanInt}/${tahunInt}`,
          jumlahHadir: jumlahHadir,
          jumlahAlpha: jumlahAlpha,
          totalAbsensi: absensiList.length,
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
 * GET SLIP GAJI USER (User bisa lihat slip gaji sendiri, Admin bisa lihat semua)
 */
exports.getSlipGaji = async (req, res) => {
  try {
    const { userId } = req.params;
    const { bulan, tahun } = req.query;

    // Check authorization (user hanya bisa lihat slip gaji sendiri)
    const requesterId = req.userData.userId;
    const requesterRole = req.userData.role;

    if (requesterRole !== 'Admin' && requesterId !== parseInt(userId)) {
      return res.status(403).json({
        message: 'Anda tidak memiliki akses untuk melihat slip gaji user lain',
      });
    }

    const whereClause = {
      userId: parseInt(userId),
    };

    if (bulan) {
      whereClause.bulan = parseInt(bulan);
    }
    if (tahun) {
      whereClause.tahun = parseInt(tahun);
    }

    const slipGajiList = await prisma.slipGaji.findMany({
      where: whereClause,
      include: {
        user: {
          select: {
            nama: true,
            email: true,
            role: {
              select: {
                nama: true,
              },
            },
          },
        },
      },
      orderBy: [{ tahun: 'desc' }, { bulan: 'desc' }],
    });

    res.json({
      message: 'Data slip gaji berhasil diambil',
      data: slipGajiList,
      summary: {
        totalSlip: slipGajiList.length,
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
 * GET ALL SLIP GAJI (Admin only)
 * Melihat semua slip gaji dengan filter
 */
exports.getAllSlipGaji = async (req, res) => {
  try {
    const { bulan, tahun, userId } = req.query;

    const whereClause = {};

    if (bulan) whereClause.bulan = parseInt(bulan);
    if (tahun) whereClause.tahun = parseInt(tahun);
    if (userId) whereClause.userId = parseInt(userId);

    const slipGajiList = await prisma.slipGaji.findMany({
      where: whereClause,
      include: {
        user: {
          select: {
            nama: true,
            email: true,
            role: {
              select: {
                nama: true,
              },
            },
          },
        },
      },
      orderBy: [{ tahun: 'desc' }, { bulan: 'desc' }, { user: { nama: 'asc' } }],
    });

    const totalGajiBersih = slipGajiList.reduce((sum, slip) => sum + slip.totalGajiBersih, 0);

    res.json({
      message: 'Data slip gaji berhasil diambil',
      data: slipGajiList,
      summary: {
        totalSlip: slipGajiList.length,
        totalGajiBersih: totalGajiBersih,
      },
    });
  } catch (error) {
    res.status(500).json({
      message: 'Terjadi kesalahan pada server',
      error: error.message,
    });
  }
};
