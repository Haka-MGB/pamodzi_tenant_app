const Lease = require('../models/Lease');
const Payment = require('../models/Payment');

// @desc    Generate lease PDF
// @route   GET /api/v1/documents/lease/:leaseId/pdf
// @access  Private
exports.generateLeasePDF = async (req, res) => {
  try {
    const lease = await Lease.findById(req.params.leaseId)
      .populate('tenant', 'firstName lastName email phone')
      .populate('property', 'name address')
      .populate('landlord', 'firstName lastName email phone');

    if (!lease) {
      return res.status(404).json({
        success: false,
        message: 'Lease not found'
      });
    }

    // Check authorization
    if (lease.tenant._id.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    // TODO: Generate actual PDF using pdf library
    // For now, return lease data
    res.json({
      success: true,
      message: 'PDF generation not yet implemented',
      lease: {
        id: lease._id,
        tenant: lease.tenant,
        property: lease.property,
        landlord: lease.landlord,
        startDate: lease.startDate,
        endDate: lease.endDate,
        rentAmount: lease.rentAmount,
        securityDeposit: lease.securityDeposit,
        terms: lease.terms
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to generate lease PDF',
      error: error.message
    });
  }
};

// @desc    Generate receipt PDF
// @route   GET /api/v1/documents/receipt/:paymentId/pdf
// @access  Private
exports.generateReceiptPDF = async (req, res) => {
  try {
    const payment = await Payment.findById(req.params.paymentId)
      .populate('tenant', 'firstName lastName email phone')
      .populate('property', 'name address')
      .populate('lease');

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found'
      });
    }

    // Check authorization
    if (payment.tenant._id.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    // TODO: Generate actual PDF using pdf library
    // For now, return receipt data
    res.json({
      success: true,
      message: 'PDF generation not yet implemented',
      receipt: {
        receiptNumber: payment.receiptNumber,
        transactionId: payment.transactionId,
        date: payment.createdAt,
        tenant: payment.tenant,
        property: payment.property,
        amount: payment.amount,
        currency: payment.currency,
        paymentFor: payment.paymentFor,
        paymentMethod: payment.paymentMethod,
        status: payment.status
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to generate receipt PDF',
      error: error.message
    });
  }
};
