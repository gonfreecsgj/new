const mongoose = require('mongoose');

const voucherSchema = new mongoose.Schema({
  // Belongs to Manager
  managerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Manager',
    required: true,
    index: true
  },
  
  // Voucher Code
  code: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  password: String,
  
  // Profile Info
  profileName: {
    type: String,
    required: true
  },
  dataLimit: { // in GB
    type: Number,
    required: true
  },
  timeLimit: { // in hours
    type: Number,
    required: true
  },
  validityDays: {
    type: Number,
    required: true
  },
  
  // Shelf Assignment
  shelfId: {
    type: String,
    default: 'default',
    index: true
  },
  
  // Reseller Assignment (for recharge system)
  resellerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Reseller',
    index: true
  },
  
  // Status
  status: {
    type: String,
    enum: ['active', 'used', 'expired', 'disabled', 'recharged'],
    default: 'active',
    index: true
  },
  
  // Usage Info
  usage: {
    usedAt: Date,
    usedByMac: String,
    usedByIp: String,
    usedByDevice: String,
    dataUsed: { type: Number, default: 0 }, // MB
    timeUsed: { type: Number, default: 0 }, // minutes
  },
  
  // Recharge History (for rechargeable vouchers)
  rechargeHistory: [{
    resellerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Reseller'
    },
    amount: Number, // amount paid by customer
    dataAdded: Number,
    commission: Number,
    rechargedAt: { type: Date, default: Date.now }
  }],
  
  // Expiry
  expiresAt: Date,
  
  // Printing
  printedAt: Date,
  printCount: { type: Number, default: 0 },
  
  // Notes
  notes: String,
  
  // Meta
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Indexes
voucherSchema.index({ managerId: 1, status: 1 });
voucherSchema.index({ managerId: 1, shelfId: 1 });
voucherSchema.index({ resellerId: 1, status: 1 });
voucherSchema.index({ createdAt: -1 });

// Virtuals
voucherSchema.virtual('isExpired').get(function() {
  if (this.expiresAt) {
    return this.expiresAt < Date.now();
  }
  return false;
});

voucherSchema.virtual('remainingData').get(function() {
  return Math.max(0, this.dataLimit * 1024 - this.usage.dataUsed);
});

voucherSchema.virtual('remainingTime').get(function() {
  return Math.max(0, this.timeLimit * 60 - this.usage.timeUsed);
});

// Methods
voucherSchema.methods.markAsUsed = function(mac, ip, device) {
  this.status = 'used';
  this.usage.usedAt = new Date();
  this.usage.usedByMac = mac;
  this.usage.usedByIp = ip;
  this.usage.usedByDevice = device;
  return this.save();
};

voucherSchema.methods.recharge = function(resellerId, amount, dataAdded, commission) {
  this.rechargeHistory.push({
    resellerId,
    amount,
    dataAdded,
    commission
  });
  
  // Reset usage and extend expiry
  this.status = 'recharged';
  this.usage.dataUsed = 0;
  this.usage.timeUsed = 0;
  this.expiresAt = new Date(Date.now() + this.validityDays * 24 * 60 * 60 * 1000);
  
  return this.save();
};

voucherSchema.methods.markAsPrinted = function() {
  this.printedAt = new Date();
  this.printCount += 1;
  return this.save();
};

// Statics
voucherSchema.statics.findByCode = function(code) {
  return this.findOne({ code: code.toUpperCase() });
};

voucherSchema.statics.findByManager = function(managerId, options = {}) {
  const query = { managerId };
  if (options.status) query.status = options.status;
  if (options.shelfId) query.shelfId = options.shelfId;
  
  return this.find(query)
    .sort({ createdAt: -1 })
    .limit(options.limit || 100);
};

voucherSchema.statics.getStats = async function(managerId) {
  const stats = await this.aggregate([
    { $match: { managerId: new mongoose.Types.ObjectId(managerId) } },
    {
      $group: {
        _id: '$status',
        count: { $sum: 1 }
      }
    }
  ]);
  
  const result = {
    total: 0,
    active: 0,
    used: 0,
    expired: 0,
    disabled: 0,
    recharged: 0
  };
  
  stats.forEach(stat => {
    result[stat._id] = stat.count;
    result.total += stat.count;
  });
  
  return result;
};

// Pre-save middleware
voucherSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  
  // Set expiry date if not set
  if (!this.expiresAt && this.validityDays) {
    this.expiresAt = new Date(Date.now() + this.validityDays * 24 * 60 * 60 * 1000);
  }
  
  // Convert code to uppercase
  if (this.code) {
    this.code = this.code.toUpperCase();
  }
  
  next();
});

module.exports = mongoose.model('Voucher', voucherSchema);
