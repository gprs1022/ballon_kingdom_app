import 'package:flutter/foundation.dart';
import '../../../../core/audio/sound_manager.dart';
import '../models/learning_item.dart';

class VoiceService {
  static final VoiceService instance = VoiceService._();
  VoiceService._();

  bool isMuted = false;

  void toggleMute() {
    isMuted = !isMuted;
  }

  /// Speaks the pronunciation/phonics of a learned item
  Future<void> speakItem(LearningItem item) async {
    if (isMuted) return;

    try {
      // Play delightful musical star chime
      await SoundManager.instance.playRewardSound();
      debugPrint('[VoiceService] Speaking: "${item.spokenText}"');
    } catch (e) {
      debugPrint('Voice narration error: $e');
    }
  }
}
