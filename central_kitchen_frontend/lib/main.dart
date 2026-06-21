import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import các file core
import 'core/constants/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/navigation/navigator_key.dart';

// Import các file data
import 'data/datasources/auth_datasource.dart';
import 'data/datasources/admin_datasource.dart';
import 'data/datasources/inventory_datasource.dart';
import 'data/datasources/order_datasource.dart';
import 'data/datasources/notification_datasource.dart';
import 'data/datasources/delivery_chat_datasource.dart';
import 'data/datasources/manager_datasource.dart';
import 'data/datasources/manager_catalog_datasource.dart';

// Import các file business
import 'business/providers/auth_provider.dart';
import 'business/providers/admin_provider.dart';
import 'business/providers/inventory_provider.dart';
import 'business/providers/cart_order_provider.dart';
import 'business/providers/notification_provider.dart';
import 'business/providers/delivery_chat_provider.dart';
import 'business/providers/manager_provider.dart';
import 'business/providers/manager_catalog_provider.dart';

// Import các file presentation
import 'presentation/screens/shared/login_screen.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';
import 'presentation/screens/kitchen/kitchen_dashboard_screen.dart';
import 'presentation/screens/franchise/franchise_dashboard_screen.dart';
import 'presentation/screens/shared/map_screen.dart';
import 'presentation/screens/shared/chat_screen.dart';
import 'presentation/screens/coordinator/coordinator_dashboard_screen.dart';
import 'presentation/screens/manager/manager_dashboard_screen.dart';
import 'presentation/screens/manager/manager_category_screen.dart';
import 'presentation/screens/manager/manager_inventory_screen.dart';
import 'presentation/screens/manager/manager_analytics_screen.dart';
import 'presentation/screens/manager/manager_debt_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Đăng ký các Providers toàn cục để mọi màn hình đều có thể truy cập
    return MultiProvider(
      providers: [
        // 1. Tạo instance ApiClient dùng chung cho toàn bộ app
        Provider<ApiClient>(
          create: (_) => ApiClient(),
        ),
        
        // 2. Tạo các Datasources phụ thuộc vào ApiClient
        ProxyProvider<ApiClient, AuthDatasource>(
          update: (_, apiClient, _) => AuthDatasource(apiClient),
        ),
        ProxyProvider<ApiClient, AdminDatasource>(
          update: (_, apiClient, _) => AdminDatasource(apiClient),
        ),
        ProxyProvider<ApiClient, InventoryDatasource>(
          update: (_, apiClient, _) => InventoryDatasource(apiClient),
        ),
        ProxyProvider<ApiClient, OrderDatasource>(
          update: (_, apiClient, _) => OrderDatasource(apiClient),
        ),
        ProxyProvider<ApiClient, NotificationDatasource>(
          update: (_, apiClient, _) => NotificationDatasource(apiClient),
        ),
        ProxyProvider<ApiClient, DeliveryChatDatasource>(
          update: (_, apiClient, _) => DeliveryChatDatasource(apiClient),
        ),
        ProxyProvider<ApiClient, ManagerDatasource>(
          update: (_, apiClient, _) => ManagerDatasource(apiClient),
        ),
        ProxyProvider<ApiClient, ManagerCatalogDatasource>(
          update: (_, apiClient, _) => ManagerCatalogDatasource(apiClient),
        ),
        
        // 3. Tạo các Providers quản lý State, phụ thuộc vào các Datasources tương ứng
        ChangeNotifierProxyProvider<AuthDatasource, AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthDatasource>()),
          update: (_, authDatasource, previous) =>
              previous ?? AuthProvider(authDatasource),
        ),
        ChangeNotifierProxyProvider<AdminDatasource, AdminProvider>(
          create: (context) => AdminProvider(context.read<AdminDatasource>()),
          update: (_, adminDatasource, previous) =>
              previous ?? AdminProvider(adminDatasource),
        ),
        ChangeNotifierProxyProvider<InventoryDatasource, InventoryProvider>(
          create: (context) => InventoryProvider(context.read<InventoryDatasource>()),
          update: (_, inventoryDatasource, previous) =>
              previous ?? InventoryProvider(inventoryDatasource),
        ),
        ChangeNotifierProxyProvider<OrderDatasource, CartOrderProvider>(
          create: (context) => CartOrderProvider(context.read<OrderDatasource>()),
          update: (_, orderDatasource, previous) =>
              previous ?? CartOrderProvider(orderDatasource),
        ),
        ChangeNotifierProxyProvider<NotificationDatasource, NotificationProvider>(
          create: (context) =>
              NotificationProvider(context.read<NotificationDatasource>()),
          update: (_, notifDatasource, previous) =>
              previous ?? NotificationProvider(notifDatasource),
        ),
        ChangeNotifierProxyProvider<DeliveryChatDatasource, DeliveryChatProvider>(
          create: (context) =>
              DeliveryChatProvider(context.read<DeliveryChatDatasource>()),
          update: (_, deliveryChatDatasource, previous) =>
              previous ?? DeliveryChatProvider(deliveryChatDatasource),
        ),
        ChangeNotifierProxyProvider<ManagerDatasource, ManagerProvider>(
          create: (context) => ManagerProvider(context.read<ManagerDatasource>()),
          update: (_, managerDatasource, previous) =>
              previous ?? ManagerProvider(managerDatasource),
        ),
        ChangeNotifierProxyProvider<ManagerCatalogDatasource, ManagerCatalogProvider>(
          create: (context) => ManagerCatalogProvider(context.read<ManagerCatalogDatasource>()),
          update: (_, managerCatalogDatasource, previous) =>
              previous ?? ManagerCatalogProvider(managerCatalogDatasource),
        ),
      ],
      child: MaterialApp(
        title: 'Central Kitchen Pro',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        
        // Cấu hình màn hình khởi chạy đầu tiên
        home: const AuthWrapper(),
        
        // Đăng ký các route phụ trợ (Admin, Kitchen, Franchise)
        routes: {
          '/login': (context) => const LoginScreen(),
          '/admin': (context) => const AdminDashboardScreen(),
          '/kitchen': (context) => const KitchenDashboardScreen(),
          '/franchise': (context) => const FranchiseDashboardScreen(),
          '/map': (context) => const MapScreen(),
          '/chat': (context) => const ChatScreen(),
          '/coordinator': (context) => const CoordinatorDashboardScreen(),
          '/manager': (context) => const ManagerDashboardScreen(),
          '/manager/catalog': (context) => const ManagerCategoryScreen(),
          '/manager/inventory': (context) => const ManagerInventoryScreen(),
          '/manager/analytics': (context) => const ManagerAnalyticsScreen(),
          '/manager/debt': (context) => const ManagerDebtScreen(),
        },
      ),
    );
  }
}

