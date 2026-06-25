import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../business/providers/manager_catalog_provider.dart';
import '../../../data/models/ingredient_model.dart';
import 'manager_bom_screen.dart';

class ManagerCategoryScreen extends StatefulWidget {
  const ManagerCategoryScreen({super.key});

  @override
  State<ManagerCategoryScreen> createState() => _ManagerCategoryScreenState();
}

class _ManagerCategoryScreenState extends State<ManagerCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerCatalogProvider>().loadCatalogData();
    });
  }

  void _showIngredientForm({IngredientModel? ingredient}) {
    final isEditing = ingredient != null;
    final nameCtrl = TextEditingController(text: ingredient?.name);
    final skuCtrl = TextEditingController(text: ingredient?.sku);
    final unitCtrl = TextEditingController(text: ingredient?.unit);
    final priceCtrl = TextEditingController(text: ingredient?.unitPrice.toString() ?? '0');
    final minStockCtrl = TextEditingController(text: ingredient?.minStockLevel.toString() ?? '0');
    bool isRawMaterial = ingredient?.isRawMaterial ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Sửa Danh mục' : 'Thêm Danh mục'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên nguyên liệu / SP')),
                  const SizedBox(height: 16),
                  TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'Mã SKU')),
                  const SizedBox(height: 16),
                  TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Đơn vị tính (kg, lít, cái)')),
                  const SizedBox(height: 16),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Đơn giá'), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  TextField(controller: minStockCtrl, decoration: const InputDecoration(labelText: 'Tồn kho tối thiểu'), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Là nguyên liệu thô?'),
                    value: isRawMaterial,
                    onChanged: (val) => setState(() => isRawMaterial = val),
                    contentPadding: EdgeInsets.zero,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () async {
                  final provider = context.read<ManagerCatalogProvider>();
                  final body = {
                    'name': nameCtrl.text,
                    'sku': skuCtrl.text,
                    'unit': unitCtrl.text,
                    'unitPrice': double.tryParse(priceCtrl.text) ?? 0,
                    'minStockLevel': double.tryParse(minStockCtrl.text) ?? 0,
                    'isRawMaterial': isRawMaterial,
                  };

                  try {
                    if (isEditing) {
                      await provider.updateIngredient(ingredient.ingredientId, body);
                    } else {
                      await provider.createIngredient(body);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                    }
                  }
                },
                child: const Text('Lưu'),
              )
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Danh mục & BOM', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showIngredientForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm mới'),
        backgroundColor: const Color(0xFF00236F),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ManagerCatalogProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text('Lỗi: ${provider.errorMessage}'));
          }

          final ingredients = provider.ingredients;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final item = ingredients[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      if (!item.isRawMaterial)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.hasRecipe ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.hasRecipe ? 'Đã có BOM' : 'Chưa có BOM',
                            style: TextStyle(
                              color: item.hasRecipe ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('SKU: ${item.sku} | ĐVT: ${item.unit}'),
                      Text('Giá: ${formatCurrency.format(item.unitPrice)}'),
                      Text('Phân loại: ${item.isRawMaterial ? "Nguyên liệu thô" : "Bán thành phẩm"}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (val) async {
                      if (val == 'edit') {
                        _showIngredientForm(ingredient: item);
                      } else if (val == 'delete') {
                        await provider.deleteIngredient(item.ingredientId);
                      } else if (val == 'bom') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManagerBomScreen(ingredient: item),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      if (!item.isRawMaterial)
                        const PopupMenuItem(value: 'bom', child: Text('Cấu hình BOM')),
                      const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                      const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
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
