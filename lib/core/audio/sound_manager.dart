import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// SoundManager provides responsive sound effects.
/// Generates lightweight in-memory procedural audio PCM WAVs for instant,
/// offline, asset-free playback, while supporting external asset paths.
class SoundManager {
  static final SoundManager instance = SoundManager._();
  SoundManager._();

  AudioPlayer? _sfxPlayer;
  bool isMuted = false;

  Uint8List? _popWavBytes;
  Uint8List? _rewardWavBytes;

  Future<void> initialize() async {
    try {
      _sfxPlayer ??= AudioPlayer();
      _sfxPlayer?.setReleaseMode(ReleaseMode.stop);
      // Pre-synthesize joyful pop & chime tones so sound plays 100% offline
      _popWavBytes = _generatePopSoundWav();
      _rewardWavBytes = _generateChimeSoundWav();
    } catch (e) {
      debugPrint('SoundManager initialize error: $e');
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
  }

  Future<void> playPopSound({double pitch = 1.0}) async {
    if (isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      if (_popWavBytes != null) {
        await _sfxPlayer?.stop();
        await _sfxPlayer?.play(BytesSource(_popWavBytes!));
      }
    } catch (e) {
      debugPrint('Audio play pop note: $e');
    }
  }

  Future<void> playRewardSound() async {
    if (isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      if (_rewardWavBytes != null) {
        await _sfxPlayer?.stop();
        await _sfxPlayer?.play(BytesSource(_rewardWavBytes!));
      }
    } catch (e) {
      debugPrint('Audio play reward note: $e');
    }
  }

  /// Synthesizes a bubbly frequency-swept pop tone (440Hz -> 880Hz down to 220Hz exponential decay)
  Uint8List _generatePopSoundWav() {
    const int sampleRate = 22050;
    const double duration = 0.12; // 120ms quick pop
    final int numSamples = (sampleRate * duration).toInt();
    final ByteData byteData = ByteData(44 + numSamples * 2);

    // RIFF header
    _writeWavHeader(byteData, numSamples, sampleRate);

    // Samples
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double progress = i / numSamples;
      // Pitch envelope: frequency starts high then decays
      final double freq = 550 + 400 * math.sin(progress * math.pi) - 200 * progress;
      final double envelope = math.pow(1.0 - progress, 2.0).toDouble();
      final double sample = math.sin(2 * math.pi * freq * t) * envelope;
      final int sampleInt16 = (sample * 30000).clamp(-32768, 32767).toInt();
      byteData.setInt16(44 + i * 2, sampleInt16, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }

  /// Synthesizes a soft musical star chime
  Uint8List _generateChimeSoundWav() {
    const int sampleRate = 22050;
    const double duration = 0.35;
    final int numSamples = (sampleRate * duration).toInt();
    final ByteData byteData = ByteData(44 + numSamples * 2);

    _writeWavHeader(byteData, numSamples, sampleRate);

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double progress = i / numSamples;
      final double envelope = math.exp(-6 * progress);
      // Rich harmonic chime (C6 + E6 + G6)
      final double sample = (math.sin(2 * math.pi * 1046.5 * t) * 0.5 +
              math.sin(2 * math.pi * 1318.5 * t) * 0.3 +
              math.sin(2 * math.pi * 1567.9 * t) * 0.2) *
          envelope;
      final int sampleInt16 = (sample * 28000).clamp(-32768, 32767).toInt();
      byteData.setInt16(44 + i * 2, sampleInt16, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }

  void _writeWavHeader(ByteData b, int numSamples, int sampleRate) {
    const int channels = 1;
    const int bitsPerSample = 16;
    final int subChunk2Size = numSamples * channels * (bitsPerSample ~/ 8);
    final int chunkSize = 36 + subChunk2Size;

    // "RIFF"
    b.setUint8(0, 0x52);
    b.setUint8(1, 0x49);
    b.setUint8(2, 0x46);
    b.setUint8(3, 0x46);
    b.setUint32(4, chunkSize, Endian.little);
    // "WAVE"
    b.setUint8(8, 0x57);
    b.setUint8(9, 0x41);
    b.setUint8(10, 0x56);
    b.setUint8(11, 0x45);
    // "fmt "
    b.setUint8(12, 0x66);
    b.setUint8(13, 0x6D);
    b.setUint8(14, 0x74);
    b.setUint8(15, 0x20);
    b.setUint32(16, 16, Endian.little); // Subchunk1Size
    b.setUint16(20, 1, Endian.little); // PCM
    b.setUint16(22, channels, Endian.little);
    b.setUint32(24, sampleRate, Endian.little);
    b.setUint32(28, sampleRate * channels * (bitsPerSample ~/ 8), Endian.little);
    b.setUint16(32, channels * (bitsPerSample ~/ 8), Endian.little);
    b.setUint16(34, bitsPerSample, Endian.little);
    // "data"
    b.setUint8(36, 0x64);
    b.setUint8(37, 0x61);
    b.setUint8(38, 0x74);
    b.setUint8(39, 0x61);
    b.setUint32(40, subChunk2Size, Endian.little);
  }

  void dispose() {
    _sfxPlayer?.dispose();
  }
}
