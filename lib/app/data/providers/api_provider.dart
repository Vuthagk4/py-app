import 'dart:io';
import 'package:dio/dio.dart';

import '../../constant.dart';
import '../../services/storage_service.dart';

class APIProvider {
  /// using dio to talk with API

  final _dio = Dio(BaseOptions(
    baseUrl: kBaseURL,
    contentType: 'application/json',
    responseType: ResponseType.json,
    receiveTimeout: const Duration(minutes: 1),
    // 🟢 Ensures Laravel always returns clean JSON errors instead of HTML pages
    headers: {
      'Accept': 'application/json',
    },
    validateStatus: (status) {
      return status! < 500;
    },
  ));

  Future<Response> register({
    required String name,
    required String email,
    required String password,
    File? image,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        if (image != null)
          'avatar': await MultipartFile.fromFile(image.path, filename: image.path.split('/').last),
      });

      return await _dio.post("/register", data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    try {
      // 🟢 Uses standard JSON data instead of FormData for better Laravel compatibility
      return await _dio.post("/login", data: {
        'email': email,
        'password': password,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getProducts() async {
    try {
      return await _dio.get("/products");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> searchProduct({
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParameters = {
        if (search != null) 'name': search,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
      };

      return await _dio.get(
        '/product-search',
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getProductByCate({
    required int proId,
    required int pageNum,
  }) async {
    try {
      return await _dio.get('/product-cate/$proId?page=$pageNum');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getCartProducts() async {
    try {
      String? token = await StorageService.read(key: 'token');

      return await _dio.get(
        "/viewCart",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile({
    required String name,
    File? avatar,
  }) async {
    try {
      String? token = await StorageService.read(key: 'token');

      FormData formData = FormData.fromMap({
        'name': name,
      });

      if (avatar != null) {
        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(avatar.path, filename: avatar.path.split('/').last),
        ));
      }

      return await _dio.post(
        '/user/update',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addToCart({
    required int productId,
    required int quantity,
    required num price,
  }) async {
    try {
      String? token = await StorageService.read(key: 'token');

      return await _dio.post(
        '/cart',
        data: {
          'product_id': productId,
          'quantity': quantity,
          'price': price,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================
  // 🔴 CHECKOUT LOGIC WITH SANCTUM TOKEN
  // =========================================================
  Future<Response> checkoutOrder({
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    required int shopkeeperId, // 🟢 1. Add this requirement
  }) async {
    try {
      String? token = await StorageService.read(key: 'token');

      return await _dio.post(
        '/order/checkout',
        data: {
          'total_amount': totalAmount,
          'items': items,
          'shopkeeper_id': shopkeeperId, // 🟢 2. Send it to Laravel
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getOrders() async {
    try {
      String? token = await StorageService.read(key: 'token');

      return await _dio.get(
        '/orders',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}