import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../business/providers/admin_provider.dart';
import '../../../../data/models/store_model.dart';
import '../../../../data/models/kitchen_model.dart';
import '../../../../core/constants/app_theme.dart';

/// Màn hình quản lý Cửa hàng nhượng quyền (Stores) và Bếp trung tâm (Kitchens).
/// Sử dụng TabController để phân chia 2 danh mục.
class ManageStoresScreen extends StatefulWidget {
  const ManageStoresScreen({super.key});

  @override
  State<ManageStoresScreen> createState() => _ManageStoresScreenState();
}

class _ManageStoresScreenState extends State<ManageStoresScreen> {
  @override
  void initState() {
    super.initState();
    // Tải dữ liệu ban đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProv = context.read<AdminProvider>();
      adminProv.fetchStores();
      adminProv.fetchKitchens();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Cửa hàng & Bếp trung tâm', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
          bottom: TabBar(
            labelColor: const Color(0xFF1E293B),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: AppTheme.primary,
            indicatorWeight: 2.5,
            dividerColor: const Color(0xFFE2E8F0),
            tabs: const [
              Tab(text: 'Cửa hàng Franchise', icon: Icon(Icons.store_mall_directory_outlined)),
              Tab(text: 'Bếp trung tâm', icon: Icon(Icons.kitchen_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Danh sách Stores
            _buildStoresTab(adminProv),
            // Tab 2: Danh sách Kitchens
            _buildKitchensTab(adminProv),
          ],
        ),
      ),
    );
  }

