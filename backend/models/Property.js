const mongoose = require('mongoose');

const propertySchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Property name is required'],
    trim: true
  },
  address: {
    street: { type: String, required: true },
    city: { type: String, required: true },
    province: { type: String, required: true },
    zipCode: { type: String }
  },
  type: {
    type: String,
    enum: ['apartment', 'house', 'duplex', 'studio', 'room'],
    required: true
  },
  bedrooms: {
    type: Number,
    min: 0
  },
  bathrooms: {
    type: Number,
    min: 0
  },
  size: {
    value: Number,
    unit: {
      type: String,
      enum: ['sqm', 'sqft'],
      default: 'sqm'
    }
  },
  rent: {
    amount: {
      type: Number,
      required: [true, 'Rent amount is required']
    },
    currency: {
      type: String,
      default: 'ZMW'
    },
    dueDay: {
      type: Number,
      min: 1,
      max: 31,
      default: 1
    }
  },
  landlord: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  amenities: [{
    type: String
  }],
  images: [{
    url: String,
    caption: String
  }],
  isAvailable: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Property', propertySchema);
