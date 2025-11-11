const express = require('express');
const router = express.Router();
const shiftController = require('../controller/shiftController');
const { authenticateToken, isAdmin } = require('../middleware/authMiddleware');

// Shift adalah TEMPLATE (seeded), hanya bisa dibaca
// GET /shifts - Get all shifts (All authenticated users can view)
router.get('/', authenticateToken, shiftController.getAllShifts);

// GET /shifts/:id - Get shift by ID (All authenticated users can view)
router.get('/:id', authenticateToken, shiftController.getShiftById);

// POST, PUT, DELETE dihapus - Shift adalah template tetap
// Jika perlu ubah shift, update langsung di seed.js dan re-seed
// POST /shifts - DISABLED (shift adalah template)
// PUT /shifts/:id - DISABLED (shift adalah template)
// DELETE /shifts/:id - DISABLED (shift adalah template)

module.exports = router;
