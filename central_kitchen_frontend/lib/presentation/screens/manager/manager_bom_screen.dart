import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../business/providers/manager_catalog_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/ingredient_model.dart';

class ManagerBomScreen extends StatefulWidget {
  final IngredientModel ingredient;

  const ManagerBomScreen({super.key, required this.ingredient});

  @override
  State<ManagerBomScreen> createState() => _ManagerBomScreenState();
}

class _ManagerBomScreenState extends State<ManagerBomScreen> {
  final List<Map<String, dynamic>> _selectedInputs = [];

  @override
  void initState() {
    super.initState();
    _loadExistingRecipe();
  }

  void _loadExistingRecipe() {
    final provider = context.read<ManagerCatalogProvider>();
    final existingRecipe = provider.recipes.where((r) => r.outputIngredientId == widget.ingredient.ingredientId).firstOrNull;
    
    if (existingRecipe != null) {
      for (var detail in existingRecipe.details) {
        _selectedInputs.add({
          'inputIngredientId': detail.inputIngredientId,
          'inputIngredientName': detail.inputIngredientName,
          'quantityRequired': detail.quantityRequired,
        });
      }
    }
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

  void _addInputIngredient() {
    final provider = context.read<ManagerCatalogProvider>();
    // Chỉ lấy nguyên liệu thô làm đầu vào BOM
    final availableInputs = provider.ingredients.where((i) => i.isRawMaterial).toList();

    showDialog(
      context: context,
      builder: (ctx) {
        IngredientModel? selected;
        final qtyCtrl = TextEditingController();
        final formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              elevation: 10,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Custom Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00236F).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.eco_outlined,
                                color: Color(0xFF00236F),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thêm nguyên liệu',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF00236F)),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Định mức nguyên liệu thô cấu thành công thức',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Dropdown Chọn Nguyên liệu thô
                        DropdownButtonFormField<IngredientModel>(
                          isExpanded: true,
                          decoration: _buildInputDecoration('Chọn nguyên liệu thô', Icons.restaurant_menu_outlined),
                          value: selected,
                          items: availableInputs.map((i) {
                            return DropdownMenuItem(value: i, child: Text(i.name));
                          }).toList(),
                          onChanged: (val) => setState(() => selected = val),
                          validator: (val) => val == null ? 'Vui lòng chọn nguyên liệu thô' : null,
                        ),
                        const SizedBox(height: 14),

                        // Ô Nhập số lượng
                        TextFormField(
                          controller: qtyCtrl,
                          decoration: _buildInputDecoration('Số lượng định mức', Icons.numbers_outlined),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập số lượng định mức';
                            }
                            if (double.tryParse(val) == null) {
                              return 'Vui lòng nhập số hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Nút hành động
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
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    this.setState(() {
                                      _selectedInputs.add({
                                        'inputIngredientId': selected!.ingredientId,
                                        'inputIngredientName': selected!.name,
                                        'quantityRequired': double.tryParse(qtyCtrl.text) ?? 0,
                                      });
                                    });
                                    Navigator.pop(ctx);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00236F),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: const Text('Thêm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  void _saveBOM() async {
    if (_selectedInputs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm ít nhất 1 nguyên liệu con.')));
      return;
    }

    final provider = context.read<ManagerCatalogProvider>();
    final existingRecipe = provider.recipes.where((r) => r.outputIngredientId == widget.ingredient.ingredientId).firstOrNull;

    final details = _selectedInputs.map((i) => {
      'inputIngredientId': i['inputIngredientId'],
      'quantityRequired': i['quantityRequired']
    }).toList();

    try {
      if (existingRecipe != null) {
        await provider.updateRecipe(existingRecipe.recipeId, {
          'description': 'Cập nhật BOM cho ${widget.ingredient.name}',
          'details': details,
        });
      } else {
        await provider.createRecipe({
          'outputIngredientId': widget.ingredient.ingredientId,
          'description': 'Tạo mới BOM cho ${widget.ingredient.name}',
          'details': details,
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu BOM thành công!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  void _editInputIngredientQuantity(int index, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) {
        final qtyCtrl = TextEditingController(text: item['quantityRequired'].toString());
        final formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              elevation: 10,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Custom Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00236F).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.edit_note_outlined,
                                color: Color(0xFF00236F),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sửa định mức',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF00236F)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Cập nhật định mức cho ${item['inputIngredientName']}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Số lượng định mức
                        TextFormField(
                          controller: qtyCtrl,
                          decoration: _buildInputDecoration('Số lượng định mức', Icons.numbers_outlined),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập số lượng định mức';
                            }
                            if (double.tryParse(val) == null) {
                              return 'Vui lòng nhập số hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Nút hành động
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
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    this.setState(() {
                                      _selectedInputs[index]['quantityRequired'] = double.tryParse(qtyCtrl.text) ?? 0;
                                    });
                                    Navigator.pop(ctx);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00236F),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: const Text('Cập nhật', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cấu hình BOM: ${widget.ingredient.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          Expanded(
            child: _selectedInputs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'Công thức chưa có nguyên liệu con nào.\nHãy bấm nút "Thêm nguyên liệu" bên dưới.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _selectedInputs.length,
                    itemBuilder: (context, index) {
                      final item = _selectedInputs[index];
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                // Trái
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.grain_outlined,
                                    color: AppTheme.secondary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Giữa
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['inputIngredientName'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text('Định mức: ', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                                          Text(
                                            '${item['quantityRequired']}',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Phải (Actions)
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppTheme.secondary, size: 20),
                                  onPressed: () => _editInputIngredientQuantity(index, item),
                                  tooltip: 'Sửa định mức',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_outlined, color: Colors.red, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _selectedInputs.removeAt(index);
                                    });
                                  },
                                  tooltip: 'Xóa khỏi công thức',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addInputIngredient,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm nguyên liệu'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00236F),
                      side: const BorderSide(color: Color(0xFF00236F)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveBOM,
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu BOM'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00236F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
