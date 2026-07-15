const Lease = require('../models/Lease');
const Property = require('../models/Property');
const Payment = require('../models/Payment');
const MaintenanceIssue = require('../models/MaintenanceIssue');
const Notification = require('../models/Notification');

// @desc    Get tenant dashboard data
// @route   GET /api/v1/tenant/dashboard
// @access  Private
exports.getDashboard = async (req, res) => {
  try {
    const tenantId = req.user.id;

    // Get active lease
    const lease = await Lease.findOne({
      tenant: tenantId,
      status: 'active'
    }).populate('property landlord');

    if (!lease) {
      return res.status(404).json({
        success: false,
        message: 'No active lease found'
      });
    }

    // Get latest payment
    const latestPayment = await Payment.findOne({
      tenant: tenantId,
      status: 'completed'
    }).sort({ createdAt: -1 });

    // Get payment history (last 6 months)
    const payments = await Payment.find({
      tenant: tenantId
    }).sort({ createdAt: -1 }).limit(6);

    // Get open maintenance issues
    const openIssues = await MaintenanceIssue.find({
      tenant: tenantId,
      status: { $ne: 'Closed' }
    }).sort({ createdAt: -1 });

    // Get unread notifications count
    const unreadNotifications = await Notification.countDocuments({
      recipient: tenantId,
      isRead: false
    });

    res.json({
      success: true,
      data: {
        lease: {
          id: lease._id,
          property: lease.property,
          landlord: lease.landlord,
          rentAmount: lease.rentAmount,
          startDate: lease.startDate,
          endDate: lease.endDate,
          status: lease.status
        },
        latestPayment: latestPayment ? {
          id: latestPayment._id,
          amount: latestPayment.amount,
          month: latestPayment.paymentFor.month,
          year: latestPayment.paymentFor.year,
          status: latestPayment.status,
          date: latestPayment.createdAt
        } : null,
        payments: payments.map(p => ({
          id: p._id,
          amount: p.amount,
          month: p.paymentFor.month,
          status: p.status,
          method: p.paymentMethod,
          date: p.createdAt
        })),
        openIssues: openIssues.map(i => ({
          id: i._id,
          title: i.title,
          category: i.category,
          status: i.status,
          priority: i.priority,
          date: i.createdAt
        })),
        unreadNotifications
      }
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to load dashboard data',
      error: error.message
    });
  }
};

// @desc    Get tenant's active lease
// @route   GET /api/v1/tenant/lease
// @access  Private
exports.getLease = async (req, res) => {
  try {
    const lease = await Lease.findOne({
      tenant: req.user.id,
      status: 'active'
    }).populate('property landlord');

    if (!lease) {
      return res.status(404).json({
        success: false,
        message: 'No active lease found'
      });
    }

    res.json({
      success: true,
      lease: {
        id: lease._id,
        tenant: lease.tenant,
        property: lease.property,
        landlord: lease.landlord,
        startDate: lease.startDate,
        endDate: lease.endDate,
        rentAmount: lease.rentAmount,
        securityDeposit: lease.securityDeposit,
        paymentFrequency: lease.paymentFrequency,
        status: lease.status,
        terms: lease.terms,
        documents: lease.documents
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to get lease',
      error: error.message
    });
  }
};

// @desc    Get tenant's property details
// @route   GET /api/v1/tenant/property
// @access  Private
exports.getProperty = async (req, res) => {
  try {
    const lease = await Lease.findOne({
      tenant: req.user.id,
      status: 'active'
    }).populate('property');

    if (!lease) {
      return res.status(404).json({
        success: false,
        message: 'No active lease found'
      });
    }

    res.json({
      success: true,
      property: lease.property
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to get property',
      error: error.message
    });
  }
};
