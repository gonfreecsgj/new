import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../models/voucher_model.dart';
import '../services/database_service.dart';
import '../providers/mikrotik_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import 'pdf_preview_screen.dart';

class VoucherGeneratorScreen extends StatefulWidget {
  const VoucherGeneratorScreen({super.key});

  @override
  State<VoucherGeneratorScreen> createState() => _VoucherGeneratorScreenState();
}

class _VoucherGeneratorScreenState extends State<VoucherGeneratorScreen> {
  final _countController = TextEditingController(text: '10');
  final _prefixController = TextEditingController();
  final _suffixController = TextEditingController();
  
  int _codeLength = 10;
  bool _useLetters = true;
  bool _useNumbers = true;
  bool _generatePassword = false;
  String? _selectedProfile;
  String? _selectedShelf;
  
  List<VoucherProfile> _profiles = [];
  List<ShelfModel> _shelves = [];
  bool _isLoading = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final profiles = await DatabaseService.instance.getProfiles();
    final shelves = await DatabaseService.instance.getShelves();
    
    setState(() {
      _profiles = profiles;
      _shelves = shelves;
      if (profiles.isNotEmpty) _selectedProfile = profiles.first.id;
      if (shelves.isNotEmpty) _selectedShelf = shelves.first.id;
      _isLoading = false;
    });
  }

  Future<void> _generateVouchers() async {
    if (_selectedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار الباقة'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final count = int.tryParse(_countController.text) ?? 10;
    if (count <= 0 || count > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عدد الكروت يجب أن يكون بين 1 و 1000'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final profile = _profiles.firstWhere((p) => p.id == _selectedProfile);
    
    final vouchers = VoucherGenerator.generateBatch(
      count: count,
      profile: profile.name,
      dataLimit: profile.dataLimit,
      timeLimit: profile.timeLimit,
      validityDays: profile.validityDays,
      shelfId: _selectedShelf ?? 'default',
      codeLength: _codeLength,
      generatePassword: _generatePassword,
      prefix: _prefixController.text.isEmpty ? null : _prefixController.text,
      suffix: _suffixController.text.isEmpty ? null : _suffixController.text,
    );

    // Save to database
    await DatabaseService.instance.saveVouchersBatch(vouchers);

    // Try to add to MikroTik if connected
    final mikrotikProvider = context.read<MikroTikProvider>();
    int addedToMikrotik = 0;
    
    if (mikrotikProvider.isConnected) {
      addedToMikrotik = await mikrotikProvider.createUsersBatch(vouchers);
    }

    setState(() => _isGenerating = false);

    if (!mounted) return;

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 8),
            const Text('تم الإنشاء بنجاح'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تم إنشاء ${vouchers.length} كرت'),
            if (addedToMikrotik > 0)
              Text('تم إضافة $addedToMikrotik إلى MikroTik'),
            const SizedBox(height: 16),
            const Text('هل تريد طباعة الكروت الآن؟'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          NeonButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PdfPreviewScreen(vouchers: vouchers),
                ),
              );
            },
            child: const Text('طباعة الآن'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('إنشاء كروت جديدة'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile selection
                  FadeInUp(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'اختر الباقة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _profiles.map((profile) {
                              final isSelected = _selectedProfile == profile.id;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedProfile = profile.id);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? AppTheme.neonGradient
                                        : null,
                                    color: isSelected
                                        ? null
                                        : AppTheme.surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : AppTheme.textMuted.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.black
                                              : AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${profile.dataLimit}GB - ${profile.timeLimit}س',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isSelected
                                              ? Colors.black.withOpacity(0.7)
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quantity
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.format_list_numbered,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'عدد الكروت',
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
                              IconButton(
                                onPressed: () {
                                  final current =
                                      int.tryParse(_countController.text) ?? 10;
                                  if (current > 1) {
                                    _countController.text = (current - 1).toString();
                                  }
                                },
                                icon: const Icon(Icons.remove_circle),
                                color: AppTheme.primaryColor,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _countController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppTheme.surfaceColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  final current =
                                      int.tryParse(_countController.text) ?? 10;
                                  if (current < 1000) {
                                    _countController.text = (current + 1).toString();
                                  }
                                },
                                icon: const Icon(Icons.add_circle),
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [10, 50, 100, 500].map((count) {
                              return ActionChip(
                                label: Text('$count'),
                                onPressed: () {
                                  _countController.text = count.toString();
                                },
                                backgroundColor: AppTheme.surfaceColor,
                                labelStyle: TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Code settings
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.password,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'إعدادات الكود',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Code length
                          Text(
                            'طول الكود: $_codeLength رقم/حرف',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Slider(
                            value: _codeLength.toDouble(),
                            min: 6,
                            max: 16,
                            divisions: 10,
                            label: _codeLength.toString(),
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              setState(() => _codeLength = value.toInt());
                            },
                          ),
                          
                          // Character types
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text(
                                    'أحرف',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  value: _useLetters,
                                  onChanged: (value) {
                                    setState(() => _useLetters = value ?? true);
                                  },
                                  activeColor: AppTheme.primaryColor,
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text(
                                    'أرقام',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  value: _useNumbers,
                                  onChanged: (value) {
                                    setState(() => _useNumbers = value ?? true);
                                  },
                                  activeColor: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          
                          // Password generation
                          CheckboxListTile(
                            title: Text(
                              'إنشاء كلمة مرور لكل كرت',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            value: _generatePassword,
                            onChanged: (value) {
                              setState(() => _generatePassword = value ?? false);
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                          
                          // Prefix/Suffix
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _prefixController,
                                  decoration: InputDecoration(
                                    labelText: 'بادئة (اختياري)',
                                    hintText: 'مثال: WIFI',
                                    labelStyle: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.surfaceColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _suffixController,
                                  decoration: InputDecoration(
                                    labelText: 'لاحقة (اختياري)',
                                    hintText: 'مثال: 2024',
                                    labelStyle: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.surfaceColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Shelf selection
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.layers,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'الرف',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedShelf,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            dropdownColor: AppTheme.cardColor,
                            style: TextStyle(color: AppTheme.textPrimary),
                            items: _shelves.map((shelf) {
                              return DropdownMenuItem(
                                value: shelf.id,
                                child: Text(shelf.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedShelf = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Generate button
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: NeonButton(
                      onPressed: _isGenerating ? null : _generateVouchers,
                      isLoading: _isGenerating,
                      child: const Text(
                        'إنشاء الكروت',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
