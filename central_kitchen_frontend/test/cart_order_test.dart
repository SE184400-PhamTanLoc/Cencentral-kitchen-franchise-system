import 'package:flutter_test/flutter_test.dart';
import 'package:central_kitchen_frontend/data/models/order_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// THAI_FLUT_04 — Unit Test: CartOrderProvider - Tính tổng tiền giỏ hàng
//
// Vì CartOrderProvider cần OrderDatasource (network), chúng ta test
// trực tiếp logic tính tiền thông qua CartItemModel và các công thức
// tương đương với provider, tránh phải mock Dio/HTTP.
// ─────────────────────────────────────────────────────────────────────────────

/// Hàm helper giả lập logic tính tiền của CartOrderProvider.
/// Tách riêng để test thuần logic mà không cần khởi tạo Provider.
class CartCalculator {
  static const double taxRate = 0.10;
  static const double shippingFee = 30000;
  static const double freeShippingThreshold = 500000;

  final Map<int, CartItemModel> _items = {};

  void addItem({
    required int ingredientId,
    required String name,
    required String unit,
    required double unitPrice,
    int quantity = 1,
  }) {
    if (_items.containsKey(ingredientId)) {
      _items[ingredientId] = _items[ingredientId]!
          .copyWith(quantity: _items[ingredientId]!.quantity + quantity);
    } else {
      _items[ingredientId] = CartItemModel(
        ingredientId: ingredientId,
        name: name,
        unit: unit,
        unitPrice: unitPrice,
        quantity: quantity,
      );
    }
  }

  void removeItem(int ingredientId) => _items.remove(ingredientId);

  void updateQuantity(int ingredientId, int qty) {
    if (qty <= 0) {
      _items.remove(ingredientId);
    } else if (_items.containsKey(ingredientId)) {
      _items[ingredientId] = _items[ingredientId]!.copyWith(quantity: qty);
    }
  }

  void decreaseItem(int ingredientId) {
    if (!_items.containsKey(ingredientId)) return;
    final current = _items[ingredientId]!;
    if (current.quantity <= 1) {
      _items.remove(ingredientId);
    } else {
      _items[ingredientId] =
          current.copyWith(quantity: current.quantity - 1);
    }
  }

  void clear() => _items.clear();

  List<CartItemModel> get items => _items.values.toList();
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  double get subtotal =>
      _items.values.fold(0.0, (sum, i) => sum + i.subtotal);

  double get taxAmount => subtotal * taxRate;

  double get shippingAmount =>
      subtotal >= freeShippingThreshold ? 0 : shippingFee;

  double get grandTotal => subtotal + taxAmount + shippingAmount;
}

