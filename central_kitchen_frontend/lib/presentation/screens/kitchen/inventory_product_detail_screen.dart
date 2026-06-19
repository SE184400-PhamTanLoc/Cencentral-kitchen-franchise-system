import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../business/providers/inventory_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/batch_model.dart';
import '../../../data/models/ingredient_model.dart';

class InventoryProductDetailScreen extends StatefulWidget {
  final IngredientModel ingredient;

  const InventoryProductDetailScreen({super.key, required this.ingredient});

  @override
  State<InventoryProductDetailScreen> createState() => _InventoryProductDetailScreenState();
}

class _InventoryProductDetailScreenState extends State<InventoryProductDetailScreen> {
  final _quantityController = TextEditingController(text: '1');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchIngredientDetail(widget.ingredient.ingredientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final ingredient = provider.selectedIngredient ?? widget.ingredient;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text('Chi tiết nguyên liệu'),
        actions: [
          IconButton(
            tooltip: 'Thêm lô mới',
            onPressed: () => _openBatchEditorSheet(context, ingredient),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: _HeaderCard(ingredient: ingredient),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _InfoGrid(ingredient: ingredient),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _RecipeOverviewCard(ingredient: ingredient),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Batches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        Text('${provider.batches.length} lô', style: const TextStyle(color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final batch = provider.batches[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _BatchCard(
                          batch: batch,
                          onEdit: () => _openBatchEditorSheet(context, ingredient, existingBatch: batch),
                          onDelete: () => _confirmDeleteBatch(context, batch),
                        ),
                      );
                    },
                    childCount: provider.batches.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: _RecipeSection(
                      ingredient: ingredient,
                      quantityController: _quantityController,
                      onBuildPlan: () async {
                        final qty = double.tryParse(_quantityController.text) ?? 1;
                        final success = await context.read<InventoryProvider>().buildProductionPlan(ingredient.ingredientId, qty);
                        if (!context.mounted) return;
                        if (success) {
                          showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                            ),
                            builder: (_) => _ProductionPlanSheet(provider: provider),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.errorMessage ?? 'Không thể tính BOM')),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _openBatchEditorSheet(
    BuildContext context,
    IngredientModel ingredient, {
    BatchModel? existingBatch,
  }) async {
    final auth = context.read<AuthProvider>();
    final inventoryProvider = context.read<InventoryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final kitchenId = auth.kitchenId ?? 1;
    final isEditMode = existingBatch != null;
    final batchCodeController = TextEditingController(text: existingBatch?.batchCode ?? '');
    final quantityController = TextEditingController(text: (existingBatch?.quantity ?? 0).toStringAsFixed(2));
    final remainingController = TextEditingController(text: (existingBatch?.remainingQuantity ?? 0).toStringAsFixed(2));
    final manufactureDateController = TextEditingController(
      text: existingBatch?.manufactureDate?.toIso8601String().split('T').first ?? '',
    );
    final expiryDateController = TextEditingController(
      text: existingBatch?.expiryDate.toIso8601String().split('T').first ?? '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              Future<void> pickDate(TextEditingController controller) async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (selected != null && context.mounted) {
                  controller.text = selected.toIso8601String().split('T').first;
                  setState(() {});
                }
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditMode ? 'Cập nhật lô sản xuất' : 'Tạo lô sản xuất',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 6),
                    Text(ingredient.name, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: batchCodeController,
                      decoration: const InputDecoration(labelText: 'Mã lô'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tổng số lượng'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: remainingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Số lượng còn lại'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: manufactureDateController,
                      readOnly: true,
                      onTap: () => pickDate(manufactureDateController),
                      decoration: const InputDecoration(
                        labelText: 'Ngày sản xuất',
                        suffixIcon: Icon(Icons.date_range_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: expiryDateController,
                      readOnly: true,
                      onTap: () => pickDate(expiryDateController),
                      decoration: const InputDecoration(
                        labelText: 'Hạn sử dụng',
                        suffixIcon: Icon(Icons.event_available_outlined),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final quantity = double.tryParse(quantityController.text) ?? 0;
                          final remaining = double.tryParse(remainingController.text) ?? 0;
                          if (batchCodeController.text.trim().isEmpty || quantity <= 0 || expiryDateController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ mã lô, số lượng và hạn sử dụng.')));
                            return;
                          }

                          final payload = {
                            'batchCode': batchCodeController.text.trim(),
                            'ingredientId': ingredient.ingredientId,
                            'quantity': quantity,
                            'remainingQuantity': remaining,
                            'manufactureDate': manufactureDateController.text.isEmpty ? null : manufactureDateController.text,
                            'expiryDate': expiryDateController.text,
                            'kitchenId': kitchenId,
                          };

                          final success = isEditMode
                              ? await inventoryProvider.updateBatch(existingBatch.batchId, payload)
                              : await inventoryProvider.createBatch(payload);

                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pop(context);
                            await inventoryProvider.fetchIngredientDetail(ingredient.ingredientId);
                            messenger.showSnackBar(
                              SnackBar(content: Text(isEditMode ? 'Cập nhật lô thành công!' : 'Tạo lô thành công!')),
                            );
                          } else {
                            messenger.showSnackBar(
                              SnackBar(content: Text(inventoryProvider.errorMessage ?? 'Thao tác lô thất bại')),
                            );
                          }
                        },
                        child: Text(isEditMode ? 'Cập nhật lô' : 'Lưu lô'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteBatch(BuildContext context, BatchModel batch) async {
    final provider = context.read<InventoryProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa lô sản xuất'),
          content: Text('Bạn có chắc muốn xóa lô "${batch.batchCode}" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final success = await provider.deleteBatch(batch.batchId);
    if (!context.mounted) return;

    if (success) {
      await provider.fetchIngredientDetail(widget.ingredient.ingredientId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa lô thành công!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Xóa lô thất bại')),
      );
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final IngredientModel ingredient;

  const _HeaderCard({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final isLowStock = ingredient.availableQuantity <= ingredient.minStockLevel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF00236F), Color(0xFF0058BE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ingredient.name,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              if (ingredient.isRawMaterial)
                const Chip(
                  label: Text('RAW'),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
                )
              else
                const Chip(
                  label: Text('BFP'),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'SKU: ${ingredient.sku}  •  ${ingredient.unit}  •  ${ingredient.batchCount} lô',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatPill(label: 'Tồn khả dụng', value: ingredient.availableQuantity.toStringAsFixed(2)),
              const SizedBox(width: 10),
              _StatPill(label: 'Ngưỡng tối thiểu', value: ingredient.minStockLevel.toStringAsFixed(2)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(isLowStock ? Icons.warning_amber_rounded : Icons.verified_outlined, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isLowStock ? 'Tồn kho đang thấp hơn ngưỡng cảnh báo.' : 'Tồn kho đang trong trạng thái an toàn.',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final IngredientModel ingredient;

  const _InfoGrid({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _InfoCard(label: 'Giá nhập', value: '${ingredient.unitPrice.toStringAsFixed(0)} đ/${ingredient.unit}')),
        const SizedBox(width: 12),
        Expanded(child: _InfoCard(label: 'Loại', value: ingredient.isRawMaterial ? 'Nguyên liệu thô' : 'Bán thành phẩm')),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RecipeOverviewCard extends StatelessWidget {
  final IngredientModel ingredient;

  const _RecipeOverviewCard({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final inputs = ingredient.recipeInputs;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Công thức quy đổi / BOM', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
          const SizedBox(height: 8),
          Text(
            ingredient.recipeDescription?.isNotEmpty == true
                ? ingredient.recipeDescription!
                : 'Chưa có mô tả định mức cho nguyên liệu này.',
            style: const TextStyle(color: AppTheme.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 14),
          if (inputs.isEmpty)
            const Text(
              'Chưa có thành phần input trong BOM.',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: inputs.map((input) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(input.inputIngredientName, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                      const SizedBox(height: 4),
                      Text(
                        '${input.quantityRequired.toStringAsFixed(4)} ${input.unit}',
                        style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final BatchModel batch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BatchCard({required this.batch, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final expired = batch.isExpired == true;
    final remaining = batch.remainingQuantity.toStringAsFixed(2);
    final total = batch.quantity.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(batch.batchCode, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: expired ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  expired ? 'Hết hạn' : 'Còn hạn',
                  style: TextStyle(color: expired ? Colors.red : Colors.green, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Bếp: ${batch.kitchenName}', style: const TextStyle(color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text('Số lượng còn lại: $remaining / $total', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('HSD: ${batch.expiryDate.day.toString().padLeft(2, '0')}/${batch.expiryDate.month.toString().padLeft(2, '0')}/${batch.expiryDate.year}', style: const TextStyle(color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Sửa'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                label: const Text('Xóa', style: TextStyle(color: AppTheme.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipeSection extends StatelessWidget {
  final IngredientModel ingredient;
  final TextEditingController quantityController;
  final VoidCallback onBuildPlan;

  const _RecipeSection({
    required this.ingredient,
    required this.quantityController,
    required this.onBuildPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lập BOM / Production Plan', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
          const SizedBox(height: 10),
          Text(
            ingredient.hasRecipe
                ? 'Nguyên liệu này có công thức quy đổi. Nhập số lượng cần sản xuất để tính nhu cầu nguyên liệu thô.'
                : 'Nguyên liệu này không có công thức quy đổi. Bạn vẫn có thể xem batch hiện có.',
            style: const TextStyle(color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số lượng cần sản xuất',
              prefixIcon: Icon(Icons.calculate_outlined),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onBuildPlan,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Tính BOM'),
          ),
        ],
      ),
    );
  }
}

class _ProductionPlanSheet extends StatelessWidget {
  final InventoryProvider provider;

  const _ProductionPlanSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final plan = provider.productionPlan;
    if (plan == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.outputIngredientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            const SizedBox(height: 4),
            Text('Số lượng yêu cầu: ${plan.requestedQuantity}', style: const TextStyle(color: AppTheme.onSurfaceVariant)),
            const SizedBox(height: 18),
            ...plan.materials.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(item.ingredientName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        Text(
                          item.shortageQuantity > 0 ? 'Thiếu' : 'Đủ',
                          style: TextStyle(
                            color: item.shortageQuantity > 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Cần: ${item.requiredQuantity.toStringAsFixed(2)} ${item.unit}'),
                    Text('Khả dụng: ${item.availableQuantity.toStringAsFixed(2)} ${item.unit}'),
                    if (item.shortageQuantity > 0)
                      Text('Thiếu: ${item.shortageQuantity.toStringAsFixed(2)} ${item.unit}', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
