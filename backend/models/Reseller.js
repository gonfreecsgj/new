const mongoose = require('mongoose');

const resellerSchema = new mongoose.Schema({
  // Belongs to Manager
  managerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Manager',
    required: true,
    index: true
  },
  
  // Basic Info
  name: {
    type: String,
    required: true
  },
  code: {
    type: String,
    required: true,
    unique: true
  },
  phone: String,
  email: String,
  address: String,
  
  // Balance & Commission
  balance: {
    type: Number,
    default: 0
  },
  commissionRate: {
    type: Number,
    default: 0.1 // 10%
  },
  totalCommission: {
    type: Number,
    default: 0
  },
  
  // Stats
  stats: {
    totalSales: { type: Number, default: 0 },
    totalRecharges: { type: Number, default: 0 },
    totalRevenue: { type: Number, default: 0 }
  },
  
  // Status
  status: {
    type: String,
    enum: ['active', 'inactive', 'suspended'],
    default: 'active'
  },
  
  // Login (for reseller app)
  loginPin: String, // 4-6 digit PIN
  lastLoginAt: Date,
  deviceId: String,
  
  // Notes
  notes: String,
  
  // Meta
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Indexes
resellerSchema.index({ managerId: 1, status: 1 });
resellerSchema.index({ code: 1 });

// Methods
resellerSchema.methods.addBalance = function(amount) {
  this.balance += amount;
  return this.save();
};

resellerSchema.methods.deductBalance = function(amount) {
  if (this.balance < amount) {
    throw new Error('Insufficient balance');
  }
  this.balance -= amount;
  return this.save();
};

resellerSchema.methods.addCommission = function(amount) {
  this.totalCommission += amount;
  this.stats.totalRevenue += amount;
  return this.save();
};

resellerSchema.methods.recordSale = function(amount) {
  this.stats.totalSales += 1;
  this.stats.totalRevenue += amount;
  return this.save();
};

resellerSchema.methods.recordRecharge = function(amount) {
  this.stats.totalRecharges += 1;
  this.stats.totalRevenue += amount;
  return this.save();
};

// Statics
resellerSchema.statics.findByCode = function(code) {
  return this.findOne({ code: code.toUpperCase() });
};

resellerSchema.statics.findByManager = function(managerId) {
  return this.find({ managerId, status: 'active' });
};

// Pre-save middleware
resellerSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  if (this.code) {
    this.code = this.code.toUpperCase();
  }
  next();
});

module.exports = mongoose.model('Reseller', resellerSchema);
