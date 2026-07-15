const mongoose = require('mongoose');

const maintenanceIssueSchema = new mongoose.Schema({
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
  category: {
    type: String,
    enum: [
      'Plumbing',
      'Electrical',
      'HVAC',
      'Appliances',
      'Structural',
      'Pest Control',
      'Cleaning',
      'Security',
      'Other'
    ],
    required: true
  },
  title: {
    type: String,
    required: [true, 'Issue title is required'],
    trim: true,
    maxlength: 200
  },
  description: {
    type: String,
    required: [true, 'Issue description is required'],
    maxlength: 2000
  },
  priority: {
    type: String,
    enum: ['Urgent', 'High', 'Medium', 'Low'],
    default: 'Medium'
  },
  status: {
    type: String,
    enum: ['Open', 'In Progress', 'Resolved', 'Closed', 'Cancelled'],
    default: 'Open'
  },
  photos: [{
    url: {
      type: String,
      required: true
    },
    publicId: String, // For Cloudinary
    uploadedAt: {
      type: Date,
      default: Date.now
    }
  }],
  assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  assignedAt: {
    type: Date
  },
  resolvedAt: {
    type: Date
  },
  resolutionNotes: {
    type: String,
    maxlength: 1000
  },
  cost: {
    amount: Number,
    currency: {
      type: String,
      default: 'ZMW'
    },
    paidBy: {
      type: String,
      enum: ['tenant', 'landlord', 'split'],
      default: 'landlord'
    }
  },
  timeline: [{
    action: {
      type: String,
      required: true
    },
    performedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    timestamp: {
      type: Date,
      default: Date.now
    },
    notes: String
  }]
}, {
  timestamps: true
});

// Add timeline entry on status change
maintenanceIssueSchema.pre('save', function(next) {
  if (this.isModified('status')) {
    this.timeline.push({
      action: `Status changed to ${this.status}`,
      performedBy: this.assignedTo || this.tenant,
      timestamp: new Date()
    });
  }
  next();
});

// Index for faster queries
maintenanceIssueSchema.index({ tenant: 1, createdAt: -1 });
maintenanceIssueSchema.index({ status: 1 });
maintenanceIssueSchema.index({ priority: 1 });

module.exports = mongoose.model('MaintenanceIssue', maintenanceIssueSchema);
