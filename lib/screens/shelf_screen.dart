import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/voucher_model.dart';
import '../services/database_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class ShelfScreen extends StatefulWidget {
  const ShelfScreen({super.key});

  @override
  State<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends State<ShelfScreen> {
  List<ShelfModel> _shelves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShelves();
  }

  Future<void> _loadShelves() async {
    final shelves = await DatabaseService.instance.getShelves();
    
    // Get voucher count for each shelf
    for (var shelf in shelves) {
      final count = await DatabaseService.instance.getVoucherCount(
        shelfId: shelf.id,
      );
      shelf = shelf.copyWith(voucherCount: count);
    }
    
    setState(() {
      _shelves = shelves;
      _isLoading = false;
    });
  }

  Future<void> _addShelf() async {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('إضافة رف جديد'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'اسم الرف',
            hintText: 'مثال: بقالة أحمد',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          NeonButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final shelf = ShelfModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: controller.text,
                );
                await DatabaseService.instance.saveShelf(shelf);
                Navigator.pop(context);
                _loadShelves();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('إدارة الأرفف'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shelves.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.layers_outlined,
                        size: 64,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد أرفف',
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
                  itemCount: _shelves.length,
                  itemBuilder: (context, index) {
                    final shelf = _shelves[index];
                    return _buildShelfCard(shelf);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addShelf,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShelfCard(ShelfModel shelf) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.neonGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.layers,
              color: Colors.black,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shelf.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${shelf.voucherCount} كرت',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              // Show shelf details
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
