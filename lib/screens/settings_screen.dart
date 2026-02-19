import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';
import 'subscription_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final manager = authProvider.currentManager;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile card
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.neonGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    manager?.name ?? 'مدير الشبكة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    manager?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: manager?.isActive == true
                          ? AppTheme.successColor.withOpacity(0.2)
                          : AppTheme.warningColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      manager?.isActive == true
                          ? 'اشتراك نشط'
                          : 'تجربة مجانية',
                      style: TextStyle(
                        color: manager?.isActive == true
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Subscription section
            _buildSectionTitle('الاشتراك'),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.card_membership,
                    title: 'تجديد الاشتراك',
                    subtitle: '${manager?.daysLeft ?? 0} يوم متبقي',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(color: AppTheme.textMuted.withOpacity(0.2)),
                  _buildSettingItem(
                    icon: Icons.history,
                    title: 'سجل المدفوعات',
                    subtitle: 'عرض جميع المدفوعات السابقة',
                    onTap: () {
                      // TODO: Show payment history
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App settings
            _buildSectionTitle('إعدادات التطبيق'),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.language,
                    title: 'اللغة',
                    subtitle: 'العربية',
                    onTap: () {
                      // TODO: Change language
                    },
                  ),
                  Divider(color: AppTheme.textMuted.withOpacity(0.2)),
                  _buildSettingItem(
                    icon: Icons.notifications,
                    title: 'الإشعارات',
                    subtitle: 'مفعلة',
                    onTap: () {
                      // TODO: Notification settings
                    },
                  ),
                  Divider(color: AppTheme.textMuted.withOpacity(0.2)),
                  _buildSettingItem(
                    icon: Icons.backup,
                    title: 'النسخ الاحتياطي',
                    subtitle: 'آخر نسخة: اليوم',
                    onTap: () {
                      // TODO: Backup settings
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Support
            _buildSectionTitle('الدعم'),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.help,
                    title: 'مركز المساعدة',
                    subtitle: 'أسئلة شائعة ودروس',
                    onTap: () {
                      // TODO: Help center
                    },
                  ),
                  Divider(color: AppTheme.textMuted.withOpacity(0.2)),
                  _buildSettingItem(
                    icon: Icons.phone,
                    title: 'تواصل معنا',
                    subtitle: '+967 734 394 867',
                    onTap: () {
                      // TODO: Open WhatsApp
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About
            _buildSectionTitle('حول التطبيق'),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.info,
                    title: 'عن Cogona Net',
                    subtitle: 'الإصدار 1.0.0',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Cogona Net',
                        applicationVersion: '1.0.0',
                        applicationIcon: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppTheme.neonGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.wifi_tethering,
                            color: Colors.black,
                          ),
                        ),
                        applicationLegalese: '© 2024 محمد طلال\nجميع الحقوق محفوظة',
                      );
                    },
                  ),
                  Divider(color: AppTheme.textMuted.withOpacity(0.2)),
                  _buildSettingItem(
                    icon: Icons.privacy_tip,
                    title: 'سياسة الخصوصية',
                    subtitle: 'قراءة سياسة الخصوصية',
                    onTap: () {
                      // TODO: Privacy policy
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout button
            ElevatedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل الخروج'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor.withOpacity(0.2),
                foregroundColor: AppTheme.errorColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppTheme.textMuted,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
