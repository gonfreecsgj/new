const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const managerRoutes = require('./routes/managers');
const adminRoutes = require('./routes/admin');
const voucherRoutes = require('./routes/vouchers');
const resellerRoutes = require('./routes/resellers');
const rechargeRoutes = require('./routes/recharges');
const statsRoutes = require('./routes/stats');

const { errorHandler } = require('./middleware/errorHandler');
const { requestLogger } = require('./utils/logger');
const { startCronJobs } = require('./utils/cronJobs');

const app = express();

// Security middleware
app.use(helmet());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});
app.use(limiter);

// CORS
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true
}));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use(requestLogger);

// Database connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/cogona_net', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ Connected to MongoDB'))
.catch(err => console.error('❌ MongoDB connection error:', err));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/managers', managerRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/vouchers', voucherRoutes);
app.use('/api/resellers', resellerRoutes);
app.use('/api/recharges', rechargeRoutes);
app.use('/api/stats', statsRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Error handling
app.use(errorHandler);

// Start cron jobs
startCronJobs();

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Admin Dashboard: http://localhost:${PORT}/admin`);
});

module.exports = app;
