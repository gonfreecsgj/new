import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import 'home_screen.dart';
import 'subscription_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    
    // Simulate Google Sign In for now
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      googleId: 'google_${_emailController.text.trim()}',
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      final manager = authProvider.currentManager;
      
      if (manager != null && manager.isActive) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'حدث خطأ'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.surfaceColor.withOpacity(0.5),
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
                const SizedBox(height: 40),
                
                // Logo
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: isSmallScreen ? 80 : 100,
                    height: isSmallScreen ? 80 : 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.neonGradient,
                      boxShadow: AppTheme.neonShadow(AppTheme.primaryColor),
                    ),
                    child: const Icon(
                      Icons.wifi_tethering_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Title
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return AppTheme.neonGradient.createShader(bounds);
                    },
                    child: Text(
                      'COGONA NET',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'نظام إدارة شبكات MikroTik المتكامل',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Form Card
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isRegistering ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            _isRegistering 
                                ? 'أدخل بياناتك لبدء التجربة المجانية'
                                : 'أدخل بريدك الإلكتروني للمتابعة',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Name field (only for registration)
                          if (_isRegistering) ...[
                            _buildTextField(
                              controller: _nameController,
                              label: 'الاسم الكامل',
                              hint: 'محمد أحمد',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال الاسم';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Email field
                          _buildTextField(
                            controller: _emailController,
                            label: 'البريد الإلكتروني',
                            hint: 'example@gmail.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال البريد الإلكتروني';
                              }
                              if (!value.contains('@')) {
                                return 'بريد إلكتروني غير صالح';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Submit button
                          NeonButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            isLoading: _isLoading,
                            child: Text(
                              _isRegistering ? 'إنشاء حساب' : 'تسجيل الدخول',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Toggle register/login
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isRegistering = !_isRegistering;
                              });
                            },
                            child: Text(
                              _isRegistering 
                                  ? 'لديك حساب؟ سجل الدخول'
                                  : 'ليس لديك حساب؟ سجل الآن',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Features list
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureChip(Icons.wifi, 'ربط MikroTik'),
                      _buildFeatureChip(Icons.print, 'طباعة الكروت'),
                      _buildFeatureChip(Icons.people, 'إدارة الموزعين'),
                      _buildFeatureChip(Icons.analytics, 'تقارير ذكية'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Contact info
                FadeIn(
                  delay: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      Text(
                        'للدعم الفني',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+967 734 394 867',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.errorColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
