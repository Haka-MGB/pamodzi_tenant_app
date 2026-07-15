const mongoose = require('mongoose');

const leaseSchema = new mongoose.Schema({
  tenant: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  property: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Property',
    required: true
  },
  landlord: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  startDate: {
    type: Date,
    required: [true, 'Lease start date is required']
  },
  endDate: {
    type: Date,
    required: [true, 'Lease end date is required']
  },
  rentAmount: {
    type: Number,
    required: [true, 'Rent amount is required']
  },
  securityDeposit: {
    type: Number,
    default: 0
  },
  paymentFrequency: {
    type: String,
    enum: ['monthly', 'quarterly', 'yearly'],
    default: 'monthly'
  },
  status: {
    type: String,
    enum: ['active', 'expired', 'terminated', 'pending'],
    default: 'active'
  },
  terms: {
    type: String,
    required: true
  },
  documents: [{
    type: {
      type: String,
      enum: ['contract', 'identification', 'proof_of_income', 'other']
    },
    url: String,
    uploadedAt: {
      type: Date,
      default: Date.now
    }
  }],
  signature: {
    tenant: {
      signed: { type: Boolean, default: false },
      signedAt: Date,
      signatureUrl: String
    },
    landlord: {
      signed: { type: Boolean, default: false },
      signedAt: Date,
      signatureUrl: String
    }
  },
  notes: {
    type: String
  }
}, {
  timestamps: true
});

// Virtual to check if lease is currently active
leaseSchema.virtual('isActive').get(function() {
  const now = new Date();
  return this.status === 'active' && 
         this.startDate <= now && 
         this.endDate >= now;
});

leaseSchema.set('toJSON', { virtuals: true });
leaseSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Lease', leaseSchema);