/// Lớp trung gian kiểm tra trạng thái Đăng nhập để điều phối màn hình khi mở app.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    // Gọi tryAutoLogin một lần duy nhất khi khởi chạy để tránh vòng lặp vô hạn
    _autoLoginFuture = context.read<AuthProvider>().tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Sử dụng FutureBuilder với Future được lưu trữ cố định từ initState
    return FutureBuilder<bool>(
      future: _autoLoginFuture,
      builder: (context, snapshot) {
        // 1. Trong lúc đang đọc dữ liệu từ secure storage -> Hiển thị màn hình chờ Splash Screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: AppTheme.primary),
                  SizedBox(height: 16),
                  CircularProgressIndicator(color: AppTheme.primary),
                ],
              ),
            ),
          );
        }
        
        // 2. Đã đọc xong dữ liệu: Kiểm tra người dùng đã xác thực chưa
        if (authProvider.isAuthenticated) {
          final role = authProvider.userRole;
          
          // Điều hướng người dùng tự động vào đúng phân hệ vai trò khi tự động đăng nhập thành công
          if (role == 'ADMIN') {
            return const AdminDashboardScreen();
          } else if (role == 'KITCHEN_STAFF') {
            return const KitchenDashboardScreen();
          } else if (role == 'SUPPLY_COORDINATOR') {
            return const CoordinatorDashboardScreen();
          } else if (role == 'MANAGER') {
            return const ManagerDashboardScreen();
          } else {
            // FRANCHISE_STAFF → vào FranchiseDashboard
            return const FranchiseDashboardScreen();
          }
        } else {
          // Chưa đăng nhập -> Vào màn hình Đăng nhập
          return const LoginScreen();
        }
      },
    );
  }
}

/// Widget hiển thị tạm thời các Dashboard tương ứng với vai trò của nhân viên
class PlaceholderDashboard extends StatelessWidget {
  final String title;

  const PlaceholderDashboard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              // TODO 5.2.1: Gọi hàm logout từ AuthProvider để đăng xuất
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_customize_outlined, size: 80, color: AppTheme.secondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Tài khoản: ${authProvider.currentUser?.fullName ?? 'N/A'} (${authProvider.userRole ?? 'N/A'})',
              style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Quay lại login
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 45)),
              child: const Text('Về màn hình Login'),
            ),
          ],
        ),
      ),
    );
  }
}
