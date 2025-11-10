const express = require('express');
const router = express.Router();
const pemasukkanController = require('../controller/pemasukkanController');
const { authenticateToken } = require('../middleware/authMiddleware');


router.get('/show', authenticateToken, pemasukkanController.showPemasukan);
router.post('/insert', authenticateToken, pemasukkanController.createPemasukkan);


module.exports = router;