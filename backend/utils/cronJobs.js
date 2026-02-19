const cron = require('node-cron');
const Manager = require('../models/Manager');
const { sendNotification } = require('./notifications');

const startCronJobs = () => {
  // Run every day at midnight
  cron.schedule('0 0 * * *', async () => {
    console.log('🔄 Running daily cron jobs...');
    
    try {
      // 1. Update expired subscriptions
      const expiredManagers = await Manager.findExpired();
      for (const manager of expiredManagers) {
        if (manager.status !== 'expired') {
          manager.status = 'expired';
          await manager.save();
          console.log(`📌 Marked manager ${manager.email} as expired`);
        }
      }
      
      // 2. Send notifications for expiring subscriptions (3 days before)
      const expiringSoon = await Manager.findExpiringSoon(3);
      for (const manager of expiringSoon) {
        // TODO: Send notification to manager
        console.log(`📧 Manager ${manager.email} subscription expires in ${manager.daysLeft} days`);
      }
      
      // 3. Update last activity for inactive managers
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
      await Manager.updateMany(
        { lastActivityAt: { $lt: thirtyDaysAgo }, status: 'active' },
        { $set: { status: 'inactive' } }
      );
      
      console.log('✅ Daily cron jobs completed');
    } catch (error) {
      console.error('❌ Cron job error:', error);
    }
  });
  
  // Run every hour for cleanup
  cron.schedule('0 * * * *', async () => {
    console.log('🧹 Running hourly cleanup...');
    
    try {
      // Cleanup old notifications or temp data
      console.log('✅ Hourly cleanup completed');
    } catch (error) {
      console.error('❌ Cleanup error:', error);
    }
  });
  
  console.log('⏰ Cron jobs scheduled');
};

module.exports = {
  startCronJobs
};
