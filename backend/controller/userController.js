const prisma = require('../config/prismaClient');
const bcrypt = require('bcrypt');

/**
 * GET /users - Get all users (Admin only)
 */
const getAllUsers = async (req, res) => {
  try {
    const { roleId, search } = req.query;
    
    const whereClause = {};
    
    // Filter by roleId if provided
    if (roleId) {
      whereClause.roleId = parseInt(roleId);
    }
    
    // Search by name or email if provided
    if (search) {
      whereClause.OR = [
        { nama: { contains: search } },
        { email: { contains: search } }
      ];
    }
    
    const users = await prisma.user.findMany({
      where: whereClause,
      select: {
        id: true,
        nama: true,
        email: true,
        roleId: true,
        gajiPerJam: true,
        shift: true,
        createdAt: true,
        updatedAt: true,
        role: {
          select: {
            id: true,
            nama: true,
            gajiPokokBulanan: true
          }
        },
        _count: {
          select: {
            absensi: true,
            slipGaji: true
          }
        }
      },
      orderBy: [
        { roleId: 'asc' },
        { nama: 'asc' }
      ]
    });

    res.status(200).json({
      message: 'Daftar user berhasil diambil',
      data: users,
      total: users.length
    });
  } catch (error) {
    console.error('Error getting users:', error);
    res.status(500).json({
      message: 'Terjadi kesalahan saat mengambil data user',
      error: error.message
    });
  }
};

/**
 * GET /users/:id - Get user by ID (Admin only)
 */
const getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const user = await prisma.user.findUnique({
      where: { id: parseInt(id) },
      select: {
        id: true,
        nama: true,
        email: true,
        roleId: true,
        gajiPerJam: true,
        shift: true,
        createdAt: true,
        updatedAt: true,
        role: {
          select: {
            id: true,
            nama: true,
            deskripsi: true,
            gajiPokokBulanan: true
          }
        },
        _count: {
          select: {
            absensi: true,
            slipGaji: true,
            jadwal: true,
            laporanPemasukan: true
          }
        }
      }
    });

    if (!user) {
      return res.status(404).json({
        message: 'User tidak ditemukan'
      });
    }

    res.status(200).json({
      message: 'Data user berhasil diambil',
      data: user
    });
  } catch (error) {
    console.error('Error getting user:', error);
    res.status(500).json({
      message: 'Terjadi kesalahan saat mengambil data user',
      error: error.message
    });
  }
};

/**
 * POST /users - Create new user (Admin only)
 */
const createUser = async (req, res) => {
  try {
    const { nama, email, password, roleId, gajiPerJam, shift } = req.body;

    // Validation
    if (!nama || !email || !password || !roleId) {
      return res.status(400).json({
        message: 'Nama, email, password, dan roleId harus diisi'
      });
    }

    // Validate shift if provided (must be "Pagi" or "Sore")
    if (shift && !['Pagi', 'Sore'].includes(shift)) {
      return res.status(400).json({
        message: 'Shift harus "Pagi" atau "Sore"'
      });
    }

    // Check if email already exists
    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    if (existingUser) {
      return res.status(409).json({
        message: 'Email sudah terdaftar'
      });
    }

    // Check if role exists
    const role = await prisma.role.findUnique({
      where: { id: parseInt(roleId) }
    });

    if (!role) {
      return res.status(404).json({
        message: 'Role tidak ditemukan'
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await prisma.user.create({
      data: {
        nama,
        email,
        password: hashedPassword,
        roleId: parseInt(roleId),
        gajiPerJam: gajiPerJam ? parseFloat(gajiPerJam) : 0,
        shift: shift || null
      },
      select: {
        id: true,
        nama: true,
        email: true,
        roleId: true,
        gajiPerJam: true,
        shift: true,
        createdAt: true,
        role: {
          select: {
            nama: true
          }
        }
      }
    });

    res.status(201).json({
      message: 'User berhasil dibuat',
      data: user
    });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({
      message: 'Terjadi kesalahan saat membuat user',
      error: error.message
    });
  }
};

/**
 * PUT /users/:id - Update user (Admin only)
 */
const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { nama, email, password, roleId, gajiPerJam, shift } = req.body;

    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { id: parseInt(id) }
    });

    if (!existingUser) {
      return res.status(404).json({
        message: 'User tidak ditemukan'
      });
    }

    // Validate shift if provided
    if (shift && !['Pagi', 'Sore'].includes(shift)) {
      return res.status(400).json({
        message: 'Shift harus "Pagi" atau "Sore"'
      });
    }

    // Check if email is already used by another user
    if (email && email !== existingUser.email) {
      const emailExists = await prisma.user.findUnique({
        where: { email }
      });

      if (emailExists) {
        return res.status(409).json({
          message: 'Email sudah digunakan oleh user lain'
        });
      }
    }

    // Check if role exists
    if (roleId) {
      const role = await prisma.role.findUnique({
        where: { id: parseInt(roleId) }
      });

      if (!role) {
        return res.status(404).json({
          message: 'Role tidak ditemukan'
        });
      }
    }

    // Prepare update data
    const updateData = {};
    if (nama) updateData.nama = nama;
    if (email) updateData.email = email;
    if (roleId) updateData.roleId = parseInt(roleId);
    if (gajiPerJam !== undefined) updateData.gajiPerJam = parseFloat(gajiPerJam);
    if (shift !== undefined) updateData.shift = shift; // Allow null to unassign shift
    
    // Hash password if provided
    if (password) {
      updateData.password = await bcrypt.hash(password, 10);
    }

    // Update user
    const user = await prisma.user.update({
      where: { id: parseInt(id) },
      data: updateData,
      select: {
        id: true,
        nama: true,
        email: true,
        roleId: true,
        gajiPerJam: true,
        shift: true,
        updatedAt: true,
        role: {
          select: {
            nama: true
          }
        }
      }
    });

    res.status(200).json({
      message: 'User berhasil diupdate',
      data: user
    });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({
      message: 'Terjadi kesalahan saat mengupdate user',
      error: error.message
    });
  }
};

/**
 * DELETE /users/:id - Delete user (Admin only)
 */
const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user exists
    const user = await prisma.user.findUnique({
      where: { id: parseInt(id) },
      include: {
        _count: {
          select: {
            absensi: true,
            slipGaji: true,
            jadwal: true,
            laporanPemasukan: true
          }
        }
      }
    });

    if (!user) {
      return res.status(404).json({
        message: 'User tidak ditemukan'
      });
    }

    // Check if user has related data
    const hasRelatedData = 
      user._count.absensi > 0 || 
      user._count.slipGaji > 0 || 
      user._count.jadwal > 0 || 
      user._count.laporanPemasukan > 0;

    if (hasRelatedData) {
      return res.status(400).json({
        message: 'Tidak dapat menghapus user. User memiliki data terkait',
        relatedData: {
          absensi: user._count.absensi,
          slipGaji: user._count.slipGaji,
          jadwal: user._count.jadwal,
          laporanPemasukan: user._count.laporanPemasukan
        }
      });
    }

    // Delete user
    await prisma.user.delete({
      where: { id: parseInt(id) }
    });

    res.status(200).json({
      message: 'User berhasil dihapus',
      data: {
        id: user.id,
        nama: user.nama,
        email: user.email
      }
    });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({
      message: 'Terjadi kesalahan saat menghapus user',
      error: error.message
    });
  }
};

module.exports = {
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser
};
