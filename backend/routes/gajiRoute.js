const express = require('express');
const router = express.Router();
const gajiController = require('../controller/gajiController');
const { authenticateToken, isAdmin } = require('../middleware/authMiddleware');

// Endpoint gaji per jam (Admin only)
router.post('/set-gaji-perjam', authenticateToken, isAdmin, gajiController.setGajiPerJam);
router.post('/hitung-dari-gaji-pokok', authenticateToken, isAdmin, gajiController.hitungGajiDariGajiPokok);
router.get('/user/:userId', authenticateToken, isAdmin, gajiController.getUserGaji);
router.get('/all', authenticateToken, isAdmin, gajiController.getAllUserGaji);

// Endpoint slip gaji
router.post('/slip/generate', authenticateToken, isAdmin, gajiController.generateSlipGaji); // Admin only
router.get('/slip/user/:userId', authenticateToken, gajiController.getSlipGaji); // User bisa lihat slip sendiri
router.get('/slip/all', authenticateToken, isAdmin, gajiController.getAllSlipGaji); // Admin only

module.exports = router;
