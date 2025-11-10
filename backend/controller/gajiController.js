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
