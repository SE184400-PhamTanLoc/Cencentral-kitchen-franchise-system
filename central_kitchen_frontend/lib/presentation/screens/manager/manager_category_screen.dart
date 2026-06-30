import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../business/providers/manager_catalog_provider.dart';
import '../../../data/models/ingredient_model.dart';
import '../../widgets/ingredient_image_helper.dart';
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

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00236F), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  void _showIngredientForm({IngredientModel? ingredient}) {
    final isEditing = ingredient != null;
    final nameCtrl = TextEditingController(text: ingredient?.name);
    final skuCtrl = TextEditingController(text: ingredient?.sku);
    final unitCtrl = TextEditingController(text: ingredient?.unit);
    final priceCtrl = TextEditingController(text: ingredient?.unitPrice.toString() ?? '0');
    final minStockCtrl = TextEditingController(text: ingredient?.minStockLevel.toString() ?? '0');
    bool isRawMaterial = ingredient?.isRawMaterial ?? true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            elevation: 10,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00236F).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isEditing ? Icons.edit_note_outlined : Icons.add_circle_outline,
                              color: const Color(0xFF00236F),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEditing ? 'Sửa Danh mục' : 'Thêm Danh mục mới',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF00236F)),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Cấu hình thông tin nguyên liệu và sản phẩm chuỗi',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tên nguyên liệu
                      TextFormField(
                        controller: nameCtrl,
                        decoration: _buildInputDecoration('Tên nguyên liệu / sản phẩm', Icons.shopping_bag_outlined),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Không được bỏ trống tên' : null,
                      ),
                      const SizedBox(height: 14),

                      // SKU
                      TextFormField(
                        controller: skuCtrl,
                        decoration: _buildInputDecoration('Mã SKU', Icons.qr_code_outlined),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Không được bỏ trống SKU' : null,
                      ),
                      const SizedBox(height: 14),

                      // Đơn vị
                      TextFormField(
                        controller: unitCtrl,
                        decoration: _buildInputDecoration('Đơn vị tính (kg, cái, viên...)', Icons.scale_outlined),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Không được bỏ trống đơn vị' : null,
                      ),
                      const SizedBox(height: 14),

                      // Đơn giá
                      TextFormField(
                        controller: priceCtrl,
                        decoration: _buildInputDecoration('Đơn giá (₫)', Icons.attach_money_outlined),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Không được bỏ trống đơn giá';
                          if (double.tryParse(val) == null) return 'Phải là số hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Tồn tối thiểu
                      TextFormField(
                        controller: minStockCtrl,
                        decoration: _buildInputDecoration('Tồn kho tối thiểu cảnh báo', Icons.warning_amber_outlined),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Không được bỏ trống tồn kho tối thiểu';
                          if (double.tryParse(val) == null) return 'Phải là số hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Switch Phân loại
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: SwitchListTile(
                          title: const Text(
                            'Là nguyên liệu thô?',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF00236F)),
                          ),
                          subtitle: Text(
                            isRawMaterial
                                ? 'Nhập kho trực tiếp từ nhà cung cấp'
                                : 'Sản xuất/chế biến qua công thức BOM',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          value: isRawMaterial,
                          activeColor: const Color(0xFF00236F),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          onChanged: (val) => setState(() => isRawMaterial = val),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Link BOM nhanh nếu đang sửa và không phải nguyên liệu thô
                      if (isEditing && !isRawMaterial) ...[
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx); // Close dialog
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManagerBomScreen(ingredient: ingredient),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long_outlined, size: 18),
                          label: const Text('Cấu hình Công thức BOM ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00236F),
                            side: const BorderSide(color: Color(0xFF00236F)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        const SizedBox(height: 12),
                      ],

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
                                
                                final provider = context.read<ManagerCatalogProvider>();
                                final body = {
                                  'name': nameCtrl.text.trim(),
                                  'sku': skuCtrl.text.trim(),
                                  'unit': unitCtrl.text.trim(),
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00236F),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      leading: buildIngredientPreview(
                        item.sku,
                        item.name,
                        size: 40,
                        borderRadius: 12,
                        fallback: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: item.isRawMaterial 
                                ? Colors.green.withOpacity(0.08)
                                : const Color(0xFF00236F).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.isRawMaterial ? Icons.eco_outlined : Icons.restaurant_menu_outlined,
                            color: item.isRawMaterial ? Colors.green : const Color(0xFF00236F),
                            size: 24,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                            ),
                          ),
                          const SizedBox(width: 8),
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        'SKU: ${item.sku} | Đơn vị: ${item.unit}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(color: Color(0xFFE2E8F0)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Đơn giá:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                  Text(
                                    formatCurrency.format(item.unitPrice),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00236F)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Phân loại:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                  Text(
                                    item.isRawMaterial ? 'Nguyên liệu thô' : 'Bán thành phẩm / Thành phẩm',
                                    style: TextStyle(
                                      fontSize: 13, 
                                      fontWeight: FontWeight.w600, 
                                      color: item.isRawMaterial ? Colors.green : const Color(0xFF00236F),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tồn kho tối thiểu:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                  Text(
                                    '${item.minStockLevel} ${item.unit}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
