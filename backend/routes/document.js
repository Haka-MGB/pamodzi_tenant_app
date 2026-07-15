const express = require('express');
const router = express.Router();
const documentController = require('../controllers/documentController');
const { protect } = require('../middleware/auth');

// All routes require authentication
router.use(protect);

// Generate lease PDF
router.get('/lease/:leaseId/pdf', documentController.generateLeasePDF);

// Generate receipt PDF
router.get('/receipt/:paymentId/pdf', documentController.generateReceiptPDF);

module.exports = router;
