import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config.dart';

class CartService {
  final Dio _dio;

  CartService(this._dio);

  // =========================================================
  // ADD PRODUCT TO CART
  // POST /api/cart/add
  // =========================================================
  Future<void> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final res = await _dio.post(
        '$apiPath/cart/add',
        data: {
          'product_id': productId,
          'quantity': quantity,
        },
      );

      debugPrint('✅ Add to cart success: ${res.data}');
    } catch (e) {
      debugPrint('❌ Add to cart failed: $e');
      rethrow;
    }
  }

  // =========================================================
  // GET CART (AMBIL DARI DATABASE)
  // GET /api/cart
  // =========================================================
  Future<List<CartItem>> fetchCart() async {
    try {
      final res = await _dio.get('$apiPath/cart');

      final List items = res.data['items'] ?? [];

      return items.map<CartItem>((e) {
        return CartItem(
          id: e['id'], // 🔥 cart_items.id (WAJIB)
          quantity: e['quantity'] ?? 1,
          product: Product.fromApi(e['product']),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Fetch cart failed: $e');
      return [];
    }
  }

  // =========================================================
  // UPDATE CART ITEM
  // PUT /api/cart/item/{cartItemId}
  // =========================================================
  Future<void> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      await _dio.put(
        '$apiPath/cart/item/$cartItemId',
        data: {
          'quantity': quantity,
        },
      );

      debugPrint('✅ Update cart item success');
    } catch (e) {
      debugPrint('❌ Update cart failed: $e');
      rethrow;
    }
  }

  // =========================================================
  // REMOVE CART ITEM
  // DELETE /api/cart/item/{cartItemId}
  // =========================================================
  Future<void> removeCartItem(int cartItemId) async {
    try {
      await _dio.delete('$apiPath/cart/item/$cartItemId');
      debugPrint('✅ Remove cart item success');
    } catch (e) {
      debugPrint('❌ Remove cart item failed: $e');
      rethrow;
    }
  }

  // =========================================================
  // CHECKOUT
  // POST /api/cart/checkout
  // =========================================================
  Future<PurchaseHistory> checkout({required int itemsCount}) async {
    try {
      final res = await _dio.post('$apiPath/cart/checkout');

      final dynamic payload = res.data;
      final dynamic data = payload is Map ? payload['data'] : null;

      final orderNumber = (data is Map ? data['order_number'] : null)?.toString() ??
          'ORD${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';

      final rawStatus = (data is Map ? data['order_status'] : null)?.toString() ?? 'Processing';
      final status = rawStatus == 'Pending' ? 'Processing' : rawStatus;

      final totalAmountNum = (data is Map ? data['total_amount'] : null);
      final totalAmount = (totalAmountNum is num) ? totalAmountNum.round() : 0;

      final today = DateTime.now();
      final date = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final newOrder = PurchaseHistory(
        id: orderNumber,
        date: date,
        total: totalAmount,
        status: status,
        items: itemsCount,
      );

      debugPrint('✅ Checkout success: ${res.data}');
      return newOrder;
    } catch (e) {
      debugPrint('❌ Checkout failed: $e');
      rethrow;
    }
  }
}
