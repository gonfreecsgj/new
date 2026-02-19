const mongoose = require('mongoose');

const managerSchema = new mongoose.Schema({
  // Google Auth Info
  googleId: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  name: {
    type: String,
    required: true
  },
  photoUrl: String,
  
  // Device Lock
  deviceId: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  deviceInfo: {
    brand: String,
    model: String,
    version: String,
    lastIp: String
  },
  
  // Subscription Status
  status: {
    type: String,
    enum: ['trial', 'active', 'expired', 'suspended'],
    default: 'trial'
  },
  
  // Subscription Dates
  trialStartedAt: {
    type: Date,
    default: Date.now
  },
  trialEndsAt: {
    type: Date,
    default: () => new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days
  },
  subscriptionStartedAt: Date,
  subscriptionEndsAt: Date,
  
  // Payment History
  payments: [{
    amount: Number,
    currency: { type: String, default: 'USD' },
    months: Number,
    method: { type: String, enum: ['manual', 'paypal', 'stripe', 'crypto'] },
    status: { type: String, enum: ['pending', 'completed', 'failed', 'refunded'] },
    transactionId: String,
    notes: String,
    createdAt: { type: Date, default: Date.now }
  }],
  
  // Router Configuration
  router: {
    ip: { type: String, default: '192.168.88.1' },
    port: { type: Number, default: 8728 },
    username: { type: String, default: 'admin' },
    password: String, // encrypted
    isConnected: { type: Boolean, default: false },
    lastConnectedAt: Date,
    connectionError: String
  },
  
  // Stats
  stats: {
    totalVouchers: { type: Number, default: 0 },
    totalPrinted: { type: Number, default: 0 },
    totalResellers: { type: Number, default: 0 },
    totalRecharges: { type: Number, default: 0 },
    totalRevenue: { type: Number, default: 0 }
  },
  
  // Settings
  settings: {
    language: { type: String, default: 'ar' },
    currency: { type: String, default: 'USD' },
    timezone: { type: String, default: 'Asia/Aden' },
    notifications: {
      email: { type: Boolean, default: true },
      push: { type: Boolean, default: true },
      sms: { type: Boolean, default: false }
    }
  },
  
  // White Label
  whiteLabel: {
    enabled: { type: Boolean, default: false },
    appName: String,
    logoUrl: String,
    primaryColor: String,
    contactPhone: String,
    contactEmail: String
  },
  
  // Meta
  lastLoginAt: Date,
  lastActivityAt: { type: Date, default: Date.now },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Indexes
managerSchema.index({ status: 1, subscriptionEndsAt: 1 });
managerSchema.index({ createdAt: -1 });

// Virtuals
managerSchema.virtual('daysLeft').get(function() {
  if (this.status === 'trial') {
    return Math.ceil((this.trialEndsAt - Date.now()) / (1000 * 60 * 60 * 24));
  }
  if (this.subscriptionEndsAt) {
    return Math.ceil((this.subscriptionEndsAt - Date.now()) / (1000 * 60 * 60 * 24));
  }
  return 0;
});

managerSchema.virtual('isActive').get(function() {
  if (this.status === 'suspended') return false;
  if (this.status === 'trial') {
    return this.trialEndsAt > Date.now();
  }
  if (this.status === 'active') {
    return this.subscriptionEndsAt > Date.now();
  }
  return false;
});

// Methods
managerSchema.methods.extendSubscription = function(months) {
  const now = new Date();
  const currentEnd = this.subscriptionEndsAt || now;
  const baseDate = currentEnd > now ? currentEnd : now;
  
  this.subscriptionEndsAt = new Date(baseDate.getTime() + months * 30 * 24 * 60 * 60 * 1000);
  this.status = 'active';
  this.subscriptionStartedAt = this.subscriptionStartedAt || now;
  
  return this.save();
};

managerSchema.methods.addPayment = function(paymentData) {
  this.payments.push(paymentData);
  return this.save();
};

managerSchema.methods.updateStats = function(statsUpdate) {
  Object.assign(this.stats, statsUpdate);
  return this.save();
};

// Statics
managerSchema.statics.findByDeviceId = function(deviceId) {
  return this.findOne({ deviceId });
};

managerSchema.statics.findExpiringSoon = function(days = 3) {
  const date = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
  return this.find({
    status: { $in: ['trial', 'active'] },
    $or: [
      { trialEndsAt: { $lte: date, $gt: new Date() } },
      { subscriptionEndsAt: { $lte: date, $gt: new Date() } }
    ]
  });
};

managerSchema.statics.findExpired = function() {
  return this.find({
    status: { $in: ['trial', 'active'] },
    $or: [
      { trialEndsAt: { $lte: new Date() } },
      { subscriptionEndsAt: { $lte: new Date() } }
    ]
  });
};

// Pre-save middleware
managerSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Manager', managerSchema);
