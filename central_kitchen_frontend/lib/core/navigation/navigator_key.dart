import 'package:flutter/material.dart';

/// Khóa điều hướng toàn cục (Global Navigator Key) giúp thực hiện chuyển hướng màn hình
/// từ bất kỳ đâu trong ứng dụng (ví dụ: trong Interceptor của ApiClient khi gặp lỗi 401)
/// mà không cần BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
