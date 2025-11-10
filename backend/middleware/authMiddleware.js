const jwt = require('jsonwebtoken');

exports.authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Token tidak ditemukan. Silakan login terlebih dahulu.' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ message: 'Token tidak valid atau expired.' });
    }

    req.user = user;
    next();
  });
};

exports.isAdmin = async (req, res, next) => {
  const prisma = require('../config/prismaClient');

  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
      include: { role: true }
    });

    if (!user) {
      return res.status(404).json({ message: 'User tidak ditemukan' });
    }

    if (user.role.nama !== 'Admin') {
      return res.status(403).json({ message: 'Akses ditolak. Hanya Admin yang bisa mengakses endpoint ini.' });
    }

    req.userData = user; // Simpan data user untuk dipakai di controller
    next();
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};

exports.isCashier = async (req, res, next) => {
  const prisma = require('../config/prismaClient');

  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
      include: { role: true }
    });

    if (!user) {
      return res.status(404).json({ message: 'User tidak ditemukan' });
    }

    if (user.role.nama !== 'Cashier') {
      return res.status(403).json({ message: 'Akses ditolak. Hanya Cashier yang bisa mengakses endpoint ini.' });
    }

    req.userData = user; // Simpan data user untuk dipakai di controller
    next();
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan pada server', error: error.message });
  }
};
