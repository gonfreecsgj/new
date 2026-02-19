const crypto = require('crypto');

// Generate activation token
const generateToken = (managerId, months) => {
  const timestamp = Date.now();
  const randomBytes = crypto.randomBytes(4).toString('hex').toUpperCase();
  
  // Format: COGONA-MANAGERID-MONTHS-RANDOM
  const token = `COGONA-${managerId.substring(0, 8)}-${months.toString().padStart(2, '0')}-${randomBytes}`;
  
  return token;
};

// Validate token format
const validateToken = (token) => {
  const pattern = /^COGONA-[A-F0-9]{8}-\d{2}-[A-F0-9]{8}$/;
  return pattern.test(token);
};

// Parse token
const parseToken = (token) => {
  if (!validateToken(token)) {
    return null;
  }
  
  const parts = token.split('-');
  return {
    prefix: parts[0],
    managerId: parts[1],
    months: parseInt(parts[2]),
    random: parts[3]
  };
};

// Generate JWT for manager
const generateJWT = (manager) => {
  const jwt = require('jsonwebtoken');
  
  return jwt.sign(
    {
      id: manager._id,
      email: manager.email,
      googleId: manager.googleId
    },
    process.env.JWT_SECRET || 'cogona-secret-key',
    { expiresIn: '30d' }
  );
};

// Generate admin JWT
const generateAdminJWT = (email) => {
  const jwt = require('jsonwebtoken');
  
  return jwt.sign(
    { email, isAdmin: true },
    process.env.JWT_SECRET || 'cogona-secret-key',
    { expiresIn: '7d' }
  );
};

module.exports = {
  generateToken,
  validateToken,
  parseToken,
  generateJWT,
  generateAdminJWT
};
