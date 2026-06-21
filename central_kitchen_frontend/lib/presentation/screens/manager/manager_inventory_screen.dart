import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../business/providers/manager_provider.dart';

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
        title: const Text('Giám sát Tồn kho Chuỗi'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      backgroundColor: const Color(0xFFF4F7FC),
      body: Consumer<ManagerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingInventory) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.inventory.isEmpty) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.inventory.length,
            itemBuilder: (context, index) {
              final item = provider.inventory[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.ingredientName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStockItem('Bếp trung tâm', item.kitchenStock, item.unit, Colors.blue),
                          _buildStockItem('Các cửa hàng', item.storeStock, item.unit, Colors.orange),
                          _buildStockItem('Tổng tồn kho', item.totalStock, item.unit, Colors.green),
                        ],
                      )
                    ],
                  ),
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
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '$value $unit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
        ),
      ],
    );
  }
}
