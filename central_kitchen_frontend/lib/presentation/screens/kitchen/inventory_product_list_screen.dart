import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/inventory_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/ingredient_model.dart';
import 'inventory_product_detail_screen.dart';
import '../../widgets/ingredient_image_helper.dart';

class InventoryProductListScreen extends StatefulWidget {
  const InventoryProductListScreen({super.key});

  @override
  State<InventoryProductListScreen> createState() => _InventoryProductListScreenState();
}

class _InventoryProductListScreenState extends State<InventoryProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final ingredients = provider.filteredIngredients;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Danh sách nguyên liệu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<InventoryProvider>().fetchIngredients(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<InventoryProvider>().fetchIngredients(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBanner(ingredientCount: provider.ingredients.length),
                    const SizedBox(height: 16),
                    _SearchBar(
                      value: provider.searchQuery,
                      onChanged: (value) {
                        provider.setSearchQuery(value);
                        provider.fetchIngredients(keyword: value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _FilterRow(
                      rawFilter: provider.rawFilter,
                      onChanged: (value) {
                        provider.setRawFilter(value);
                        provider.fetchIngredients(isRawMaterial: value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && ingredients.isEmpty)
              SliverFillRemaining(
                child: Center(child: Text(provider.errorMessage!)),
              )
            else if (ingredients.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Chưa có nguyên liệu nào phù hợp.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = ingredients[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _IngredientCard(
                          ingredient: item,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => InventoryProductDetailScreen(ingredient: item)),
                            );
                          },
                        ),
                      );
                    },
                    childCount: ingredients.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBanner extends StatelessWidget {
  final int ingredientCount;

  const _TopBanner({required this.ingredientCount});

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Central Kitchen Inventory', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                const Text(
                  'Danh mục nguyên liệu và bán thành phẩm',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hiện có $ingredientCount mặt hàng trong hệ thống.',
                  style: TextStyle(color: Colors.white.withOpacity(0.82)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 34),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.value, required this.onChanged});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: 'Tìm theo tên hoặc SKU',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.value.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final bool? rawFilter;
  final ValueChanged<bool?> onChanged;

  const _FilterRow({required this.rawFilter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = <({String label, bool? value})>[
      (label: 'Tất cả', value: null),
      (label: 'Nguyên liệu thô', value: true),
      (label: 'Bán thành phẩm', value: false),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final selected = item.value == rawFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text(item.label),
              selected: selected,
              onSelected: (_) => onChanged(item.value),
              selectedColor: AppTheme.primary.withOpacity(0.12),
              labelStyle: TextStyle(
                color: selected ? AppTheme.primary : AppTheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(color: selected ? AppTheme.primary : const Color(0xFFE2E8F0)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  final IngredientModel ingredient;
  final VoidCallback onTap;

  const _IngredientCard({required this.ingredient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLowStock = ingredient.availableQuantity <= ingredient.minStockLevel;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            (() {
              final imagePath = getIngredientImage(ingredient.sku, ingredient.name);
              if (imagePath != null) {
                return Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                );
              }
              return Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ingredient.isRawMaterial ? AppTheme.secondary : AppTheme.primaryContainer,
                      AppTheme.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(ingredient.isRawMaterial ? Icons.grain_outlined : Icons.bakery_dining_outlined, color: Colors.white),
              );
            })(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ingredient.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primary),
                        ),
                      ),
                      if (isLowStock)
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('SKU: ${ingredient.sku}', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Tag(label: ingredient.isRawMaterial ? 'Nguyên liệu thô' : 'Bán thành phẩm'),
                      _Tag(label: '${ingredient.availableQuantity.toStringAsFixed(1)} ${ingredient.unit}'),
                      _Tag(label: '${ingredient.batchCount} lô'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant)),
    );
  }
}
