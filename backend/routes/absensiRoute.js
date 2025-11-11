const express = require('express');
const router = express.Router();
const absensiController = require('../controller/absensiController');
const { authenticateToken, isAdmin } = require('../middleware/authMiddleware');

// Endpoint untuk semua user yang login
router.post('/clock-in', authenticateToken, absensiController.clockIn);
router.post('/clock-out', authenticateToken, absensiController.clockOut);
router.get('/my', authenticateToken, absensiController.getMyAbsensi);
router.get('/today', authenticateToken, absensiController.getAbsensiToday);

// Endpoint untuk Admin only
router.get('/all', authenticateToken, isAdmin, absensiController.getAllAbsensi);

module.exports = router;
