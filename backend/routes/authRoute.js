const express = require('express');
const router = express.Router();
const AuthController = require('../controller/authController');

// Register dihapus - Hanya admin yang bisa create user via /users endpoint
// router.post('/register', AuthController.register);
router.post('/login', AuthController.login);

module.exports = router;