  // ======================== TAB 1: CỬA HÀNG FRANCHISE ========================
  Widget _buildStoresTab(AdminProvider adminProv) {
    if (adminProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (adminProv.stores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Chưa có cửa hàng franchise nào.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _openStoreEditDialog(null),
              icon: const Icon(Icons.add),
              label: const Text('Thêm Cửa hàng'),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _openStoreEditDialog(null),
              icon: const Icon(Icons.add),
              label: const Text('Thêm Cửa hàng'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: adminProv.stores.length,
            itemBuilder: (context, index) {
              final store = adminProv.stores[index];
              return _buildStoreCard(store);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoreCard(StoreModel store) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.outlineVariant),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    store.storeName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: store.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    store.isActive ? 'Active' : 'Closed',
                    style: TextStyle(fontSize: 12, color: store.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.outline),
                const SizedBox(width: 6),
                Expanded(child: Text(store.address, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant))),
              ],
            ),
            if (store.phoneNumber != null)
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 14, color: AppTheme.outline),
                  const SizedBox(width: 6),
                  Text(store.phoneNumber!, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            const Divider(height: 16),
            // Thông tin công nợ & hạn mức tín dụng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hạn mức nợ: \$${store.creditLimit ?? 0.0}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text('Nợ hiện tại: \$${store.currentDebt ?? 0.0}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: (store.currentDebt ?? 0) > (store.creditLimit ?? 0) ? Colors.red : AppTheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Số nhân sự cửa hàng: ${store.staffCount}', style: const TextStyle(fontSize: 11, color: AppTheme.outline)),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppTheme.secondary),
                  onPressed: () => _openStoreEditDialog(store),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_outlined, color: AppTheme.error),
                  onPressed: () => _confirmDeleteStore(store.storeId, store.storeName),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ======================== TAB 2: BẾP TRUNG TÂM ========================
  Widget _buildKitchensTab(AdminProvider adminProv) {
    if (adminProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (adminProv.kitchens.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Chưa có bếp trung tâm nào.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _openKitchenEditDialog(null),
              icon: const Icon(Icons.add),
              label: const Text('Thêm Bếp sản xuất'),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _openKitchenEditDialog(null),
              icon: const Icon(Icons.add),
              label: const Text('Thêm Bếp sản xuất'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: adminProv.kitchens.length,
            itemBuilder: (context, index) {
              final kitchen = adminProv.kitchens[index];
              return _buildKitchenCard(kitchen);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKitchenCard(KitchenModel kitchen) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.outlineVariant),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    kitchen.kitchenName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kitchen.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    kitchen.isActive ? 'Active' : 'Closed',
                    style: TextStyle(fontSize: 12, color: kitchen.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.outline),
                const SizedBox(width: 6),
                Expanded(child: Text(kitchen.address, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant))),
              ],
            ),
            if (kitchen.phoneNumber != null)
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 14, color: AppTheme.outline),
                  const SizedBox(width: 6),
                  Text(kitchen.phoneNumber!, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            const SizedBox(height: 4),
            Text('Số nhân sự bếp: ${kitchen.staffCount}', style: const TextStyle(fontSize: 11, color: AppTheme.outline)),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppTheme.secondary),
                  onPressed: () => _openKitchenEditDialog(kitchen),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_outlined, color: AppTheme.error),
                  onPressed: () => _confirmDeleteKitchen(kitchen.kitchenId, kitchen.kitchenName),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- POPUP DIALOGS ---
  void _openStoreEditDialog(StoreModel? store) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _StoreEditDialog(
          store: store,
          onSaved: () => context.read<AdminProvider>().fetchStores(),
        );
      },
    );
  }

  void _openKitchenEditDialog(KitchenModel? kitchen) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _KitchenEditDialog(
          kitchen: kitchen,
          onSaved: () => context.read<AdminProvider>().fetchKitchens(),
        );
      },
    );
  }

  // --- CONFIRM DELETES ---
  void _confirmDeleteStore(int id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa cửa hàng "$name"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              onPressed: () async {
                Navigator.pop(context);
                final success = await context.read<AdminProvider>().removeStore(id);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa cửa hàng thành công!')));
                }
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteKitchen(int id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa bếp trung tâm "$name"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              onPressed: () async {
                Navigator.pop(context);
                final success = await context.read<AdminProvider>().removeKitchen(id);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa bếp thành công!')));
                }
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}

// ======================== EDIT STORE FORM DIALOG ========================
class _StoreEditDialog extends StatefulWidget {
  final StoreModel? store;
  final VoidCallback onSaved;

  const _StoreEditDialog({this.store, required this.onSaved});

  @override
  State<_StoreEditDialog> createState() => _StoreEditDialogState();
}

class _StoreEditDialogState extends State<_StoreEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _creditController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.store != null) {
      _nameController.text = widget.store!.storeName;
      _addressController.text = widget.store!.address;
      _phoneController.text = widget.store!.phoneNumber ?? '';
      _creditController.text = widget.store!.creditLimit?.toString() ?? '0.0';
      _isActive = widget.store!.isActive;
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
      prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant, size: 20),
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
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
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

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.store != null;

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
            key: _formKey,
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
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEditMode ? Icons.edit_location_alt_outlined : Icons.add_business_outlined,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditMode ? 'Chỉnh sửa Cửa hàng' : 'Thêm Cửa hàng mới',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Thông tin chi tiết cửa hàng franchise nhượng quyền',
                            style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('Tên cửa hàng nhượng quyền', Icons.storefront_outlined),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Không được bỏ trống tên' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _addressController,
                  decoration: _buildInputDecoration('Địa chỉ cửa hàng', Icons.location_on_outlined),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Không được bỏ trống địa chỉ' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _phoneController,
                  decoration: _buildInputDecoration('Số điện thoại', Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _creditController,
                  decoration: _buildInputDecoration('Hạn mức nợ tối đa (\$)', Icons.attach_money_outlined),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return null;
                    if (double.tryParse(val) == null) return 'Phải là định dạng số hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                if (isEditMode) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SwitchListTile(
                      title: const Text('Trạng thái hoạt động', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      value: _isActive,
                      activeColor: AppTheme.secondary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  const SizedBox(height: 10),
                ],

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Hủy', style: TextStyle(color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final provider = context.read<AdminProvider>();
                          
                          final storeData = {
                            'storeName': _nameController.text.trim(),
                            'address': _addressController.text.trim(),
                            'phoneNumber': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                            'creditLimit': _creditController.text.trim().isEmpty ? null : double.tryParse(_creditController.text),
                            'isActive': _isActive,
                          };

                          bool success;
                          if (isEditMode) {
                            success = await provider.editStore(widget.store!.storeId, storeData);
                          } else {
                            success = await provider.addStore(storeData);
                          }

                          if (mounted) {
                            if (success) {
                              Navigator.pop(context);
                              widget.onSaved();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditMode ? 'Cập nhật thành công!' : 'Tạo cửa hàng thành công!')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Có lỗi xảy ra!')));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================== EDIT KITCHEN FORM DIALOG ========================
class _KitchenEditDialog extends StatefulWidget {
  final KitchenModel? kitchen;
  final VoidCallback onSaved;

  const _KitchenEditDialog({this.kitchen, required this.onSaved});

  @override
  State<_KitchenEditDialog> createState() => _KitchenEditDialogState();
}

class _KitchenEditDialogState extends State<_KitchenEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.kitchen != null) {
      _nameController.text = widget.kitchen!.kitchenName;
      _addressController.text = widget.kitchen!.address;
      _phoneController.text = widget.kitchen!.phoneNumber ?? '';
      _isActive = widget.kitchen!.isActive;
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
      prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant, size: 20),
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
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
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

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.kitchen != null;

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
            key: _formKey,
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
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEditMode ? Icons.edit_road_outlined : Icons.add_home_work_outlined,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditMode ? 'Chỉnh sửa Bếp' : 'Thêm Bếp mới',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Thông tin chi tiết bếp sản xuất trung tâm',
                            style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('Tên bếp trung tâm', Icons.kitchen_outlined),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Không được bỏ trống tên' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _addressController,
                  decoration: _buildInputDecoration('Địa chỉ bếp', Icons.location_on_outlined),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Không được bỏ trống địa chỉ' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _phoneController,
                  decoration: _buildInputDecoration('Số điện thoại liên hệ', Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                if (isEditMode) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SwitchListTile(
                      title: const Text('Trạng thái hoạt động', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      value: _isActive,
                      activeColor: AppTheme.secondary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  const SizedBox(height: 10),
                ],

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Hủy', style: TextStyle(color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final provider = context.read<AdminProvider>();
                          
                          final kitchenData = {
                            'kitchenName': _nameController.text.trim(),
                            'address': _addressController.text.trim(),
                            'phoneNumber': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                            'isActive': _isActive,
                          };

                          bool success;
                          if (isEditMode) {
                            success = await provider.editKitchen(widget.kitchen!.kitchenId, kitchenData);
                          } else {
                            success = await provider.addKitchen(kitchenData);
                          }

                          if (mounted) {
                            if (success) {
                              Navigator.pop(context);
                              widget.onSaved();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditMode ? 'Cập nhật thành công!' : 'Tạo bếp thành công!')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Có lỗi xảy ra!')));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
