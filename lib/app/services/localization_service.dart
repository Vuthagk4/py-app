import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('en', 'US');

  // Fallback locale if the selected one is missing
  static const fallbackLocale = Locale('en', 'US');

  // Languages supported
  static final langs = ['English', 'Khmer', 'Chinese'];
  static final locales = [
    const Locale('en', 'US'),
    const Locale('km', 'KH'),
    const Locale('zh', 'CN'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'profile': 'Profile',
      'personal_data': 'Personal Data',
      'shipping_address': 'Shipping Addresses',
      'order_history': 'Order History',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'sign_out': 'SIGN OUT',
      'orders': 'Orders',
    },
    'km_KH': {
      'profile': 'ប្រវត្តិរូប',
      'personal_data': 'ទិន្នន័យផ្ទាល់ខ្លួន',
      'shipping_address': 'អាសយដ្ឋានដឹកជញ្ជូន',
      'order_history': 'ប្រវត្តិបញ្ជាទិញ',
      'dark_mode': 'មុខងារងងឹត',
      'language': 'ភាសា',
      'sign_out': 'ចាកចេញ',
      'orders': 'ការកម្ម៉ង់',
    },
    'zh_CN': {
      'profile': '个人资料',
      'personal_data': '个人数据',
      'shipping_address': '收货地址',
      'order_history': '历史订单',
      'dark_mode': '深色模式',
      'language': '语言',
      'sign_out': '退出登录',
      'orders': '订单',
    },
  };

  // Logic to change language
  static void changeLoc(String lang) {
    final index = langs.indexOf(lang);
    if (index != -1) {
      Get.updateLocale(locales[index]);
    }
  }
}