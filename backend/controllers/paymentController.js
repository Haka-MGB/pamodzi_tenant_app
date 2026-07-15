const Payment = require('../models/Payment');
const Lease = require('../models/Lease');
const Notification = require('../models/Notification');

// @desc    Get all payments for tenant
// @route   GET /api/v1/payments
// @access  Private
exports.getPayments = async (req, res) => {
  try {
    const payments = await Payment.find({ tenant: req.user.id })
      .populate('property', 'name address')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: payments.length,
      payments
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to get payments',
      error: error.message
    });
  }
};

// @desc    Get single payment
// @route   GET /api/v1/payments/:id
// @access  Private
exports.getPayment = async (req, res) => {
  try {
    const payment = await Payment.findById(req.params.id)
      .populate('property', 'name address')
      .populate('lease');

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found'
      });
    }

    // Check if payment belongs to user
    if (payment.tenant.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this payment'
      });
    }

    res.json({
      success: true,
      payment
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to get payment',
      error: error.message
    });
  }
};

// @desc    Create new payment
// @route   POST /api/v1/payments
// @access  Private
exports.createPayment = async (req, res) => {
  try {
    const { amount, paymentMethod, month, year, phoneNumber, bankDetails } = req.body;

    // Get tenant's active lease
    const lease = await Lease.findOne({
      tenant: req.user.id,
      status: 'active'
    });

    if (!lease) {
      return res.status(404).json({
        success: false,
        message: 'No active lease found'
      });
    }

    // Validate payment method requirements
    if (['airtel_money', 'mtn_momo'].includes(paymentMethod) && !phoneNumber) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required for mobile money payments'
      });
    }

    if (paymentMethod === 'bank_transfer' && !bankDetails) {
      return res.status(400).json({
        success: false,
        message: 'Bank details are required for bank transfer'
      });
    }

    // Create payment
    const payment = await Payment.create({
      tenant: req.user.id,
      lease: lease._id,
      property: lease.property,
      amount,
      paymentMethod,
      paymentFor: { month, year },
      phoneNumber,
      bankDetails,
      status: paymentMethod === 'deposit_slip' ? 'pending' : 'processing'
    });

    // TODO: Call actual payment gateway API here
    // For Airtel Money / MTN MoMo
    if (['airtel_money', 'mtn_momo'].includes(paymentMethod)) {
      // Simulate payment gateway call
      // In production: integrate with actual API
      setTimeout(async () => {
        payment.status = 'completed';
        payment.verifiedAt = new Date();
        await payment.save();

        // Create notification
        await Notification.create({
          recipient: req.user.id,
          type: 'payment',
          title: 'Payment Successful',
          message: `Your payment of K${amount} for ${month} ${year} has been processed successfully.`,
          relatedEntity: {
            entityType: 'Payment',
            entityId: payment._id
          }
        });
      }, 3000);
    }

    res.status(201).json({
      success: true,
      message: 'Payment initiated successfully',
      payment: {
        id: payment._id,
        transactionId: payment.transactionId,
        amount: payment.amount,
        status: payment.status,
        paymentMethod: payment.paymentMethod
      }
    });
  } catch (error) {
    console.error('Payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process payment',
      error: error.message
    });
  }
};

// @desc    Verify payment status
// @route   GET /api/v1/payments/verify/:transactionId
// @access  Private
exports.verifyPayment = async (req, res) => {
  try {
    const payment = await Payment.findOne({
      transactionId: req.params.transactionId,
      tenant: req.user.id
    });

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found'
      });
    }

    // TODO: In production, verify with payment gateway
    res.json({
      success: true,
      payment: {
        transactionId: payment.transactionId,
        status: payment.status,
        amount: payment.amount,
        verifiedAt: payment.verifiedAt
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to verify payment',
      error: error.message
    });
  }
};

// @desc    Generate payment receipt
// @route   GET /api/v1/payments/:id/receipt
// @access  Private
exports.generateReceipt = async (req, res) => {
  try {
    const payment = await Payment.findById(req.params.id)
      .populate('tenant', 'firstName lastName email phone')
      .populate('property', 'name address')
      .populate('lease');

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found'
      });
    }

    if (payment.tenant._id.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    // TODO: Generate PDF receipt
    // For now, return receipt data
    res.json({
      success: true,
      receipt: {
        receiptNumber: payment.receiptNumber,
        transactionId: payment.transactionId,
        date: payment.createdAt,
        tenant: payment.tenant,
        property: payment.property,
        amount: payment.amount,
        paymentFor: payment.paymentFor,
        paymentMethod: payment.paymentMethod
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to generate receipt',
      error: error.message
    });
  }
};
