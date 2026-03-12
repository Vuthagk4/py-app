import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  static const Color primary   = Color(0xFFFF3D57);
  static const Color dark      = Color(0xFF0D0D0D);
  static const Color surface   = Color(0xFF1A1A1A);
  static const Color cardBg    = Color(0xFF222222);
  static const Color inputBg   = Color(0xFF1E1E1E);
  static const Color muted     = Color(0xFF666666);
  static const Color dimText   = Color(0xFF999999);

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    final int shopId = (args is Map && args['shopId'] != null)
        ? args['shopId'] as int : 0;
    final String shopToken = (args is Map && args['shopToken'] != null)
        ? args['shopToken'] as String : '';
    final String shopName = (args is Map && args['shopName'] != null)
        ? args['shopName'] as String : 'Seller';

    controller.loadMessages(shopId);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: dark,
      appBar: _buildAppBar(shopName),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final m = controller.messages[index];
                  final isMe = m['sender_type'] == 'user';
                  final prevMsg = index > 0 ? controller.messages[index - 1] : null;
                  final showTimestamp = prevMsg == null ||
                      _shouldShowTimestamp(prevMsg['created_at'], m['created_at']);
                  return Column(
                    children: [
                      if (showTimestamp) _buildDateDivider(m['created_at']),
                      _buildBubble(m, isMe, context),
                    ],
                  );
                },
              );
            }),
          ),

          // Uploading indicator
          Obx(() => controller.isUploading.value
              ? Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            child: LinearProgressIndicator(
              backgroundColor: surface,
              valueColor: const AlwaysStoppedAnimation<Color>(primary),
            ),
          )
              : const SizedBox.shrink()),

          _buildInputArea(shopId, shopToken),
        ],
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(String shopName) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.07)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 15),
                  ),
                ),
                const SizedBox(width: 12),

                // Avatar
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF3D57), Color(0xFFFF6B35)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      shopName.isNotEmpty ? shopName[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Shop info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        shopName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 7, height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Online',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Call / info buttons
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.07)),
                  ),
                  child: const Icon(Icons.more_horiz_rounded,
                      color: Colors.white70, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: Colors.white24, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start the conversation below',
            style: TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── DATE DIVIDER ─────────────────────────────────────────────────────────
  Widget _buildDateDivider(String? timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.06))),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Text(
              _formatTimestamp(timestamp),
              style: const TextStyle(color: dimText, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.06))),
        ],
      ),
    );
  }

  // ─── BUBBLE ───────────────────────────────────────────────────────────────
  Widget _buildBubble(Map<String, dynamic> m, bool isMe, BuildContext context) {
    final hasImage = m['image_url'] != null;
    final time = _formatTime(m['created_at']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Seller avatar (left side only)
          if (!isMe) ...[
            Container(
              width: 30, height: 30,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3D57), Color(0xFFFF6B35)],
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.storefront_rounded,
                  color: Colors.white, size: 14),
            ),
          ],

          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.70,
              ),
              padding: hasImage
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? primary : cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: isMe
                    ? [BoxShadow(color: primary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
                border: isMe
                    ? null
                    : Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        controller.getImageUrl(m['image_url']),
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 200, height: 120,
                          color: surface,
                          child: const Icon(Icons.broken_image_rounded,
                              color: Colors.white24, size: 32),
                        ),
                      ),
                    )
                  else
                    Text(
                      m['message'] ?? '',
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.white.withOpacity(0.88),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                  // Timestamp
                  Padding(
                    padding: EdgeInsets.only(
                      top: hasImage ? 6 : 4,
                      left: hasImage ? 6 : 0,
                      right: hasImage ? 6 : 0,
                      bottom: hasImage ? 4 : 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            color: isMe
                                ? Colors.white.withOpacity(0.6)
                                : Colors.white.withOpacity(0.35),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.done_all_rounded,
                              size: 13,
                              color: Colors.white.withOpacity(0.6)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // "Me" spacer right side
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ─── INPUT AREA ───────────────────────────────────────────────────────────
  Widget _buildInputArea(int id, String token) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Image attach button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              controller.uploadImage(id, token);
            },
            child: Container(
              width: 44, height: 44,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Icon(Icons.image_outlined,
                  color: Colors.white54, size: 20),
            ),
          ),

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TextField(
                controller: controller.textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.sendTextMessage(id, token);
            },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3D57), Color(0xFFFF6B35)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  bool _shouldShowTimestamp(String? prev, String? current) {
    if (prev == null || current == null) return true;
    try {
      final a = DateTime.parse(prev);
      final b = DateTime.parse(current);
      return b.difference(a).inMinutes > 30;
    } catch (_) { return false; }
  }

  String _formatTimestamp(String? ts) {
    if (ts == null) return 'Today';
    try {
      final dt = DateTime.parse(ts).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Today';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
        return 'Yesterday';
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return 'Today'; }
  }

  String _formatTime(String? ts) {
    if (ts == null) return '';
    try {
      final dt = DateTime.parse(ts).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) { return ''; }
  }
}