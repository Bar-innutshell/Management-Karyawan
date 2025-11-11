const express = require('express');
const router = express.Router();
const userController = require('../controller/userController');
const { authenticateToken, isAdmin } = require('../middleware/authMiddleware');

// All routes require authentication and admin role
router.use(authenticateToken);
router.use(isAdmin);

// GET /users - Get all users
router.get('/', userController.getAllUsers);

// GET /users/:id - Get user by ID
router.get('/:id', userController.getUserById);

// POST /users - Create new user
router.post('/', userController.createUser);

// PUT /users/:id - Update user
router.put('/:id', userController.updateUser);

// DELETE /users/:id - Delete user
router.delete('/:id', userController.deleteUser);

module.exports = router;
