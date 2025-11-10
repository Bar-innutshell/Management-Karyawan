const express = require('express');
const router = express.Router();
const gajiController = require('../controller/gajiController');
const { authenticateToken, isAdmin } = require('../middleware/authMiddleware');

// Semua endpoint gaji hanya untuk Admin
router.post('/set-gaji-perjam', authenticateToken, isAdmin, gajiController.setGajiPerJam);
router.post('/hitung-dari-gaji-pokok', authenticateToken, isAdmin, gajiController.hitungGajiDariGajiPokok);
router.get('/user/:userId', authenticateToken, isAdmin, gajiController.getUserGaji);
router.get('/all', authenticateToken, isAdmin, gajiController.getAllUserGaji);

module.exports = router;
