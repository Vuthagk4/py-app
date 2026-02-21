import 'dart:io';

import 'package:dio/dio.dart';

import '../../constant/constant.dart';

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
}
