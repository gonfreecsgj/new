const express = require('express');
const router = express.Router();
const Manager = require('../models/Manager');
const Voucher = require('../models/Voucher');
const Reseller = require('../models/Reseller');
const Recharge = require('../models/Recharge');
const { adminAuth } = require('../middleware/auth');
const { generateToken } = require('../utils/tokens');

// Apply admin auth to all routes
router.use(adminAuth);

// ==================== DASHBOARD STATS ====================

// GET /api/admin/dashboard
router.get('/dashboard', async (req, res) => {
  try {
    const [
      totalManagers,
      activeManagers,
      trialManagers,
      expiredManagers,
      totalVouchers,
      totalResellers,
      recentManagers,
      expiringSoon
    ] = await Promise.all([
      Manager.countDocuments(),
      Manager.countDocuments({ status: 'active' }),
      Manager.countDocuments({ status: 'trial' }),
      Manager.countDocuments({ status: 'expired' }),
      Voucher.countDocuments(),
      Reseller.countDocuments(),
      Manager.find().sort({ createdAt: -1 }).limit(5).select('name email status createdAt'),
      Manager.findExpiringSoon(3)
    ]);

    // Calculate revenue
    const revenueStats = await Manager.aggregate([
      { $unwind: '$payments' },
      { $match: { 'payments.status': 'completed' } },
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: '$payments.amount' },
          totalPayments: { $sum: 1 }
        }
      }
    ]);

    res.json({
      success: true,
      data: {
        stats: {
          totalManagers,
          activeManagers,
          trialManagers,
          expiredManagers,
          totalVouchers,
          totalResellers,
          totalRevenue: revenueStats[0]?.totalRevenue || 0,
          totalPayments: revenueStats[0]?.totalPayments || 0
        },
        recentManagers,
        expiringSoonCount: expiringSoon.length,
        expiringSoon: expiringSoon.map(m => ({
          id: m._id,
          name: m.name,
          email: m.email,
          daysLeft: m.daysLeft,
          status: m.status
        }))
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== MANAGER MANAGEMENT ====================

// GET /api/admin/managers
router.get('/managers', async (req, res) => {
  try {
    const { status, search, page = 1, limit = 20 } = req.query;
    
    const query = {};
    if (status) query.status = status;
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }

    const managers = await Manager.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .select('-router.password');

    const total = await Manager.countDocuments(query);

    res.json({
      success: true,
      data: managers,
      pagination: {
        page: parseInt(page),
        pages: Math.ceil(total / limit),
        total
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/admin/managers/:id
router.get('/managers/:id', async (req, res) => {
  try {
    const manager = await Manager.findById(req.params.id)
      .select('-router.password');
    
    if (!manager) {
      return res.status(404).json({ success: false, error: 'Manager not found' });
    }

    // Get voucher stats
    const voucherStats = await Voucher.getStats(manager._id);
    
    // Get reseller count
    const resellerCount = await Reseller.countDocuments({ managerId: manager._id });
    
    // Get recharge stats
    const rechargeStats = await Recharge.getStats(manager._id, 'month');

    res.json({
      success: true,
      data: {
        ...manager.toObject(),
        voucherStats,
        resellerCount,
        rechargeStats
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/admin/managers/:id/activate
router.post('/managers/:id/activate', async (req, res) => {
  try {
    const { months = 1, amount = 5, notes = '' } = req.body;
    const manager = await Manager.findById(req.params.id);
    
    if (!manager) {
      return res.status(404).json({ success: false, error: 'Manager not found' });
    }

    // Extend subscription
    await manager.extendSubscription(parseInt(months));
    
    // Add payment record
    await manager.addPayment({
      amount: parseFloat(amount),
      months: parseInt(months),
      method: 'manual',
      status: 'completed',
      notes: notes || `Activated by admin for ${months} month(s)`
    });

    res.json({
      success: true,
      message: `Subscription activated for ${months} month(s)`,
      data: {
        id: manager._id,
        name: manager.name,
        status: manager.status,
        subscriptionEndsAt: manager.subscriptionEndsAt,
        daysLeft: manager.daysLeft
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/admin/managers/:id/suspend
router.post('/managers/:id/suspend', async (req, res) => {
  try {
    const { reason = '' } = req.body;
    const manager = await Manager.findById(req.params.id);
    
    if (!manager) {
      return res.status(404).json({ success: false, error: 'Manager not found' });
    }

    manager.status = 'suspended';
    await manager.save();

    res.json({
      success: true,
      message: 'Manager suspended successfully',
      data: {
        id: manager._id,
        name: manager.name,
        status: manager.status
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// DELETE /api/admin/managers/:id
router.delete('/managers/:id', async (req, res) => {
  try {
    const manager = await Manager.findById(req.params.id);
    
    if (!manager) {
      return res.status(404).json({ success: false, error: 'Manager not found' });
    }

    // Delete related data
    await Promise.all([
      Voucher.deleteMany({ managerId: manager._id }),
      Reseller.deleteMany({ managerId: manager._id }),
      Recharge.deleteMany({ managerId: manager._id }),
      Manager.findByIdAndDelete(manager._id)
    ]);

    res.json({
      success: true,
      message: 'Manager and all related data deleted successfully'
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== TOKEN GENERATION ====================

// POST /api/admin/generate-token
router.post('/generate-token', async (req, res) => {
  try {
    const { managerId, months = 1 } = req.body;
    
    const manager = await Manager.findById(managerId);
    if (!manager) {
      return res.status(404).json({ success: false, error: 'Manager not found' });
    }

    const token = generateToken(managerId, months);

    res.json({
      success: true,
      data: {
        token,
        managerId,
        months,
        expiresIn: '30 days'
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== REVENUE STATS ====================

// GET /api/admin/revenue
router.get('/revenue', async (req, res) => {
  try {
    const { period = 'month' } = req.query;
    
    const now = new Date();
    let startDate;
    let groupBy;
    
    switch(period) {
      case 'day':
        startDate = new Date(now.setDate(now.getDate() - 30));
        groupBy = { $dateToString: { format: '%Y-%m-%d', date: '$payments.createdAt' } };
        break;
      case 'week':
        startDate = new Date(now.setDate(now.getDate() - 84));
        groupBy = { $week: '$payments.createdAt' };
        break;
      case 'month':
        startDate = new Date(now.setMonth(now.getMonth() - 12));
        groupBy = { $dateToString: { format: '%Y-%m', date: '$payments.createdAt' } };
        break;
      case 'year':
        startDate = new Date(now.setFullYear(now.getFullYear() - 5));
        groupBy = { $year: '$payments.createdAt' };
        break;
      default:
        startDate = new Date(0);
        groupBy = { $dateToString: { format: '%Y-%m', date: '$payments.createdAt' } };
    }

    const revenue = await Manager.aggregate([
      { $unwind: '$payments' },
      {
        $match: {
          'payments.status': 'completed',
          'payments.createdAt': { $gte: startDate }
        }
      },
      {
        $group: {
          _id: groupBy,
          amount: { $sum: '$payments.amount' },
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    res.json({
      success: true,
      data: revenue
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== NOTIFICATIONS ====================

// GET /api/admin/notifications
router.get('/notifications', async (req, res) => {
  try {
    const notifications = [];
    
    // Expiring subscriptions
    const expiringSoon = await Manager.findExpiringSoon(3);
    expiringSoon.forEach(manager => {
      notifications.push({
        type: 'expiring',
        priority: 'high',
        title: 'اشتراك أوشك على الانتهاء',
        message: `${manager.name} - ${manager.daysLeft} يوم متبقي`,
        managerId: manager._id,
        createdAt: new Date()
      });
    });
    
    // Expired subscriptions
    const expired = await Manager.findExpired();
    expired.forEach(manager => {
      notifications.push({
        type: 'expired',
        priority: 'urgent',
        title: 'اشتراك منتهي',
        message: `${manager.name} - انتهى الاشتراك`,
        managerId: manager._id,
        createdAt: new Date()
      });
    });

    res.json({
      success: true,
      data: notifications.sort((a, b) => b.priority.localeCompare(a.priority))
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
