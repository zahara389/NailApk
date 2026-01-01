import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config.dart';
import '../screens/all_products_screen.dart'; // untuk model Product

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                // 🔒 BASE URL DIKUNCI DI SINI
                baseUrl: apiBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  // ===========================================================================
  // GET /api/products
  // ===========================================================================
  Future<List<Product>> fetchProducts() async {
    try {
      final res = await _dio.get('$apiPath/products');

      if (res.statusCode == 200) {
        final dynamic rawData =
            (res.data is Map && res.data['data'] != null)
                ? res.data['data']
                : res.data;

        if (rawData is List) {
          return rawData
              .map(
                (e) => Product.fromApi(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint(
        'Gagal load products: ${e.response?.data ?? e.message}',
      );
      return [];
    } catch (e) {
      debugPrint('Unexpected error loading products: $e');
      return [];
    }
  }

  // ===========================================================================
  // POST /api/products
  // ===========================================================================
  Future<Product> createProduct(
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    try {
      final Response res;

      if (imagePath != null &&
          imagePath.isNotEmpty &&
          File(imagePath).existsSync()) {
        final form = FormData.fromMap({
          ...payload,
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split(Platform.pathSeparator).last,
          ),
        });

        res = await _dio.post(
          '$apiPath/products',
          data: form,
        );
      } else {
        res = await _dio.post(
          '$apiPath/products',
          data: payload,
        );
      }

      if (res.statusCode == 201 || res.statusCode == 200) {
        final json =
            (res.data is Map && res.data['data'] != null)
                ? Map<String, dynamic>.from(res.data['data'])
                : Map<String, dynamic>.from(res.data);

        return Product.fromApi(json);
      }

      throw Exception(
        'Gagal membuat produk: Status ${res.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Gagal membuat produk: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  // ===========================================================================
  // PUT /api/products/{id}
  // ===========================================================================
  Future<Product> updateProduct(
    int id,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    final path = '$apiPath/products/$id';

    try {
      final Response res;

      if (imagePath != null &&
          imagePath.isNotEmpty &&
          File(imagePath).existsSync()) {
        final form = FormData.fromMap({
          ...payload,
          '_method': 'PUT',
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split(Platform.pathSeparator).last,
          ),
        });

        res = await _dio.post(path, data: form);
      } else {
        res = await _dio.put(path, data: payload);
      }

      if (res.statusCode == 200) {
        final json =
            (res.data is Map && res.data['data'] != null)
                ? Map<String, dynamic>.from(res.data['data'])
                : Map<String, dynamic>.from(res.data);

        return Product.fromApi(json);
      }

      throw Exception(
        'Gagal memperbarui produk: Status ${res.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Gagal update produk: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  // ===========================================================================
  // DELETE /api/products/{id}
  // ===========================================================================
  Future<void> deleteProduct(int id) async {
    try {
      final res = await _dio.delete('$apiPath/products/$id');

      if (res.statusCode == 200 || res.statusCode == 204) return;

      throw Exception(
        'Gagal menghapus produk: Status ${res.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Gagal hapus produk: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }
}
