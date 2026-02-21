import 'package:haptic_feedback/haptic_feedback.dart';

class VibrateHelper {
  static void vibrateSoft() async {
    final canVibrate = await Haptics.canVibrate();
    if (!canVibrate) return;
    await Haptics.vibrate(HapticsType.soft);
  }
}
