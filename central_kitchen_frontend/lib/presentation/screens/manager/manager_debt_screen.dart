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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cập nhật hạn mức công nợ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Hạn mức mới (VNĐ)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00236F), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00236F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
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
        title: const Text('Quản lý Công nợ', style: TextStyle(fontWeight: FontWeight.bold)),
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
          if (provider.isLoadingStores) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00236F)));
          }
          if (provider.errorMessage != null && provider.stores.isEmpty) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}', style: const TextStyle(color: Color(0xFF64748B))));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.stores.length,
            itemBuilder: (context, index) {
              final store = provider.stores[index];
              final debtRatio = store.creditLimit > 0 ? (store.currentDebt / store.creditLimit) : 0.0;
              final color = debtRatio > 0.8 ? const Color(0xFFEF4444) : (debtRatio > 0.5 ? const Color(0xFFF59E0B) : const Color(0xFF10B981));
              final bgTint = debtRatio > 0.8 ? const Color(0xFFFEF2F2) : (debtRatio > 0.5 ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5));

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            store.storeName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                          ),
                        ),
                        InkWell(
                          onTap: () => _showUpdateLimitDialog(store.storeId, store.creditLimit),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit_outlined, color: Color(0xFF64748B), size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('NỢ HIỆN TẠI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: Color(0xFF757682))),
                              const SizedBox(height: 4),
                              Text(formatCurrency.format(store.currentDebt), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('HẠN MỨC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: Color(0xFF757682))),
                              const SizedBox(height: 4),
                              Text(formatCurrency.format(store.creditLimit), style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 15)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: debtRatio.clamp(0.0, 1.0).toDouble(),
                        color: color,
                        backgroundColor: bgTint,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
