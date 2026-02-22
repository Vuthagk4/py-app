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
    receiveTimeout: Duration(minutes: 1),
    validateStatus: (status) {
      return status! < 500;
    },
  ));

  Future<Response> register(
      {required String name,
        required String email,
        required String password,
        File? image}) async {
    try {
      // print("image ${image!.path}");
      final _formData = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        'avatar':
        image != null ? await MultipartFile.fromFile(image.path) : null,
      });

      return await _dio.post("/register", data: _formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    try {
      final _formData = FormData.fromMap({
        'email': email,
        'password': password,
      });

      return await _dio.post("/login", data: _formData);
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

  Future<Response> searchProduct(
      {String? search, double? minPrice, double? maxPrice}) async {
    try {
      final queryParameters = {
        if (search != null) 'name': search,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
      };

      return await _dio.get(
        '/product-search',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getProductByCate(
      {required int proId, required int pageNum}) async {
    try {
      print("${_dio.get('/product-cate/${proId}?page=$pageNum')}");
      return await _dio.get(
        '/product-cate/${proId}?page=$pageNum',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getCartProducts() async {
    try {
      return await _dio.get(
        "/viewCart",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
            'Bearer ${await StorageService.read(key: 'token')}',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }



  // --- ADD THIS TO api_provider.dart ---
  Future<Response> updateProfile({required String name, File? avatar}) async {
    try {
      String? token = await StorageService.read(key: 'token');

      FormData formData = FormData.fromMap({
        'name': name,
        // '_method': 'PUT', // Uncomment if your Laravel route is a PUT request
      });

      if (avatar != null) {
        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(avatar.path, filename: avatar.path.split('/').last),
        ));
      }

      // Adjust '/user/update' to match your actual api.php route
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
  Future<Response> addToCart(
      {required int productId,
        required int quantity,
        required num price}) async {
    try {
      return await _dio.post(
        '/cart',
        data: {
          'product_id': productId,
          'quantity': quantity,
          'price': price,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
            'Bearer ${await StorageService.read(key: 'token')}',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
