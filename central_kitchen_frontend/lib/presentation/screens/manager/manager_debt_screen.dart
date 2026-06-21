import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../business/providers/manager_provider.dart';

class ManagerDebtScreen extends StatefulWidget {
  const ManagerDebtScreen({super.key});

  @override
  State<ManagerDebtScreen> createState() => _ManagerDebtScreenState();
}

class _ManagerDebtScreenState extends State<ManagerDebtScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().loadStores();
    });
  }

  void _showUpdateLimitDialog(int storeId, double currentLimit) {
    final ctrl = TextEditingController(text: currentLimit.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật hạn mức công nợ'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Hạn mức mới (VNĐ)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final newLimit = double.tryParse(ctrl.text);
              if (newLimit != null) {
                final success = await context.read<ManagerProvider>().updateCreditLimit(storeId, newLimit);
                if (mounted) {
                  Navigator.pop(ctx);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại')));
                  }
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Công nợ'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      backgroundColor: const Color(0xFFF4F7FC),
      body: Consumer<ManagerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingStores) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.stores.isEmpty) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.stores.length,
            itemBuilder: (context, index) {
              final store = provider.stores[index];
              final debtRatio = store.creditLimit > 0 ? (store.currentDebt / store.creditLimit) : 0.0;
              final color = debtRatio > 0.8 ? Colors.red : (debtRatio > 0.5 ? Colors.orange : Colors.green);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            store.storeName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showUpdateLimitDialog(store.storeId, store.creditLimit),
                          ),
                        ],
                      ),
                      Text('Nợ hiện tại: ${formatCurrency.format(store.currentDebt)}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Hạn mức: ${formatCurrency.format(store.creditLimit)}'),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: debtRatio.clamp(0.0, 1.0).toDouble(),
                        color: color,
                        backgroundColor: Colors.grey[200],
                      ),
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
}
