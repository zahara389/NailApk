import 'dart:convert';
import 'dart:typed_data'; // ✅ TAMBAHAN WAJIB

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nail_studio/services/api_service.dart';

/// Simple HttpClientAdapter to stub responses for Dio in tests.
class MockAdapter implements HttpClientAdapter {
  final Map<String, ResponseBody> responses;
  final Map<String, DioException> exceptions;

  MockAdapter({
    Map<String, ResponseBody>? responses,
    Map<String, DioException>? exceptions,
  })  : responses = responses ?? {},
        exceptions = exceptions ?? {};

  @override
  void close({bool force = false}) {}

  String _key(RequestOptions options) =>
      '${options.method.toUpperCase()} ${options.path}';

  // ✅ FIX SIGNATURE (Dio 5.x)
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    final key = _key(options);

    if (exceptions.containsKey(key)) {
      throw exceptions[key]!;
    }

    if (responses.containsKey(key)) {
      return responses[key]!;
    }

    // default 404
    return ResponseBody.fromString('', 404);
  }
}

void main() {
  group('ApiService', () {
    test('fetchProducts returns parsed products on 200', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.httpClientAdapter = MockAdapter(responses: {
        'GET /api/products': ResponseBody.fromString(
          jsonEncode([
            {'id': 1, 'name': 'Test Product', 'price': 15000}
          ]),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType]
          },
        ),
      });

      final api = ApiService(dio: dio);
      final list = await api.fetchProducts();

      expect(list, isNotEmpty);
      expect(list.first.id, 1);
      expect(list.first.name, 'Test Product');
      expect(list.first.price, 15000);
    });

    test('fetchProducts returns empty list on DioException', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.httpClientAdapter = MockAdapter(exceptions: {
        'GET /api/products': DioException(
          requestOptions: RequestOptions(path: '/api/products'),
        ),
      });

      final api = ApiService(dio: dio);
      final list = await api.fetchProducts();

      expect(list, isEmpty);
    });

    test('createProduct parses response when status 201 and data key present', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.httpClientAdapter = MockAdapter(responses: {
        'POST /api/products': ResponseBody.fromString(
          jsonEncode({
            'data': {'id': 10, 'name': 'New Prod', 'price': 20000}
          }),
          201,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType]
          },
        ),
      });

      final api = ApiService(dio: dio);
      final p =
          await api.createProduct({'namaproduct': 'ignored', 'price': 20000});

      expect(p.id, 10);
      expect(p.name, 'New Prod');
      expect(p.price, 20000);
    });

    test('createProduct throws on non-success status', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.httpClientAdapter = MockAdapter(responses: {
        'POST /api/products': ResponseBody.fromString('Bad', 400),
      });

      final api = ApiService(dio: dio);
      expect(
        api.createProduct({'namaproduct': 'x'}),
        throwsA(isA<Exception>()),
      );
    });

    test('updateProduct returns product on 200', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.httpClientAdapter = MockAdapter(responses: {
        'PUT /api/products/5': ResponseBody.fromString(
          jsonEncode({
            'data': {'id': 5, 'name': 'Updated', 'price': 30000}
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType]
          },
        ),
      });

      final api = ApiService(dio: dio);
      final p = await api.updateProduct(5, {'namaproduct': 'u'});

      expect(p.id, 5);
      expect(p.name, 'Updated');
    });

    test('updateProduct throws on non-200', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.httpClientAdapter = MockAdapter(responses: {
        'PUT /api/products/5': ResponseBody.fromString('Err', 500),
      });

      final api = ApiService(dio: dio);
      expect(api.updateProduct(5, {}), throwsA(isA<Exception>()));
    });

    test('deleteProduct succeeds on 200 and throws on non-200', () async {
      final dioOk = Dio(BaseOptions(baseUrl: 'http://test'));
      dioOk.httpClientAdapter = MockAdapter(responses: {
        'DELETE /api/products/4': ResponseBody.fromString('', 200),
      });

      final apiOk = ApiService(dio: dioOk);
      await apiOk.deleteProduct(4);

      final dioBad = Dio(BaseOptions(baseUrl: 'http://test'));
      dioBad.httpClientAdapter = MockAdapter(responses: {
        'DELETE /api/products/9': ResponseBody.fromString('', 404),
      });

      final apiBad = ApiService(dio: dioBad);
      expect(apiBad.deleteProduct(9), throwsA(isA<Exception>()));
    });
  });
}
