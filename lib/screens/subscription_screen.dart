import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import 'home_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  bool _showTokenInput = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _activateSubscription() async {
    if (_tokenController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.activateSubscription(
      _tokenController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تفعيل الاشتراك بنجاح!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'رمز التفعيل غير صالح'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final authProvider = context.watch<AuthProvider>();
    final manager = authProvider.currentManager;
    final daysLeft = manager?.daysLeft ?? 0;
    final isTrial = manager?.status == 'trial';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.surfaceColor,
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Status indicator
                FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isTrial 
                          ? AppTheme.warningColor.withOpacity(0.2)
                          : AppTheme.errorColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isTrial ? AppTheme.warningColor : AppTheme.errorColor,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTrial ? Icons.access_time : Icons.lock,
                          color: isTrial ? AppTheme.warningColor : AppTheme.errorColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isTrial 
                              ? 'التجربة المجانية - $daysLeft يوم متبقي'
                              : 'الاشتراك منتهي',
                          style: TextStyle(
                            color: isTrial ? AppTheme.warningColor : AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Title
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'اختر خطتك',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'كروت غير محدودة - دعم فني - تحديثات مجانية',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Pricing cards
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      _buildPricingCard(
                        title: 'الاشتراك الشهري',
                        price: '\$5',
                        period: '/شهر',
                        features: [
                          'كروت غير محدودة',
                          'إدارة الموزعين',
                          'تقارير مفصلة',
                          'دعم فني 24/7',
                        ],
                        isPopular: true,
                        onSelect: () {
                          setState(() => _showTokenInput = true);
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildPricingCard(
                        title: 'الاشتراك السنوي',
                        price: '\$50',
                        period: '/سنة',
                        features: [
                          'وفر \$10',
                          'كل مميزات الشهري',
                          'أولوية في الدعم',
                          'نسخ احتياطي سحابي',
                        ],
                        isPopular: false,
                        onSelect: () {
                          setState(() => _showTokenInput = true);
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Token input section
                if (_showTokenInput)
                  FadeInUp(
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'أدخل رمز التفعيل',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تواصل معنا للحصول على الرمز',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _tokenController,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                            decoration: InputDecoration(
                              hintText: 'COGONA-XXXX-XX',
                              hintStyle: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 16,
                              ),
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          NeonButton(
                            onPressed: _isLoading ? null : _activateSubscription,
                            isLoading: _isLoading,
                            child: const Text('تفعيل الاشتراك'),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 30),
                
                // Contact info
                FadeIn(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'للاشتراك أو الاستفسار',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildContactButton(
                              icon: Icons.phone,
                              label: 'واتساب',
                              value: '+967 734 394 867',
                              color: const Color(0xFF25D366),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'alshamytlal702@gmail.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPopular 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.2),
                    AppTheme.secondaryColor.withOpacity(0.2),
                  ],
                )
              : null,
          color: isPopular ? null : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPopular ? AppTheme.primaryColor : AppTheme.textMuted.withOpacity(0.3),
            width: isPopular ? 2 : 1,
          ),
          boxShadow: isPopular ? AppTheme.neonShadow(AppTheme.primaryColor) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'الأكثر شيوعاً',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isPopular ? AppTheme.primaryColor : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPopular ? AppTheme.primaryColor : AppTheme.surfaceColor,
                  foregroundColor: isPopular ? Colors.black : AppTheme.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('اختر هذه الخطة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
