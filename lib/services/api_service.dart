import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; 
import '../config.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  /// GET /api/products
  Future<List<Product>> fetchProducts() async {
    try {
      final res = await _dio.get('/api/products');

      if (res.statusCode == 200 && res.data is List) {
        final data = res.data as List;
        return data
            .map((e) => Product.fromApi(Map<String, dynamic>.from(e)))
            .toList();
      }

      // Non-200 tapi tidak throw → return kosong agar UI aman
      return [];
    } on DioException catch (e) {
      debugPrint('Gagal load products: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Unexpected error loading products: $e');
      return [];
    }
  }

  /// POST /api/products
  /// support JSON / multipart (jika imagePath ada)
  Future<Product> createProduct(
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
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
      res = await _dio.post('/api/products', data: form);
    } else {
      res = await _dio.post('/api/products', data: payload);
    }

    if (res.statusCode == 201 || res.statusCode == 200) {
      final json = (res.data is Map && res.data['data'] != null)
          ? Map<String, dynamic>.from(res.data['data'])
          : Map<String, dynamic>.from(res.data);

      return Product.fromApi(json);
    }

    throw Exception('Gagal membuat produk: ${res.statusCode}');
  }

  /// PUT /api/products/{id}
  Future<Product> updateProduct(
    int id,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    final path = '/api/products/$id';
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
        path,
        data: form,
        options: Options(method: 'PUT'),
      );
    } else {
      res = await _dio.put(path, data: payload);
    }

    if (res.statusCode == 200) {
      final json = (res.data is Map && res.data['data'] != null)
          ? Map<String, dynamic>.from(res.data['data'])
          : Map<String, dynamic>.from(res.data);

      return Product.fromApi(json);
    }

    throw Exception('Gagal memperbarui produk: ${res.statusCode}');
  }

  /// DELETE /api/products/{id}
  Future<void> deleteProduct(int id) async {
    final res = await _dio.delete('/api/products/$id');

    if (res.statusCode == 200) return;

    throw Exception('Gagal menghapus produk: ${res.statusCode}');
  }
}
