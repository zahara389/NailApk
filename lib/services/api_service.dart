import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; 
import '../config.dart';
// Pastikan path model Product sudah benar
import '../screens/all_products_screen.dart'; 

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: apiBaseUrl, // Diambil dari config.dart (http://10.174.212.209:8000)
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  /// GET /api/products
  /// Mengambil daftar produk
  Future<List<Product>> fetchProducts() async {
    try {
      final res = await _dio.get('/api/products');

      if (res.statusCode == 200) {
        // Cek apakah data dibungkus dalam key 'data' (standar Laravel API Resource)
        // atau langsung berupa List
        final dynamic rawData = (res.data is Map && res.data['data'] != null) 
            ? res.data['data'] 
            : res.data;

        if (rawData is List) {
          return rawData
              .map((e) => Product.fromApi(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Gagal load products: ${e.response?.data ?? e.message}');
      return [];
    } catch (e) {
      debugPrint('Unexpected error loading products: $e');
      return [];
    }
  }

  /// POST /api/products
  /// Membuat produk baru (Mendukung upload gambar)
  Future<Product> createProduct(
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    try {
      final Response res;

      if (imagePath != null &&
          imagePath.isNotEmpty &&
          File(imagePath).existsSync()) {
        
        // Gunakan FormData untuk upload file
        final form = FormData.fromMap({
          ...payload,
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split(Platform.pathSeparator).last,
          ),
        });
        
        res = await _dio.post('/api/products', data: form);
      } else {
        // Kirim sebagai JSON biasa jika tidak ada gambar
        res = await _dio.post('/api/products', data: payload);
      }

      if (res.statusCode == 201 || res.statusCode == 200) {
        final json = (res.data is Map && res.data['data'] != null)
            ? Map<String, dynamic>.from(res.data['data'])
            : Map<String, dynamic>.from(res.data);

        return Product.fromApi(json);
      }
      throw Exception('Gagal membuat produk: Status ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception('Gagal membuat produk: ${e.response?.data['message'] ?? e.message}');
    }
  }

  /// PUT /api/products/{id}
  /// Memperbarui produk (Mendukung upload gambar ulang)
  Future<Product> updateProduct(
    int id,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    final path = '/api/products/$id';
    
    try {
      final Response res;

      if (imagePath != null &&
          imagePath.isNotEmpty &&
          File(imagePath).existsSync()) {
        
        // PENTING: Laravel PHP tidak bisa membaca PUT dengan Multipart secara langsung.
        // Kita gunakan POST tapi kita "akali" dengan method PUT agar dibaca Laravel.
        final form = FormData.fromMap({
          ...payload,
          '_method': 'PUT', // Memberitahu Laravel ini adalah request PUT
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split(Platform.pathSeparator).last,
          ),
        });

        res = await _dio.post(
          path,
          data: form,
        );
      } else {
        // Jika tidak ada gambar, gunakan PUT murni dengan JSON
        res = await _dio.put(path, data: payload);
      }

      if (res.statusCode == 200) {
        final json = (res.data is Map && res.data['data'] != null)
            ? Map<String, dynamic>.from(res.data['data'])
            : Map<String, dynamic>.from(res.data);

        return Product.fromApi(json);
      }
      throw Exception('Gagal memperbarui produk: Status ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception('Gagal update produk: ${e.response?.data['message'] ?? e.message}');
    }
  }

  /// DELETE /api/products/{id}
  Future<void> deleteProduct(int id) async {
    try {
      final res = await _dio.delete('/api/products/$id');
      if (res.statusCode == 200 || res.statusCode == 204) return;
      
      throw Exception('Gagal menghapus produk: Status ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception('Gagal hapus produk: ${e.response?.data['message'] ?? e.message}');
    }
  }
}