import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../services/localization_service.dart';
import '../../Map_Shipping/MapPickerView.dart';
import '../../OrderHistory/controllers/order_history_controller.dart';
import '../../Wishlist/controllers/wishlist_controller.dart';
import '../../Wishlist/views/wishlist_view.dart';
import '../controllers/profile_controller.dart';
import '../../OrderHistory/views/order_history_view.dart';
import '../../help_support/views/help_support_view.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({super.key});

  // ── LIGHT palette ─────────────────────────────────────────
  static const _ltBg        = Color(0xFFF5F5F7);
  static const _ltSurface   = Color(0xFFFFFFFF);
  static const _ltCard      = Color(0xFFFFFFFF);
  static const _ltBorder    = Color(0xFFE8E8EE);
  static const _ltText      = Color(0xFF0D0D14);
  static const _ltSub       = Color(0xFF8A8A9A);
  static const _ltAccent    = Color(0xFFFF3D57);
  static const _ltAccentB   = Color(0xFFFF7A3D);
  static const _ltBlue      = Color(0xFF4A7BFF);
  static const _ltTeal      = Color(0xFF00B4AA);
  static const _ltAmber     = Color(0xFFFF9800);
  static const _ltPurple    = Color(0xFF9B59FF);
  static const _ltGreen     = Color(0xFF00B87A);
  static const _ltYellow    = Color(0xFFE6AC00);
  static const _ltDiamond   = Color(0xFF00A8CC);

  // ── DARK palette ──────────────────────────────────────────
  static const _dkBg        = Color(0xFF060608);
  static const _dkSurface   = Color(0xFF111116);
  static const _dkCard      = Color(0xFF1A1A22);
  static const _dkBorder    = Color(0xFF2C2C3A);
  static const _dkText      = Color(0xFFF0F0F8);
  static const _dkSub       = Color(0xFF5A5A70);
  static const _dkAccent    = Color(0xFFFF0033);
  static const _dkAccentB   = Color(0xFFFF5500);
  static const _dkBlue      = Color(0xFF4D79FF);
  static const _dkTeal      = Color(0xFF00F5D4);
  static const _dkAmber     = Color(0xFFFFAA00);
  static const _dkPurple    = Color(0xFFCC44FF);
  static const _dkGreen     = Color(0xFF00FF9D);
  static const _dkYellow    = Color(0xFFFFE000);
  static const _dkDiamond   = Color(0xFF00EEFF);

  @override
  Widget build(BuildContext context) {
    controller.fetchOrderStats();

    return Obx(() {
      final dk = controller.isDarkMode.value;

      // Resolve all colors
      final bg       = dk ? _dkBg      : _ltBg;
      final surface  = dk ? _dkSurface : _ltSurface;
      final card     = dk ? _dkCard    : _ltCard;
      final border   = dk ? _dkBorder  : _ltBorder;
      final text     = dk ? _dkText    : _ltText;
      final sub      = dk ? _dkSub     : _ltSub;
      final accent   = dk ? _dkAccent  : _ltAccent;
      final accentB  = dk ? _dkAccentB : _ltAccentB;
      final blue     = dk ? _dkBlue    : _ltBlue;
      final teal     = dk ? _dkTeal    : _ltTeal;
      final amber    = dk ? _dkAmber   : _ltAmber;
      final purple   = dk ? _dkPurple  : _ltPurple;
      final green    = dk ? _dkGreen   : _ltGreen;
      final yellow   = dk ? _dkYellow  : _ltYellow;
      final diamond  = dk ? _dkDiamond : _ltDiamond;

      SystemChrome.setSystemUIOverlayStyle(dk
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark);

      return Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            // ── Ambient blobs ──────────────────────────────
            Positioned(
              top: -80, left: -60,
              child: _blob(260, accent, dk ? 0.28 : 0.10),
            ),
            Positioned(
              top: 140, right: -80,
              child: _blob(220, accentB, dk ? 0.20 : 0.07),
            ),
            if (dk) ...[
              Positioned(
                bottom: 280, right: 10,
                child: _blob(180, purple, 0.16),
              ),
              Positioned(
                bottom: 80, left: -50,
                child: _blob(200, teal, 0.13),
              ),
            ],

            // ── Scroll content ────────────────────────────
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top bar
                  SliverToBoxAdapter(
                    child: _topBar(accent, text, border, card, dk),
                  ),
                  // Profile hero card
                  SliverToBoxAdapter(
                    child: _profileHero(
                        accent, accentB, text, sub, card, border, dk),
                  ),
                  // Stats
                  SliverToBoxAdapter(
                    child: _stats(accent, green, diamond,
                        text, sub, card, border, dk),
                  ),
                  // Menu sections
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel("MY ACCOUNT", sub),
                          const SizedBox(height: 12),
                          _menuCard(card, border, dk, [
                            _row(Icons.person_outline_rounded,
                                "personal_data".tr, blue, text, sub, card, dk,
                                onTap: () async {
                                  final r = await Get.toNamed('/edit-profile');
                                  if (r == true) controller.getUserData();
                                }),
                            _gap(border),
                            _row(Icons.map_outlined,
                                "shipping_address".tr, teal, text, sub, card, dk,
                                onTap: () async {
                                  final p = await Geolocator.requestPermission();
                                  if (p == LocationPermission.whileInUse ||
                                      p == LocationPermission.always) {
                                    await Get.to(() => const MapPickerView());
                                  }
                                }),
                            _gap(border),
                            _row(Icons.language_rounded,
                                "language".tr, amber, text, sub, card, dk,
                                onTap: () => _langSheet(
                                    card, border, text, sub, dk)),
                            _gap(border),
                            _switchRow(
                              Icons.dark_mode_outlined,
                              "dark_mode".tr,
                              purple,
                              text,
                              card,
                              dk,
                              dk,
                                  (v) => controller.toggleDarkMode(v),
                            ),
                          ]),

                          const SizedBox(height: 26),
                          _sectionLabel("ACTIVITY", sub),
                          const SizedBox(height: 12),
                          _menuCard(card, border, dk, [
                            _row(Icons.receipt_long_outlined,
                                "order_history".tr, accent, text, sub, card, dk,
                                onTap: () {
                                  Get.to(() {
                                    Get.put(OrderHistoryController());
                                    return const OrderHistoryView();
                                  });
                                }),
                            _gap(border),
                            _row(Icons.chat_bubble_outline_rounded,
                                "chat_with_shopkeeper".tr, green, text, sub,
                                card, dk,
                                onTap: () => Get.toNamed('/chat',
                                    arguments: {
                                      'shopId': 1,
                                      'shopToken': ''
                                    })),
                            _gap(border),
                            _row(Icons.help_outline_rounded,
                                "help_center".tr, yellow, text, sub, card, dk,
                                onTap: () =>
                                    Get.to(() => const HelpSupportView())),
                          ]),

                          const SizedBox(height: 32),
                          _logoutButton(accent, accentB, dk),
                          const SizedBox(height: 52),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── BLOB ─────────────────────────────────────────────────
  Widget _blob(double size, Color c, double opacity) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.withOpacity(opacity),
        ),
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────
  Widget _topBar(Color accent, Color text, Color border,
      Color card, bool dk) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _iconPill(Icons.arrow_back_ios_new_rounded,
                  () => Get.back(), text, card, border, dk),
          Text(
            "profile".tr,
            style: TextStyle(
              color: text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          _iconPill(Icons.notifications_outlined,
                  () {}, text, card, border, dk),
        ],
      ),
    );
  }

  Widget _iconPill(IconData icon, VoidCallback onTap,
      Color text, Color card, Color border, bool dk) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: border),
          boxShadow: dk
              ? []
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(icon, color: text, size: 17),
      ),
    );
  }

  // ── PROFILE HERO ─────────────────────────────────────────
  Widget _profileHero(Color accent, Color accentB, Color text,
      Color sub, Color card, Color border, bool dk) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: border),
          boxShadow: dk
              ? [
            BoxShadow(
              color: accent.withOpacity(0.10),
              blurRadius: 24,
            )
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            _avatar(accent, accentB, dk),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient:
                      LinearGradient(colors: [accent, accentB]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: dk
                          ? [
                        BoxShadow(
                          color: accent.withOpacity(0.35),
                          blurRadius: 10,
                        )
                      ]
                          : [],
                    ),
                    child: const Text(
                      "PREMIUM MEMBER",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Obx(() => Text(
                    controller.userName.value,
                    style: TextStyle(
                      color: text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    controller.userEmail.value,
                    style:
                    TextStyle(color: sub, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  )),
                  const SizedBox(height: 13),
                  GestureDetector(
                    onTap: () async {
                      final r = await Get.toNamed('/edit-profile');
                      if (r == true) controller.getUserData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(dk ? 0.14 : 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                            accent.withOpacity(dk ? 0.30 : 0.20)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined,
                              color: accent, size: 11),
                          const SizedBox(width: 5),
                          Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AVATAR ───────────────────────────────────────────────
  Widget _avatar(Color accent, Color accentB, bool dk) {
    return Obx(() {
      final url = controller.getImageUrl(controller.userImage.value);
      final uploading = controller.isUploading.value;

      return GestureDetector(
        onTap: uploading ? null : () => controller.pickAndUploadAvatar(),
        child: Stack(
          children: [
            Container(
              width: 86, height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [accent, accentB]),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(dk ? 0.55 : 0.30),
                    blurRadius: dk ? 24 : 14,
                  )
                ],
              ),
              padding: const EdgeInsets.all(2.5),
              child: ClipOval(
                child: Container(
                  color: dk
                      ? const Color(0xFF1A1A22)
                      : const Color(0xFFF0F0F5),
                  child: controller.userImage.value.isEmpty
                      ? Icon(Icons.person,
                      size: 42,
                      color: dk
                          ? Colors.white.withOpacity(0.3)
                          : Colors.black.withOpacity(0.2))
                      : Image.network(
                    url,
                    fit: BoxFit.cover,
                    key: ValueKey(url),
                    loadingBuilder: (ctx, child, prog) {
                      if (prog == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                            color: accent, strokeWidth: 2),
                      );
                    },
                    errorBuilder: (ctx, e, s) {
                      Future.delayed(
                          const Duration(milliseconds: 1500),
                              () {
                            if (Get.isRegistered<ProfileController>()) {
                              Get.find<ProfileController>()
                                  .retryImageLoad();
                            }
                          });
                      return Icon(Icons.person, size: 42,
                          color: dk
                              ? Colors.white.withOpacity(0.3)
                              : Colors.black.withOpacity(0.2));
                    },
                  ),
                ),
              ),
            ),
            if (uploading)
              Positioned.fill(
                child: ClipOval(
                  child: Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            if (!uploading)
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accent, accentB]),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: dk
                            ? const Color(0xFF1A1A22)
                            : Colors.white,
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(dk ? 0.5 : 0.25),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 11),
                ),
              ),
          ],
        ),
      );
    });
  }

  // ── STATS ────────────────────────────────────────────────
  Widget _stats(Color accent, Color green, Color diamond,
      Color text, Color sub, Color card, Color border, bool dk) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Obx(() => Row(
        children: [
          _statCard(
            controller.orderCount.value,
            "orders".tr,
            Icons.shopping_bag_outlined,
            accent, text, sub, card, border, dk,
            onTap: () {
              Get.to(() {
                Get.put(OrderHistoryController());
                return const OrderHistoryView();
              });
            },
          ),
          const SizedBox(width: 10),
          Obx(() {
            final w = Get.find<WishlistController>();
            return _statCard(
              "${w.count}", "wishlist".tr,
              Icons.bookmark_outline_rounded,
              green, text, sub, card, border, dk,
              onTap: () => Get.to(() => const WishlistView()),
            );
          }),
          const SizedBox(width: 10),
          _statCard("0", "points".tr,
              Icons.diamond_outlined,
              diamond, text, sub, card, border, dk),
        ],
      )),
    );
  }

  Widget _statCard(
      String val,
      String label,
      IconData icon,
      Color color,
      Color text,
      Color sub,
      Color card,
      Color border,
      bool dk, {
        VoidCallback? onTap,
      }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: dk
                    ? color.withOpacity(0.25)
                    : border),
            boxShadow: dk
                ? [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 16,
              )
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(dk ? 0.15 : 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(height: 8),
              Text(val,
                  style: TextStyle(
                      color: dk ? color : text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      color: sub,
                      fontSize: 10,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  // ── SECTION LABEL ────────────────────────────────────────
  Widget _sectionLabel(String t, Color sub) {
    return Text(t,
        style: TextStyle(
          color: sub,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
        ));
  }

  // ── MENU CARD ────────────────────────────────────────────
  Widget _menuCard(Color card, Color border, bool dk,
      List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: dk
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _row(
      IconData icon,
      String label,
      Color color,
      Color text,
      Color sub,
      Color card,
      bool dk, {
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(22),
        splashColor: color.withOpacity(0.07),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 18, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(dk ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: dk
                      ? [
                    BoxShadow(
                      color: color.withOpacity(0.22),
                      blurRadius: 8,
                    )
                  ]
                      : [],
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                      color: text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    )),
              ),
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(dk ? 0.12 : 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    color: color.withOpacity(dk ? 0.7 : 0.5),
                    size: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchRow(
      IconData icon,
      String label,
      Color color,
      Color text,
      Color card,
      bool dk,
      bool value,
      Function(bool) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 18, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(dk ? 0.16 : 0.10),
              borderRadius: BorderRadius.circular(12),
              boxShadow: dk
                  ? [
                BoxShadow(
                  color: color.withOpacity(0.22),
                  blurRadius: 8,
                )
              ]
                  : [],
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
          Transform.scale(
            scale: 0.82,
            child: Switch.adaptive(
              value: value,
              onChanged: (v) {
                HapticFeedback.lightImpact();
                onChanged(v);
              },
              activeColor: color,
              activeTrackColor: color.withOpacity(0.28),
              inactiveThumbColor:
              dk ? Colors.white.withOpacity(0.3) : Colors.grey,
              inactiveTrackColor: dk
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gap(Color border) {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
          height: 1, thickness: 0.5, color: border),
    );
  }

  // ── LOGOUT ───────────────────────────────────────────────
  Widget _logoutButton(Color accent, Color accentB, bool dk) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        controller.logout();
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, accentB],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(dk ? 0.40 : 0.25),
              blurRadius: dk ? 20 : 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              "sign_out".tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LANGUAGE SHEET ───────────────────────────────────────
  void _langSheet(Color card, Color border, Color text,
      Color sub, bool dk) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
        decoration: BoxDecoration(
          color: card,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(
              top: BorderSide(color: border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dk ? 0.5 : 0.12),
              blurRadius: 30,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Text("language".tr,
                style: TextStyle(
                    color: text,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text("Choose your preferred language",
                style: TextStyle(color: sub, fontSize: 13)),
            const SizedBox(height: 20),
            _langOption("🇺🇸", "English", "English",
                text, border, card, dk),
            _langOption("🇰🇭", "ភាសាខ្មែរ", "Khmer",
                text, border, card, dk),
            _langOption("🇨🇳", "中文", "Chinese",
                text, border, card, dk),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _langOption(String flag, String label,
      String value, Color text, Color border, Color card, bool dk) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        LocalizationService.changeLoc(value);
        Get.back();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: dk
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    color: text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: text.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }
}