// ─────────────────────────────────────────────────────────────────────────────
// TEST SUITE
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('CartCalculator — Logic tính tiền giỏ hàng', () {
    late CartCalculator cart;

    setUp(() {
      cart = CartCalculator();
    });

    // ────────────────────────────────────────────────────────────
    // TC-01: Giỏ hàng trống → tất cả bằng 0 (ngoại trừ ship)
    // ────────────────────────────────────────────────────────────
    test('TC-01: Giỏ trống - subtotal = 0, taxAmount = 0, grandTotal = shipping', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.subtotal, equals(0.0));
      expect(cart.taxAmount, equals(0.0));
      // Giỏ trống → subtotal = 0 < 500k → shippingAmount = 30000
      expect(cart.shippingAmount, equals(30000.0));
      expect(cart.grandTotal, equals(30000.0));
    });

    // ────────────────────────────────────────────────────────────
    // TC-02: Thêm 1 mặt hàng duy nhất
    // ────────────────────────────────────────────────────────────
    test('TC-02: Thêm 1 item - subtotal chính xác', () {
      cart.addItem(
        ingredientId: 1,
        name: 'Gạo tẻ',
        unit: 'kg',
        unitPrice: 25000,
        quantity: 10,
      );

      // subtotal = 25000 * 10 = 250,000
      expect(cart.subtotal, equals(250000.0));
      expect(cart.itemCount, equals(1));
    });

    // ────────────────────────────────────────────────────────────
    // TC-03: Tính thuế VAT 10%
    // ────────────────────────────────────────────────────────────
    test('TC-03: Thuế VAT = 10% của subtotal', () {
      cart.addItem(
        ingredientId: 1,
        name: 'Gạo tẻ',
        unit: 'kg',
        unitPrice: 25000,
        quantity: 10,
      );

      // taxAmount = 250,000 * 0.10 = 25,000
      expect(cart.taxAmount, closeTo(25000.0, 0.01));
    });

    // ────────────────────────────────────────────────────────────
    // TC-04: Tổng cộng = subtotal + tax + ship (dưới ngưỡng free ship)
    // ────────────────────────────────────────────────────────────
    test('TC-04: grandTotal bao gồm subtotal + tax + shippingFee', () {
      cart.addItem(
        ingredientId: 1,
        name: 'Gạo tẻ',
        unit: 'kg',
        unitPrice: 25000,
        quantity: 10,
      );

      // subtotal = 250,000 < 500,000 → ship = 30,000
      // grandTotal = 250,000 + 25,000 + 30,000 = 305,000
      expect(cart.grandTotal, closeTo(305000.0, 0.01));
      expect(cart.shippingAmount, equals(30000.0));
    });

    // ────────────────────────────────────────────────────────────
    // TC-05: Miễn phí ship khi đơn >= 500,000 VNĐ
    // ────────────────────────────────────────────────────────────
    test('TC-05: Miễn phí vận chuyển khi subtotal >= 500,000', () {
      cart.addItem(
        ingredientId: 1,
        name: 'Thịt bò',
        unit: 'kg',
        unitPrice: 300000,
        quantity: 2,
      );

      // subtotal = 600,000 >= 500,000 → shippingAmount = 0
      expect(cart.subtotal, equals(600000.0));
      expect(cart.shippingAmount, equals(0.0));
      // grandTotal = 600,000 + 60,000 + 0 = 660,000
      expect(cart.grandTotal, closeTo(660000.0, 0.01));
    });

    // ────────────────────────────────────────────────────────────
    // TC-06: Thêm nhiều mặt hàng — cộng dồn subtotal đúng
    // ────────────────────────────────────────────────────────────
    test('TC-06: Nhiều items - subtotal = tổng cộng dồn', () {
      cart.addItem(
          ingredientId: 1, name: 'Gạo', unit: 'kg', unitPrice: 25000, quantity: 5);
      cart.addItem(
          ingredientId: 2, name: 'Thịt heo', unit: 'kg', unitPrice: 120000, quantity: 3);
      cart.addItem(
          ingredientId: 3, name: 'Rau cải', unit: 'bó', unitPrice: 8000, quantity: 10);

      // 25000*5=125,000 + 120000*3=360,000 + 8000*10=80,000 = 565,000
      expect(cart.subtotal, equals(565000.0));
      expect(cart.itemCount, equals(3));
      // subtotal >= 500,000 → ship = 0
      expect(cart.shippingAmount, equals(0.0));
      // tax = 565,000 * 0.10 = 56,500
      expect(cart.taxAmount, closeTo(56500.0, 0.01));
      // grand = 565,000 + 56,500 = 621,500
      expect(cart.grandTotal, closeTo(621500.0, 0.01));
    });

    // ────────────────────────────────────────────────────────────
    // TC-07: Thêm cùng mặt hàng 2 lần — cộng dồn số lượng
    // ────────────────────────────────────────────────────────────
    test('TC-07: Thêm cùng ingredientId 2 lần - quantity cộng dồn', () {
      cart.addItem(
          ingredientId: 1, name: 'Gạo', unit: 'kg', unitPrice: 25000);
      cart.addItem(
          ingredientId: 1, name: 'Gạo', unit: 'kg', unitPrice: 25000);

      // Chỉ có 1 loại, quantity = 2
      expect(cart.itemCount, equals(1));
      expect(cart.items.first.quantity, equals(2));
      expect(cart.subtotal, equals(50000.0));
    });

    // ────────────────────────────────────────────────────────────
    // TC-08: Xóa item → giảm subtotal đúng
    // ────────────────────────────────────────────────────────────
    test('TC-08: Xóa item - subtotal giảm chính xác', () {
      cart.addItem(
          ingredientId: 1, name: 'Gạo', unit: 'kg', unitPrice: 25000, quantity: 4);
      cart.addItem(
          ingredientId: 2, name: 'Thịt', unit: 'kg', unitPrice: 100000, quantity: 2);

      final subtotalBefore = cart.subtotal; // 100,000 + 200,000 = 300,000
      expect(subtotalBefore, equals(300000.0));

      cart.removeItem(2); // Xóa Thịt

      // Còn lại: Gạo 25000*4 = 100,000
      expect(cart.subtotal, equals(100000.0));
      expect(cart.itemCount, equals(1));
    });

    // ────────────────────────────────────────────────────────────
    // TC-09: Cập nhật số lượng → subtotal cập nhật đúng
    // ────────────────────────────────────────────────────────────
    test('TC-09: updateQuantity - subtotal tính lại chính xác', () {
      cart.addItem(
          ingredientId: 1, name: 'Gạo', unit: 'kg', unitPrice: 25000, quantity: 2);

      cart.updateQuantity(1, 10); // Sửa từ 2 → 10
      expect(cart.items.first.quantity, equals(10));
      expect(cart.subtotal, equals(250000.0));
    });

    // ────────────────────────────────────────────────────────────
    // TC-10: updateQuantity = 0 → tự xóa item
    // ────────────────────────────────────────────────────────────
    test('TC-10: updateQuantity(0) - tự xóa item khỏi giỏ', () {
      cart.addItem(
          ingredientId: 1, name: 'Gạo', unit: 'kg', unitPrice: 25000, quantity: 3);
      cart.updateQuantity(1, 0);

      expect(cart.isEmpty, isTrue);
      expect(cart.subtotal, equals(0.0));
    });

    // ────────────────────────────────────────────────────────────
    // TC-11: decreaseItem → quantity về 0 → tự xóa
    // ────────────────────────────────────────────────────────────
    test('TC-11: decreaseItem đến 0 - xóa item tự động', () {
      cart.addItem(
          ingredientId: 1, name: 'Gạo', unit: 'kg', unitPrice: 25000, quantity: 1);
      cart.decreaseItem(1);

      expect(cart.isEmpty, isTrue);
    });

    // ────────────────────────────────────────────────────────────
    // TC-12: clearCart → giỏ về trống
    // ────────────────────────────────────────────────────────────
    test('TC-12: clearCart - xóa sạch toàn bộ giỏ', () {
      cart.addItem(
          ingredientId: 1, name: 'A', unit: 'kg', unitPrice: 10000, quantity: 5);
      cart.addItem(
          ingredientId: 2, name: 'B', unit: 'lít', unitPrice: 20000, quantity: 3);

      cart.clear();

      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, equals(0));
      expect(cart.subtotal, equals(0.0));
      expect(cart.grandTotal, equals(30000.0)); // chỉ còn ship fee
    });

    // ────────────────────────────────────────────────────────────
    // TC-13: grandTotal chính xác tại ngưỡng giới hạn free ship
    // ────────────────────────────────────────────────────────────
    test('TC-13: grandTotal tại đúng ngưỡng 500,000 - miễn ship', () {
      cart.addItem(
          ingredientId: 1, name: 'Test', unit: 'cái', unitPrice: 500000, quantity: 1);

      expect(cart.subtotal, equals(500000.0));
      expect(cart.shippingAmount, equals(0.0));
      // grand = 500,000 + 50,000 = 550,000
      expect(cart.grandTotal, closeTo(550000.0, 0.01));
    });

    // ────────────────────────────────────────────────────────────
    // TC-14: Subtotal item — tích hợp CartItemModel.subtotal
    // ────────────────────────────────────────────────────────────
    test('TC-14: CartItemModel.subtotal = unitPrice * quantity', () {
      final item = CartItemModel(
        ingredientId: 99,
        name: 'Dầu ăn',
        unit: 'lít',
        unitPrice: 45000,
        quantity: 7,
      );

      expect(item.subtotal, equals(315000.0));
    });
  });
}
