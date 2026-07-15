const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  tenant: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  lease: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Lease',
    required: true
  },
  property: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Property',
    required: true
  },
  amount: {
    type: Number,
    required: [true, 'Payment amount is required'],
    min: 0
  },
  currency: {
    type: String,
    default: 'ZMW'
  },
  paymentMethod: {
    type: String,
    enum: ['airtel_money', 'mtn_momo', 'bank_transfer', 'deposit_slip', 'cash', 'other'],
    required: true
  },
  paymentFor: {
    month: {
      type: String,
      required: true
    },
    year: {
      type: Number,
      required: true
    }
  },
  status: {
    type: String,
    enum: ['pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded'],
    default: 'pending'
  },
  transactionId: {
    type: String,
    sparse: true
  },
  externalReference: {
    type: String, // Reference from payment provider (Airtel, MTN, etc.)
    sparse: true
  },
  phoneNumber: {
    type: String // For mobile money payments
  },
  bankDetails: {
    bankName: String,
    accountNumber: String,
    referenceNumber: String
  },
  depositSlip: {
    url: String,
    uploadedAt: Date
  },
  verifiedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  verifiedAt: {
    type: Date
  },
  receiptNumber: {
    type: String,
    unique: true,
    sparse: true
  },
  notes: {
    type: String
  },
  metadata: {
    type: Map,
    of: String
  }
}, {
  timestamps: true
});

// Generate unique transaction ID
paymentSchema.pre('save', async function(next) {
  if (!this.transactionId) {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 10000);
    this.transactionId = `PMZ${timestamp}${random}`;
  }
  
  if (!this.receiptNumber && this.status === 'completed') {
    const year = new Date().getFullYear();
    const count = await this.constructor.countDocuments({ status: 'completed' });
    this.receiptNumber = `RCP-${year}-${String(count + 1).padStart(6, '0')}`;
  }
  
  next();
});

// Index for faster queries
paymentSchema.index({ tenant: 1, createdAt: -1 });
paymentSchema.index({ status: 1 });
paymentSchema.index({ transactionId: 1 }, { unique: true, sparse: true });

module.exports = mongoose.model('Payment', paymentSchema);
