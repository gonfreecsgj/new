import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/mikrotik_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class RouterConfigScreen extends StatefulWidget {
  const RouterConfigScreen({super.key});

  @override
  State<RouterConfigScreen> createState() => _RouterConfigScreenState();
}

class _RouterConfigScreenState extends State<RouterConfigScreen> {
  final _ipController = TextEditingController(text: '192.168.88.1');
  final _portController = TextEditingController(text: '8728');
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController();
  bool _isTesting = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    final authProvider = context.read<AuthProvider>();
    final router = authProvider.currentManager?.router;
    
    if (router != null) {
      _ipController.text = router.ip;
      _portController.text = router.port.toString();
      _usernameController.text = router.username;
      _passwordController.text = router.password;
    }
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);

    final mikrotikProvider = context.read<MikroTikProvider>();
    final success = await mikrotikProvider.testConnection(
      _ipController.text,
      int.tryParse(_portController.text) ?? 8728,
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isTesting = false);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Icon(
          success ? Icons.check_circle : Icons.error,
          color: success ? AppTheme.successColor : AppTheme.errorColor,
          size: 48,
        ),
        content: Text(
          success
              ? 'تم الاتصال بنجاح!'
              : 'فشل الاتصال: ${mikrotikProvider.error ?? 'تحقق من الإعدادات'}',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    
    await authProvider.updateRouterConfig(
      RouterConfig(
        ip: _ipController.text,
        port: int.tryParse(_portController.text) ?? 8728,
        username: _usernameController.text,
        password: _passwordController.text,
        isConnected: context.read<MikroTikProvider>().isConnected,
      ),
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الإعدادات'),
        backgroundColor: AppTheme.successColor,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mikrotikProvider = context.watch<MikroTikProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('إعدادات MikroTik'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mikrotikProvider.isConnected
                          ? AppTheme.successColor.withOpacity(0.2)
                          : AppTheme.errorColor.withOpacity(0.2),
                    ),
                    child: Icon(
                      mikrotikProvider.isConnected
                          ? Icons.check_circle
                          : Icons.router,
                      size: 40,
                      color: mikrotikProvider.isConnected
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    mikrotikProvider.isConnected
                        ? 'متصل'
                        : 'غير متصل',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mikrotikProvider.isConnected
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                  if (mikrotikProvider.isConnected) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_ipController.text}:${_portController.text}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Configuration form
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إعدادات الاتصال',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // IP Address
                  _buildTextField(
                    controller: _ipController,
                    label: 'عنوان IP',
                    hint: '192.168.88.1',
                    icon: Icons.computer,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Port
                  _buildTextField(
                    controller: _portController,
                    label: 'المنفذ (Port)',
                    hint: '8728',
                    icon: Icons.settings_ethernet,
                    keyboardType: TextInputType.number,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Username
                  _buildTextField(
                    controller: _usernameController,
                    label: 'اسم المستخدم',
                    hint: 'admin',
                    icon: Icons.person,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password
                  _buildTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    hint: '••••••••',
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Test button
            NeonButton(
              onPressed: _isTesting ? null : _testConnection,
              isLoading: _isTesting,
              isOutlined: true,
              child: const Text('اختبار الاتصال'),
            ),

            const SizedBox(height: 12),

            // Save button
            NeonButton(
              onPressed: _isSaving ? null : _saveConfig,
              isLoading: _isSaving,
              child: const Text('حفظ الإعدادات'),
            ),

            const SizedBox(height: 20),
          ],
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
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          style: TextStyle(
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textMuted,
            ),
            prefixIcon: Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
