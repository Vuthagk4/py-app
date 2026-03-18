import 'dart:io';
import 'package:dio/dio.dart';

import '../../constant.dart';
import '../../services/storage_service.dart';
import 'package:dio/dio.dart' as dio;

class APIProvider {
  /// using dio to talk with API

  final _dio = Dio(BaseOptions(
    baseUrl: kBaseURL,
    contentType: 'application/json',
    responseType: ResponseType.json,
    connectTimeout: const Duration(seconds: 30),  // 🟢 ADD
    sendTimeout: const Duration(seconds: 30),      // 🟢 ADD
    receiveTimeout: const Duration(minutes: 2),    // 🟢 increase from 1min to 2min
    headers: {
      'Accept': 'application/json',
    },
    validateStatus: (status) {
      return status! >= 200 && status! < 300;
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
      final response = await _dio.get("/products");

      print("STATUS: ${response.statusCode}");
      print("DATA: ${response.data}");

      return response;
    } catch (e) {
      print("ERROR: $e");
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
  // =========================================================
  // 🟢 FEEDBACK (REVIEWS) LOGIC
  // =========================================================

  // Fetch all feedback for the logged-in user
  Future<Response> getUserFeedback() async {
    try {
      String? token = await StorageService.read(key: 'token');

      return await _dio.get(
        '/user/feedback',
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

  // Submit new feedback for a specific product
  Future<Response> storeFeedback({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    try {
      String? token = await StorageService.read(key: 'token');

      return await _dio.post(
        '/feedback/store',
        data: {
          'product_id': productId,
          'rating': rating,
          'comment': comment,
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
  // 🟢 ADDRESS MANAGEMENT LOGIC
  // =========================================================

  // Fetch all address for the logged-in user
  // inside APIProvider class...

  // 🟢 Store a new addresses
  // This accepts the Map from AddressRequest.toJson()
  Future<Response> storeAddress(Map<String, dynamic> data) async {
    try {
      String? token = await StorageService.read(key: 'token');

      return await _dio.post(
        '/addresses',
        data: data, // Sending: {"message": "...", "addresses": {...}}
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


  // Delete an addresses
  Future<Response> deleteAddress(int addressId) async {
    try {
      String? token = await StorageService.read(key: 'token');

      return await _dio.delete(
        '/address/$addressId', // 🟢 RESTful delete route
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

  Future<Response> getAddress() async {
    try {
      String? token = await StorageService.read(key: 'token');
      return await _dio.get(
        "/address",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateAddress(int id, Map<String, dynamic> data) async {
    try {
      String? token = await StorageService.read(key: 'token');
      return await _dio.put(
        '/address/$id', // RESTful PUT route
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }
  Future<dio.Response> uploadOrderWithSlip(dio.FormData data) async {
    try {
      // 🟢 Read the token from storage
      String? token = await StorageService.read(key: 'token');

      return await _dio.post(
        '/orders/checkout-with-slip',
        data: data,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token', // 🟢 Added Required Token
            'Accept': 'application/json',
          },
        ),
      );
    } on dio.DioException catch (e) {
      rethrow;
    }
  }
  Future<Response> updateFcmToken(String fcmToken) async {
    try {
      String? token = await StorageService.read(key: 'token');

      return await _dio.post(
        '/user/fcm-token', // 🟢 Matches your Laravel route
        data: {
          'fcm_token': fcmToken,
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
  Future<Response> getChatMessages(int shopkeeperId) async {
    String? token = await StorageService.read(key: 'token');
    return await _dio.get('/chat/messages/$shopkeeperId',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> sendChatMessage(FormData data) async {
    String? token = await StorageService.read(key: 'token');
    return await _dio.post('/chat/send',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

// 🟢 Helper to get full image URL from your CentOS server
  String getImageUrl(String? path) {
    if (path == null) return "";
    return "$kBaseURL/storage/$path";
  }

  Future<Response> getNotifications() async {
    String? token = await StorageService.read(key: 'token');
    return await _dio.get('/notifications',
        options: Options(headers: {'Authorization': 'Bearer $token'})
    );
  }

  // 🟢 FIXED: Using _dio.post with the required headers
  Future<Response> markAsRead(String id) async {
    String? token = await StorageService.read(key: 'token');
    return await _dio.post(
      '/notifications/$id/read',
      data: {},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // 🟢 ADDED: Delete notification method
  Future<Response> deleteNotification(String id) async {
    String? token = await StorageService.read(key: 'token');
    return await _dio.delete(
      '/notifications/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // 🟢 ADDED: Mark all as read method
  Future<Response> markAllRead() async {
    String? token = await StorageService.read(key: 'token');
    return await _dio.post(
      '/notifications/mark-all-read',
      data: {},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> clearAllNotifications() async {
    try {
      String? token = await StorageService.read(key: 'token');

      return await _dio.post(
        '/notifications/clear-all', // 🟢 Matches your Laravel API route
        data: {},
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