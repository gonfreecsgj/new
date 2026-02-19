const mongoose = require('mongoose');

const rechargeSchema = new mongoose.Schema({
  // Voucher being recharged
  voucherId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Voucher',
    required: true,
    index: true
  },
  
  // Reseller who performed the recharge
  resellerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Reseller',
    required: true,
    index: true
  },
  
  // Manager (for quick lookup)
  managerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Manager',
    required: true,
    index: true
  },
  
  // Customer Info
  customerPhone: String,
  customerName: String,
  
  // Financial Details
  amount: { // Amount paid by customer
    type: Number,
    required: true
  },
  dataAdded: { // Data added to voucher (in GB)
    type: Number,
    required: true
  },
  commission: { // Commission earned by reseller
    type: Number,
    required: true
  },
  systemFee: { // Fee for the system (you)
    type: Number,
    default: 0
  },
  
  // Payment Method
  paymentMethod: {
    type: String,
    enum: ['cash', 'transfer', 'mobile_money'],
    default: 'cash'
  },
  
  // Status
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'refunded'],
    default: 'completed'
  },
  
  // Notes
  notes: String,
  
  // Meta
  createdAt: { type: Date, default: Date.now }
});

// Indexes
rechargeSchema.index({ resellerId: 1, createdAt: -1 });
rechargeSchema.index({ managerId: 1, createdAt: -1 });
rechargeSchema.index({ createdAt: -1 });

// Virtuals
rechargeSchema.virtual('netAmount').get(function() {
  return this.amount - this.commission - this.systemFee;
});

// Statics
rechargeSchema.statics.getStats = async function(managerId, period = 'month') {
  const now = new Date();
  let startDate;
  
  switch(period) {
    case 'day':
      startDate = new Date(now.setHours(0, 0, 0, 0));
      break;
    case 'week':
      startDate = new Date(now.setDate(now.getDate() - 7));
      break;
    case 'month':
      startDate = new Date(now.setMonth(now.getMonth() - 1));
      break;
    case 'year':
      startDate = new Date(now.setFullYear(now.getFullYear() - 1));
      break;
    default:
      startDate = new Date(0);
  }
  
  const stats = await this.aggregate([
    {
      $match: {
        managerId: new mongoose.Types.ObjectId(managerId),
        createdAt: { $gte: startDate },
        status: 'completed'
      }
    },
    {
      $group: {
        _id: null,
        totalRecharges: { $sum: 1 },
        totalAmount: { $sum: '$amount' },
        totalCommission: { $sum: '$commission' },
        totalSystemFee: { $sum: '$systemFee' }
      }
    }
  ]);
  
  return stats[0] || {
    totalRecharges: 0,
    totalAmount: 0,
    totalCommission: 0,
    totalSystemFee: 0
  };
};

rechargeSchema.statics.getResellerStats = async function(resellerId) {
  const stats = await this.aggregate([
    {
      $match: {
        resellerId: new mongoose.Types.ObjectId(resellerId),
        status: 'completed'
      }
    },
    {
      $group: {
        _id: null,
        totalRecharges: { $sum: 1 },
        totalAmount: { $sum: '$amount' },
        totalCommission: { $sum: '$commission' }
      }
    }
  ]);
  
  return stats[0] || {
    totalRecharges: 0,
    totalAmount: 0,
    totalCommission: 0
  };
};

module.exports = mongoose.model('Recharge', rechargeSchema);
