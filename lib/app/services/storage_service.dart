import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 🟢 FIXED: Accept dynamic and convert to String
  static Future<void> write({required String key, required dynamic value}) async {
    await _storage.write(key: key, value: value.toString());
  }

  static Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }
}
