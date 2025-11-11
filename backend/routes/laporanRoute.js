const express = require('express');
const router = express.Router();
const laporanController = require('../controller/laporanController');
const { authenticateToken, isAdmin } = require('../middleware/authMiddleware');

// Semua endpoint laporan hanya untuk Admin
router.get('/total', authenticateToken, isAdmin, laporanController.getTotalPemasukkan);
router.get('/harian', authenticateToken, isAdmin, laporanController.getLaporanHarian);
router.get('/detail', authenticateToken, isAdmin, laporanController.getLaporanDetail);

module.exports = router;
