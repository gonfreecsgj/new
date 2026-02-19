const jwt = require('jsonwebtoken');
const Manager = require('../models/Manager');

// Manager Authentication
const managerAuth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ success: false, error: 'Access denied. No token provided.' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'cogona-secret-key');
    const manager = await Manager.findById(decoded.id);
    
    if (!manager) {
      return res.status(401).json({ success: false, error: 'Manager not found' });
    }

    if (manager.status === 'suspended') {
      return res.status(403).json({ success: false, error: 'Account suspended' });
    }

    req.manager = manager;
    req.token = token;
    next();
  } catch (error) {
    res.status(401).json({ success: false, error: 'Invalid token' });
  }
};

// Admin Authentication
const adminAuth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ success: false, error: 'Access denied' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'cogona-secret-key');
    
    // Check if admin email
    if (decoded.email !== 'alshamytlal702@gmail.com') {
      return res.status(403).json({ success: false, error: 'Admin access required' });
    }

    req.admin = decoded;
    next();
  } catch (error) {
    res.status(401).json({ success: false, error: 'Invalid token' });
  }
};

// Optional Authentication (for public routes)
const optionalAuth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (token) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'cogona-secret-key');
      const manager = await Manager.findById(decoded.id);
      req.manager = manager;
    }
    
    next();
  } catch (error) {
    next();
  }
};

module.exports = {
  managerAuth,
  adminAuth,
  optionalAuth
};
