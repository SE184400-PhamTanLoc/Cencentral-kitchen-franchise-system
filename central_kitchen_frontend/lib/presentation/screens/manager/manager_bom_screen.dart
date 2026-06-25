import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../business/providers/manager_catalog_provider.dart';
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

  void _addInputIngredient() {
    final provider = context.read<ManagerCatalogProvider>();
    // Chỉ lấy nguyên liệu thô làm đầu vào BOM
    final availableInputs = provider.ingredients.where((i) => i.isRawMaterial).toList();

    showDialog(
      context: context,
      builder: (ctx) {
        IngredientModel? selected;
        final qtyCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thêm nguyên liệu con'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<IngredientModel>(
                    isExpanded: true,
                    hint: const Text('Chọn nguyên liệu thô'),
                    value: selected,
                    items: availableInputs.map((i) {
                      return DropdownMenuItem(value: i, child: Text(i.name));
                    }).toList(),
                    onChanged: (val) => setState(() => selected = val),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: qtyCtrl,
                    decoration: const InputDecoration(labelText: 'Số lượng định mức'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () {
                    if (selected != null && qtyCtrl.text.isNotEmpty) {
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
                  child: const Text('Thêm'),
                )
              ],
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _selectedInputs.length,
              itemBuilder: (context, index) {
                final item = _selectedInputs[index];
                return Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    title: Text(item['inputIngredientName'], style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    subtitle: Text('Định mức: ${item['quantityRequired']}', style: const TextStyle(color: Color(0xFF64748B))),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                      onPressed: () {
                        setState(() {
                          _selectedInputs.removeAt(index);
                        });
                      },
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
