import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:khqrcode/khqrcode.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:confetti/confetti.dart';
import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  // ── Brand Colors ────────────────────────────────────────────────────────────
  static const Color _bg       = Color(0xFF0A0A0F);
  static const Color _surface  = Color(0xFF13131A);
  static const Color _card     = Color(0xFF1C1C26);
  static const Color _accent   = Color(0xFFFF5252);
  static const Color _accentB  = Color(0xFF7C5CFC);
  static const Color _gold     = Color(0xFFFFD166);
  static const Color _textPri  = Color(0xFFF0F0F5);
  static const Color _textSec  = Color(0xFF8585A0);
  static const Color _border   = Color(0xFF2A2A38);

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "https://via.placeholder.com/150";
    if (path.startsWith("http")) {
      return path
          .replaceAll('127.0.0.1', '10.0.2.2')
          .replaceAll('localhost', '10.0.2.2');
    }
    return "http://10.0.2.2/storage/$path";
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _bg,
      extendBody: true,
      body: Stack(
        children: [
          // ── Ambient glow background ──
          Positioned(
            top: -100, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentB.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200, left: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accent.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildOrderSummaryHeader(),
                        _buildProductList(context),
                        _buildLocationCard(context),
                        _buildPriceSummary(context),
                        const SizedBox(height: 160),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Confetti ──
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: controller.confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                _accent, _accentB, _gold,
                Colors.green, Colors.pink,
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCheckoutBar(context),
    );
  }

  // ─── APP BAR ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _textPri, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "My Bag",
              style: TextStyle(
                color: _textPri,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accent.withOpacity(0.25)),
            ),
            child: Text(
              "${controller.cartItems.length} items",
              style: const TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
          )),
        ],
      ),
    );
  }

  // ─── ORDER SUMMARY HEADER ──────────────────────────────────────────────────
  Widget _buildOrderSummaryHeader() {
    return Obx(() {
      if (controller.cartItems.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Row(
          children: [
            Container(
              width: 4, height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_accent, _accentB],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Order Items",
              style: TextStyle(
                color: _textSec,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── PRODUCT LIST ──────────────────────────────────────────────────────────
  Widget _buildProductList(BuildContext context) {
    return Obx(() {
      if (controller.cartItems.isEmpty) return _buildEmptyState();
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: controller.cartItems.length,
        itemBuilder: (context, index) {
          return _buildCartItem(context, controller.cartItems[index], index);
        },
      );
    });
  }

  // ─── CART ITEM ─────────────────────────────────────────────────────────────
  Widget _buildCartItem(BuildContext context, CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ── Product Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: getImageUrl(item.product.image),
                    width: 90, height: 90,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _accent),
                        ),
                      ),
                    ),
                    errorWidget: (c, u, e) => Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: _textSec, size: 26),
                    ),
                  ),
                ),
                // Size pill overlay on image
                if (item.size != null && item.size!.isNotEmpty)
                  Positioned(
                    bottom: 5, left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.size!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Product Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name ?? "Product",
                    style: const TextStyle(
                      color: _textPri,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "\$${item.product.price}",
                        style: const TextStyle(
                          color: _accent,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "each",
                        style: TextStyle(
                          color: _textSec,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Qty controls ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          children: [
                            _qtyButton(
                              icon: Icons.remove_rounded,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                controller.decreaseQuantity(index);
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14),
                              child: Text(
                                "${item.quantity}",
                                style: const TextStyle(
                                  color: _textPri,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _qtyButton(
                              icon: Icons.add_rounded,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                controller.increaseQuantity(index);
                              },
                              isAdd: true,
                            ),
                          ],
                        ),
                      ),

                      // Delete button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          controller.removeItem(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _accent.withOpacity(0.2)),
                          ),
                          child: const Icon(
                              Icons.delete_outline_rounded,
                              color: _accent, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isAdd = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: isAdd ? _accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 16,
            color: isAdd ? _accent : _textSec),
      ),
    );
  }

  // ─── LOCATION CARD ─────────────────────────────────────────────────────────
  Widget _buildLocationCard(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: () => controller.openMapPicker(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: controller.pickedLocation.value != null
                ? Colors.green.withOpacity(0.4)
                : _border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: controller.pickedLocation.value != null
                      ? [
                    Colors.green.withOpacity(0.3),
                    Colors.green.withOpacity(0.1),
                  ]
                      : [
                    _accentB.withOpacity(0.3),
                    _accentB.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                controller.pickedLocation.value != null
                    ? Icons.location_on_rounded
                    : Icons.add_location_alt_outlined,
                color: controller.pickedLocation.value != null
                    ? Colors.green
                    : _accentB,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Delivery Location",
                    style: TextStyle(
                      color: _textPri,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    controller.pickedLocation.value == null
                        ? "Tap to pin your location on map"
                        : controller.pickedAddressName.value.isNotEmpty
                        ? controller.pickedAddressName.value
                        : "Location selected ✅",
                    style: TextStyle(
                      color: controller.pickedLocation.value == null
                          ? _accent
                          : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: _textSec,
              size: 20,
            ),
          ],
        ),
      ),
    ));
  }

  // ─── PRICE SUMMARY ─────────────────────────────────────────────────────────
  Widget _buildPriceSummary(BuildContext context) {
    return Obx(() {
      if (controller.cartItems.isEmpty) return const SizedBox.shrink();
      final total = controller.totalCartPrice;
      const shipping = 0.0;
      final grand = total + shipping;

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Order Summary",
                  style: TextStyle(
                    color: _textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _gold.withOpacity(0.25)),
                  ),
                  child: Text(
                    "${controller.cartItems.length} items",
                    style: const TextStyle(
                        color: _gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _summaryRow("Subtotal", "\$${total.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            _summaryRow("Shipping", "Free", valueColor: Colors.green),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Container(height: 1, color: _border),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    color: _textPri,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  "\$${grand.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryRow(String label, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: _textSec, fontSize: 13)),
        Text(value,
            style: TextStyle(
              color: valueColor ?? _textPri,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }

  // ─── CHECKOUT BAR ──────────────────────────────────────────────────────────
  Widget _buildCheckoutBar(BuildContext context) {
    return Obx(() {
      if (controller.cartItems.isEmpty) return const SizedBox.shrink();
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: _surface.withOpacity(0.95),
              border: Border(
                  top: BorderSide(color: _border, width: 1)),
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _showPaymentSheet(context);
              },
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    const Text(
                      "Proceed to Checkout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "\$${controller.totalCartPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // ─── PAYMENT SHEET ─────────────────────────────────────────────────────────
  void _showPaymentSheet(BuildContext context) {
    final bakongKhqr = BakongKHQR();
    final individualInfo = IndividualInfo(
      bakongAccountId: 'your_id@acleda',
      merchantName: 'Phnom Penh Store',
      merchantCity: 'Phnom Penh',
      amount: controller.totalCartPrice,
      currency: KHQRDataConst.currency['usd']!,
    );

    final result = bakongKhqr.generateIndividual(individualInfo);
    final String khqrString = result.data?.qr ?? "";
    final phoneController =
    TextEditingController(text: controller.customerPhone.value);

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 20),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.verified_user_rounded,
                        color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Secure Payment",
                        style: TextStyle(
                          color: _textPri,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "Scan KHQR to pay",
                        style: TextStyle(
                            color: _textSec, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Phone field
              Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                      color: _textPri, fontWeight: FontWeight.w600),
                  onChanged: (v) =>
                  controller.customerPhone.value = v,
                  decoration: InputDecoration(
                    hintText: "Your phone number",
                    hintStyle: const TextStyle(
                        color: _textSec, fontSize: 13),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _accentB.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.phone_rounded,
                          color: _accentB, size: 16),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // QR code
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _accentB.withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: khqrString,
                      version: QrVersions.auto,
                      size: 180,
                      eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.circle,
                          color: Color(0xFF0A0A0F)),
                      dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: Color(0xFF0A0A0F)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Scan with any Bakong-supported bank app",
                      style: TextStyle(
                          color: Color(0xFF666680),
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Steps
              _buildSteps(context),
              const SizedBox(height: 20),

              // Slip preview
              Obx(() => _buildSlipPreview(context)),
              const SizedBox(height: 16),

              // Button
              _buildCheckoutButton(),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ─── STEPS ─────────────────────────────────────────────────────────────────
  Widget _buildSteps(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _step(
            icon: Icons.account_balance_rounded,
            label: "Open Bank",
            color: _accentB,
            isActive: controller.selectedSlip.value == null,
            onTap: () => controller.openBankingApp(),
          ),
          _stepConnector(),
          _step(
            icon: Icons.camera_alt_rounded,
            label: "Capture",
            color: _accent,
            isActive: controller.selectedSlip.value != null,
            onTap: () => controller.capturePaymentSlip(),
          ),
          _stepConnector(),
          _step(
            icon: Icons.cloud_upload_rounded,
            label: "Upload",
            color: Colors.green,
            isActive: controller.isLoading.value,
            onTap: null,
          ),
        ],
      ),
    ));
  }

  Widget _step({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? color.withOpacity(0.15)
                  : _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? color.withOpacity(0.4)
                    : _border,
              ),
            ),
            child: Icon(icon,
                size: 22,
                color: isActive ? color : _textSec),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? color : _textSec,
              )),
        ],
      ),
    );
  }

  Widget _stepConnector() => Expanded(
    child: Container(
      height: 1,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_border, _border.withOpacity(0.3)],
        ),
      ),
    ),
  );

  // ─── SLIP PREVIEW ──────────────────────────────────────────────────────────
  Widget _buildSlipPreview(BuildContext context) {
    if (controller.selectedSlip.value == null) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(controller.selectedSlip.value!.path),
            width: 52, height: 52, fit: BoxFit.cover,
          ),
        ),
        title: const Text("Slip Attached ✅",
            style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
        subtitle: const Text("Tap × to remove",
            style: TextStyle(color: _textSec, fontSize: 11)),
        trailing: GestureDetector(
          onTap: () => controller.selectedSlip.value = null,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.close_rounded,
                color: _accent, size: 16),
          ),
        ),
      ),
    );
  }

  // ─── CHECKOUT BUTTON ───────────────────────────────────────────────────────
  Widget _buildCheckoutButton() {
    return Obx(() => GestureDetector(
      onTap: controller.isLoading.value
          ? null
          : (controller.selectedSlip.value == null
          ? () => controller.pickPaymentSlip()
          : () => controller.processPaymentSuccess()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: controller.selectedSlip.value == null
                ? [const Color(0xFF7C5CFC), const Color(0xFF5A3FD4)]
                : [Colors.green.shade500, Colors.green.shade700],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (controller.selectedSlip.value == null
                  ? _accentB
                  : Colors.green)
                  .withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: controller.isLoading.value
              ? const SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.selectedSlip.value == null
                    ? Icons.upload_rounded
                    : Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                controller.selectedSlip.value == null
                    ? "Upload Payment Slip"
                    : "Complete Purchase",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  // ─── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: _card,
              shape: BoxShape.circle,
              border: Border.all(color: _border),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                size: 44, color: _textSec),
          ),
          const SizedBox(height: 20),
          const Text(
            "Your bag is empty",
            style: TextStyle(
              color: _textPri,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add items to start shopping",
            style: TextStyle(color: _textSec, fontSize: 14),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_accent, Color(0xFFFF1744)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                "Browse Products",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}