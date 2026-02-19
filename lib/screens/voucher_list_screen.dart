import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/voucher_model.dart';
import '../services/database_service.dart';
import '../widgets/glass_card.dart';

class VoucherListScreen extends StatefulWidget {
  const VoucherListScreen({super.key});

  @override
  State<VoucherListScreen> createState() => _VoucherListScreenState();
}

class _VoucherListScreenState extends State<VoucherListScreen> {
  List<VoucherModel> _vouchers = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() => _isLoading = true);
    
    String? status = _filterStatus == 'all' ? null : _filterStatus;
    final vouchers = await DatabaseService.instance.getVouchers(
      status: status,
      limit: 100,
    );
    
    setState(() {
      _vouchers = vouchers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('قائمة الكروت'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filterStatus = value);
              _loadVouchers();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('الكل'),
              ),
              const PopupMenuItem(
                value: 'active',
                child: Text('النشطة'),
              ),
              const PopupMenuItem(
                value: 'used',
                child: Text('المستخدمة'),
              ),
              const PopupMenuItem(
                value: 'expired',
                child: Text('المنتهية'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vouchers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 64,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد كروت',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vouchers.length,
                  itemBuilder: (context, index) {
                    final voucher = _vouchers[index];
                    return _buildVoucherCard(voucher);
                  },
                ),
    );
  }

  Widget _buildVoucherCard(VoucherModel voucher) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (voucher.status) {
      case 'active':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        statusText = 'نشط';
        break;
      case 'used':
        statusColor = AppTheme.accentColor;
        statusIcon = Icons.person;
        statusText = 'مستخدم';
        break;
      case 'expired':
        statusColor = AppTheme.textMuted;
        statusIcon = Icons.timer_off;
        statusText = 'منتهي';
        break;
      default:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.help;
        statusText = 'غير معروف';
    }

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                voucher.shelfId,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            voucher.code,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: 2,
            ),
          ),
          if (voucher.password != null) ...[
            const SizedBox(height: 4),
            Text(
              'كلمة المرور: ${voucher.password}',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.data_usage,
                size: 16,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${voucher.dataLimit}GB',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.timer,
                size: 16,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${voucher.timeLimit}س',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${voucher.validityDays} يوم',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
