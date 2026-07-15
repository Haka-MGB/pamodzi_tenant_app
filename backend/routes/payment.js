const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const { protect } = require('../middleware/auth');

// All routes require authentication
router.use(protect);

// Get all payments for logged-in tenant
router.get('/', paymentController.getPayments);

// Get single payment
router.get('/:id', paymentController.getPayment);

// Create payment (Airtel Money, MTN MoMo, Bank Transfer)
router.post('/', paymentController.createPayment);

// Verify payment status
router.get('/verify/:transactionId', paymentController.verifyPayment);

// Generate receipt PDF
router.get('/:id/receipt', paymentController.generateReceipt);

module.exports = router;
