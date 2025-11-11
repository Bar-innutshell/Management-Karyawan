const prisma = require('../config/prismaClient');

/**
 * GET /shifts - Get all shifts
 */
const getAllShifts = async (req, res) => {
  try {
    const { aktif } = req.query;
    
    const whereClause = {};
    
    // Filter by aktif status if provided
    if (aktif !== undefined) {
      whereClause.aktif = aktif === 'true';
    }
    
    const shifts = await prisma.shift.findMany({
      where: whereClause,
      orderBy: {
        nama: 'asc'
      }
    });

    res.status(200).json({
      message: 'Daftar shift berhasil diambil',
      data: shifts,
      total: shifts.length
    });
  } catch (error) {
    console.error('Error getting shifts:', error);
    res.status(500).json({
      message: 'Terjadi kesalahan saat mengambil data shift',
      error: error.message
    });
  }
};

/**
 * GET /shifts/:id - Get shift by ID
 */
const getShiftById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const shift = await prisma.shift.findUnique({
      where: { id: parseInt(id) }
    });

    if (!shift) {
      return res.status(404).json({
        message: 'Shift tidak ditemukan'
      });
    }

    res.status(200).json({
      message: 'Data shift berhasil diambil',
      data: shift
    });
  } catch (error) {
    console.error('Error getting shift:', error);
    res.status(500).json({
      message: 'Terjadi kesalahan saat mengambil data shift',
      error: error.message
    });
  }
};

/**
 * POST /shifts - Create new shift (Admin only)
 */
const createShift = async (req, res) => {
  try {
    const { nama, jamMulai, jamSelesai, deskripsi, aktif } = req.body;

    // Validation
    if (!nama || !jamMulai || !jamSelesai) {
      return res.status(400).json({
        message: 'Nama, jamMulai, dan jamSelesai harus diisi'
      });
    }

    // Validate time format (HH:MM)
    const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (!timeRegex.test(jamMulai) || !timeRegex.test(jamSelesai)) {
      return res.status(400).json({
        message: 'Format waktu harus HH:MM (contoh: 08:00, 14:30)'
      });
    }

    // Check if shift name already exists
    const existingShift = await prisma.shift.findUnique({
      where: { nama }
    });

    if (existingShift) {
      return res.status(409).json({
        message: 'Nama shift sudah ada'
      });
    }

    // Create shift
    const shift = await prisma.shift.create({
      data: {
        nama,
        jamMulai,
        jamSelesai,
        deskripsi: deskripsi || null,
        aktif: aktif !== undefined ? aktif : true
      }
    });

    res.status(201).json({
      message: 'Shift berhasil dibuat',
      data: shift
    });
  } catch (error) {
    console.error('Error creating shift:', error);
    res.status(500).json({
      message: 'Terjadi kesalahan saat membuat shift',
      error: error.message
    });
  }
};

/**
 * PUT /shifts/:id - Update shift (Admin only)
 */
const updateShift = async (req, res) => {
  try {
    const { id } = req.params;
    const { nama, jamMulai, jamSelesai, deskripsi, aktif } = req.body;

    // Check if shift exists
    const existingShift = await prisma.shift.findUnique({
      where: { id: parseInt(id) }
    });

    if (!existingShift) {
      return res.status(404).json({
        message: 'Shift tidak ditemukan'
      });
    }

    // Validate time format if provided
    const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (jamMulai && !timeRegex.test(jamMulai)) {
      return res.status(400).json({
        message: 'Format jamMulai harus HH:MM (contoh: 08:00, 14:30)'
      });
    }
    if (jamSelesai && !timeRegex.test(jamSelesai)) {
      return res.status(400).json({
        message: 'Format jamSelesai harus HH:MM (contoh: 08:00, 14:30)'
      });
    }

    // Check if nama is already used by another shift
    if (nama && nama !== existingShift.nama) {
      const namaExists = await prisma.shift.findUnique({
        where: { nama }
      });

      if (namaExists) {
        return res.status(409).json({
          message: 'Nama shift sudah digunakan'
        });
      }
    }

    // Prepare update data
    const updateData = {};
    if (nama) updateData.nama = nama;
    if (jamMulai) updateData.jamMulai = jamMulai;
    if (jamSelesai) updateData.jamSelesai = jamSelesai;
    if (deskripsi !== undefined) updateData.deskripsi = deskripsi;
    if (aktif !== undefined) updateData.aktif = aktif;

    // Update shift
    const shift = await prisma.shift.update({
      where: { id: parseInt(id) },
      data: updateData
    });

    res.status(200).json({
      message: 'Shift berhasil diupdate',
      data: shift
    });
  } catch (error) {
    console.error('Error updating shift:', error);
    res.status(500).json({
      message: 'Terjadi kesalahan saat mengupdate shift',
      error: error.message
    });
  }
};

/**
 * DELETE /shifts/:id - Delete shift (Admin only)
 */
const deleteShift = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if shift exists
    const shift = await prisma.shift.findUnique({
      where: { id: parseInt(id) }
    });

    if (!shift) {
      return res.status(404).json({
        message: 'Shift tidak ditemukan'
      });
    }

    // Delete shift
    await prisma.shift.delete({
      where: { id: parseInt(id) }
    });

    res.status(200).json({
      message: 'Shift berhasil dihapus',
      data: {
        id: shift.id,
        nama: shift.nama
      }
    });
  } catch (error) {
    console.error('Error deleting shift:', error);
    res.status(500).json({
      message: 'Terjadi kesalahan saat menghapus shift',
      error: error.message
    });
  }
};

module.exports = {
  getAllShifts,
  getShiftById,
  createShift,
  updateShift,
  deleteShift
};
