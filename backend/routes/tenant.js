const express = require('express');
const router = express.Router();
const tenantController = require('../controllers/tenantController');
const { protect, authorize } = require('../middleware/auth');

// All routes require authentication
router.use(protect);

// Get tenant dashboard data
router.get('/dashboard', tenantController.getDashboard);

// Get tenant's active lease
router.get('/lease', tenantController.getLease);

// Get tenant's property details
router.get('/property', tenantController.getProperty);

module.exports = router;
