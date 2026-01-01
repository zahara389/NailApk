import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config.dart';

class CartService {
  final Dio _dio;

  CartService(this._dio);

  // ===============================
  // ADD PRODUCT TO CART
  // POST /api/cart/add
  // ===============================
  Future<void> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final res = await _dio.post(
        '$apiPath/cart/add',
        data: {
          "product_id": productId,
          "quantity": quantity,
        },
      );

      debugPrint('Add to cart success: ${res.data}');
    } catch (e) {
      debugPrint('Add to cart failed: $e');
      rethrow;
    }
  }

  // ===============================
  // UPDATE CART ITEM
  // PUT /api/cart/item/{id}
  // ===============================
  Future<void> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      await _dio.put(
        '$apiPath/cart/item/$cartItemId',
        data: {
          "quantity": quantity,
        },
      );
    } catch (e) {
      debugPrint('Update cart failed: $e');
      rethrow;
    }
  }

  // ===============================
  // REMOVE CART ITEM
  // DELETE /api/cart/item/{id}
  // ===============================
  Future<void> removeCartItem(int cartItemId) async {
    try {
      await _dio.delete('$apiPath/cart/item/$cartItemId');
    } catch (e) {
      debugPrint('Remove cart item failed: $e');
      rethrow;
    }
  }

  // ===============================
  // CHECKOUT
  // POST /api/cart/checkout
  // ===============================
  Future<void> checkout() async {
    try {
      final res = await _dio.post('$apiPath/cart/checkout');
      debugPrint('Checkout response: ${res.data}');
    } catch (e) {
      debugPrint('Checkout failed: $e');
      rethrow;
    }
  }
}
