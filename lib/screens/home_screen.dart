import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import 'voucher_generator_screen.dart';
import 'voucher_list_screen.dart';
import 'shelf_screen.dart';
import 'router_config_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await DatabaseService.instance.getStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _refreshStats() async {
    setState(() => _isLoading = true);
    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final manager = authProvider.currentManager;
    final daysLeft = manager?.daysLeft ?? 0;

    final screens = [
      _buildDashboard(),
      const VoucherListScreen(),
      const ShelfScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textMuted,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_outlined),
                activeIcon: Icon(Icons.confirmation_number),
                label: 'الكروت',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.layers_outlined),
                activeIcon: Icon(Icons.layers),
                label: 'الأرفف',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'الإعدادات',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const VoucherGeneratorScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text('كرت جديد'),
            )
          : null,
    );
  }

  Widget _buildDashboard() {
    final authProvider = context.watch<AuthProvider>();
    final manager = authProvider.currentManager;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return RefreshIndicator(
      onRefresh: _refreshStats,
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.surfaceColor,
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor.withOpacity(0.9),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'COGONA NET',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RouterConfigScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.router,
                  color: manager?.router?.isConnected == true
                      ? AppTheme.successColor
                      : AppTheme.textMuted,
                ),
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome section
                FadeInDown(
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: AppTheme.neonGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'أهلاً، ${manager?.name ?? 'مدير الشبكة'}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    manager?.email ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: manager?.isActive == true
                                ? AppTheme.successColor.withOpacity(0.2)
                                : AppTheme.warningColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: manager?.isActive == true
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                manager?.isActive == true
                                    ? Icons.check_circle
                                    : Icons.access_time,
                                size: 16,
                                color: manager?.isActive == true
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                manager?.isActive == true
                                    ? 'نشط - $daysLeft يوم'
                                    : 'تجربة - $daysLeft يوم',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: manager?.isActive == true
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Quick stats
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.confirmation_number,
                          value: _stats['totalVouchers']?.toString() ?? '0',
                          label: 'إجمالي الكروت',
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle,
                          value: _stats['activeVouchers']?.toString() ?? '0',
                          label: 'الكروت النشطة',
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.people,
                          value: _stats['usedVouchers']?.toString() ?? '0',
                          label: 'الكروت المستخدمة',
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.timer_off,
                          value: _stats['expiredVouchers']?.toString() ?? '0',
                          label: 'المنتهية',
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick actions
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'إجراءات سريعة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildQuickAction(
                        icon: Icons.add_circle,
                        label: 'إنشاء كروت',
                        color: AppTheme.primaryColor,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VoucherGeneratorScreen(),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.print,
                        label: 'طباعة الكروت',
                        color: AppTheme.successColor,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VoucherListScreen(),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.layers,
                        label: 'إدارة الأرفف',
                        color: AppTheme.secondaryColor,
                        onTap: () {
                          setState(() => _selectedIndex = 2);
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.people,
                        label: 'الموزعين',
                        color: AppTheme.accentColor,
                        onTap: () {
                          // TODO: Navigate to resellers
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Router status
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.router,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'حالة MikroTik',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: manager?.router?.isConnected == true
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: (manager?.router?.isConnected == true
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor)
                                        .withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              manager?.router?.isConnected == true
                                  ? 'متصل - ${manager?.router?.ip}'
                                  : 'غير متصل',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (manager?.router?.isConnected != true) ...[
                          const SizedBox(height: 12),
                          NeonButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RouterConfigScreen(),
                                ),
                              );
                            },
                            child: const Text('إعدادات الاتصال'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 56) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
