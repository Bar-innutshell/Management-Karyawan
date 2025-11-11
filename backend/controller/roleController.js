const prisma = require('../config/prismaClient');

exports.getAllRoles = async (req, res) => {
  try {
    const roles = await prisma.role.findMany({
      select: {
        id: true,
        nama: true,
        gajiPokokBulanan: true,
        deskripsi: true,
        createdAt: true,
        updatedAt: true,
        _count: {
          select: { users: true }
        }
      },
      orderBy: { id: 'asc' }
    });

    res.json({
      message: 'Daftar role berhasil diambil',
      data: roles
    });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};

exports.getRoleById = async (req, res) => {
  const { id } = req.params;

  try {
    const role = await prisma.role.findUnique({
      where: { id: parseInt(id) },
      include: {
        users: {
          select: {
            id: true,
            nama: true,
            email: true
          }
        }
      }
    });

    if (!role) {
      return res.status(404).json({ message: 'Role tidak ditemukan' });
    }

    res.json({
      message: 'Role berhasil diambil',
      data: role
    });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};

exports.createRole = async (req, res) => {
  const { nama, gajiPokokBulanan, deskripsi } = req.body;

  try {
    if (!nama) {
      return res.status(400).json({ message: 'Nama role wajib diisi' });
    }

    const roleExists = await prisma.role.findUnique({
      where: { nama: nama }
    });

    if (roleExists) {
      return res.status(409).json({ message: 'Role dengan nama ini sudah ada' });
    }

    const newRole = await prisma.role.create({
      data: {
        nama: nama,
        gajiPokokBulanan: parseFloat(gajiPokokBulanan) || 0,
        deskripsi: deskripsi || null
      }
    });

    res.status(201).json({
      message: 'Role berhasil dibuat',
      data: newRole
    });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};

exports.updateRole = async (req, res) => {
  const { id } = req.params;
  const { nama, gajiPokokBulanan, deskripsi } = req.body;

  try {
    const roleExists = await prisma.role.findUnique({
      where: { id: parseInt(id) }
    });

    if (!roleExists) {
      return res.status(404).json({ message: 'Role tidak ditemukan' });
    }

    if (nama && nama !== roleExists.nama) {
      const namaExists = await prisma.role.findUnique({
        where: { nama: nama }
      });

      if (namaExists) {
        return res.status(409).json({ message: 'Nama role sudah digunakan' });
      }
    }

    const updatedRole = await prisma.role.update({
      where: { id: parseInt(id) },
      data: {
        ...(nama && { nama }),
        ...(gajiPokokBulanan !== undefined && { gajiPokokBulanan: parseFloat(gajiPokokBulanan) }),
        ...(deskripsi !== undefined && { deskripsi })
      }
    });

    res.json({
      message: 'Role berhasil diupdate',
      data: updatedRole
    });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};

exports.deleteRole = async (req, res) => {
  const { id } = req.params;

  try {
    const role = await prisma.role.findUnique({
      where: { id: parseInt(id) },
      include: {
        _count: {
          select: { users: true }
        }
      }
    });

    if (!role) {
      return res.status(404).json({ message: 'Role tidak ditemukan' });
    }

    if (role._count.users > 0) {
      return res.status(400).json({
        message: `Tidak bisa hapus role. Masih ada ${role._count.users} user yang menggunakan role ini`
      });
    }

    await prisma.role.delete({
      where: { id: parseInt(id) }
    });

    res.json({
      message: 'Role berhasil dihapus',
      data: role
    });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};
