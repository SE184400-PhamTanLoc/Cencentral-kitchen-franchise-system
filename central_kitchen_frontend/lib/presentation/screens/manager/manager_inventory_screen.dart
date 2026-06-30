import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../business/providers/manager_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../widgets/ingredient_image_helper.dart';

class ManagerInventoryScreen extends StatefulWidget {
  const ManagerInventoryScreen({super.key});

  @override
  State<ManagerInventoryScreen> createState() => _ManagerInventoryScreenState();
}

class _ManagerInventoryScreenState extends State<ManagerInventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().loadInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giám sát Tồn kho Chuỗi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: Consumer<ManagerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingInventory) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00236F)));
          }
          if (provider.errorMessage != null && provider.inventory.isEmpty) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}', style: const TextStyle(color: Color(0xFF64748B))));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.inventory.length,
            itemBuilder: (context, index) {
              final item = provider.inventory[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        buildIngredientPreview(
                          null,
                          item.ingredientName,
                          size: 40,
                          borderRadius: 12,
                          fallback: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00236F).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Color(0xFF00236F),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.ingredientName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStockItem('Bếp trung tâm', item.kitchenStock, item.unit, AppTheme.secondary),
                        _buildStockItem('Các cửa hàng', item.storeStock, item.unit, AppTheme.warning),
                        _buildStockItem('Tổng tồn kho', item.totalStock, item.unit, AppTheme.success),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStockItem(String label, double value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: Color(0xFF757682)),
        ),
        const SizedBox(height: 6),
        Text(
          '$value $unit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
        ),
      ],
    );
  }
}
