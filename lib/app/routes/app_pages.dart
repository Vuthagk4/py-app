import 'package:get/get.dart';

import '../modules/CategoryDetail/bindings/category_detail_binding.dart';
import '../modules/CategoryDetail/views/category_detail_view.dart';
import '../modules/Chat/bindings/chat_binding.dart';
import '../modules/Chat/views/chat_view.dart';
import '../modules/EditAddress/bindings/edit_address_binding.dart';
import '../modules/EditAddress/views/edit_address_view.dart';
import '../modules/MyFeedbackView/bindings/my_feedback_view_binding.dart';
import '../modules/MyFeedbackView/views/my_feedback_view_view.dart';
import '../modules/Notification/bindings/notification_binding.dart';
import '../modules/Notification/views/notification_view.dart';
import '../modules/OrderHistory/bindings/order_history_binding.dart';
import '../modules/OrderHistory/views/order_history_view.dart';
import '../modules/OrderSuccessView/bindings/order_success_view_binding.dart';
import '../modules/OrderSuccessView/views/order_success_view_view.dart';
import '../modules/Wishlist/bindings/wishlist_binding.dart';
import '../modules/Wishlist/views/wishlist_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/edit-profile/bindings/edit_profile_binding.dart';
import '../modules/edit-profile/views/edit_profile_view.dart';
import '../modules/help_support/bindings/help_support_binding.dart';
import '../modules/help_support/views/help_support_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/privacy_policy/bindings/privacy_policy_binding.dart';
import '../modules/privacy_policy/views/privacy_policy_view.dart';
import '../modules/products/home/bindings/home_binding.dart';
import '../modules/products/home/views/home_view.dart';
import '../modules/products/product-detail/bindings/product_detail_binding.dart';
import '../modules/products/product-detail/views/product_detail_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/search-product/bindings/search_product_binding.dart';
import '../modules/search-product/views/search_product_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAIN;

  static final routes = [
    GetPage(
      name: _Paths.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH_PRODUCT,
      page: () => SearchProductView(),
      binding: SearchProductBinding(),
    ),
    GetPage(
      name: _Paths.CART,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_DETAIL,
      page: () => ProductDetailView(product: Get.arguments),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: _Paths.HELP_SUPPORT,
      page: () => const HelpSupportView(),
      binding: HelpSupportBinding(),
    ),
    GetPage(
      name: _Paths.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_HISTORY,
      page: () => const OrderHistoryView(),
      binding: OrderHistoryBinding(),
    ),
    GetPage(
      name: _Paths.CATEGORY_DETAIL,
      page: () => CategoryDetailView(), // No more 'category: null'
      binding: CategoryDetailBinding(),
    ),
    GetPage(
      name: _Paths.MY_FEEDBACK_VIEW,
      page: () => MyFeedbackView(),
      binding: MyFeedbackViewBinding(),
    ),

    GetPage(
      name: _Paths.EDIT_ADDRESS,
      page: () => const EditAddressView(),
      binding: EditAddressBinding(),
    ),
    // GetPage(
    //   name: _Paths.ADDRESS,
    //   page: () => const AddressView(),
    //   binding: AddressBinding(),
    // ),
    // GetPage(
    //   name: _Paths.ADD_ADDRESS,
    //   page: () => const AddAddressView(),
    //   binding: AddAddressBinding(),
    // ),
    GetPage(
      name: _Paths.ORDER_SUCCESS_VIEW,
      page: () => OrderSuccessView(),
      binding: OrderSuccessViewBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.WISHLIST,
      page: () => const WishlistView(),
      binding: WishlistBinding(),
    ),
  ];
}
