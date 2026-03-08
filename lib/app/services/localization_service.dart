import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('en', 'US');
  static const fallbackLocale = Locale('en', 'US');

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
      'account_section': 'Account Section',
      'activity_support': 'Activity & Support',
      'chat_with_shopkeeper': 'Chat with Shopkeeper',
      'help_center': 'Help Center',
      'type_message': 'Type a message...',
      'nav_home': 'Home',
      'nav_search': 'Search',
      'nav_cart': 'Cart',
      'nav_profile': 'Profile',
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
      'account_section': 'ផ្នែកគណនី',
      'activity_support': 'សកម្មភាព និងការគាំទ្រ',
      'chat_with_shopkeeper': 'ជជែកជាមួយអ្នកលក់',
      'help_center': 'មជ្ឈមណ្ឌលជំនួយ',
      'type_message': 'វាយសារនៅទីនេះ...',
      'nav_home': 'ទំព័រដើម',
      'nav_search': 'ស្វែងរក',
      'nav_cart': 'កន្ត្រកទំនិញ',
      'nav_profile': 'ប្រវត្តិរូប',
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
      'account_section': '账户部分',
      'activity_support': '活动与支持',
      'chat_with_shopkeeper': '与店主聊天',
      'help_center': '帮助中心',
      'type_message': '输入消息...',
      'nav_home': '首页',
      'nav_search': '搜索',
      'nav_cart': '购物车',
      'nav_profile': '个人中心',
    },
  };

  static void changeLoc(String lang) {
    final index = langs.indexOf(lang);
    if (index != -1) {
      Get.updateLocale(locales[index]);  // ✅ This handles rebuilding automatically
    }
  }

  static String getFontFamily() {
    // Ensure this returns a string matching your pubspec.yaml exactly
    String langCode = Get.locale?.languageCode ?? 'en';
    if (langCode == 'km') return 'KhmerMoul';
    if (langCode == 'zh') return 'ChineseFont';
    return 'EnglishFont';
  }

  static double getLineHeight() {
    String langCode = Get.locale?.languageCode ?? 'en';
    return langCode == 'km' ? 1.6 : 1.2;
  }
}