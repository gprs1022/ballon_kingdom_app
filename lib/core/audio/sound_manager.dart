import 'dart:async';
import 'dart:io' show File;
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

/// SoundManager provides responsive, multi-platform sound effects and background music.
/// Uses dynamic in-storage device audio caching (`DeviceFileSource`), bundled assets,
/// and in-memory Web Audio (`BytesSource`).
/// Configured with `AndroidAudioFocus.none` globally and per-player so BGM NEVER
/// stops or stutters while popping balloons!
/// Automatically pauses BGM when the device enters sleep mode, screen turns off,
/// or app is backgrounded.
class SoundManager with WidgetsBindingObserver {
  static final SoundManager instance = SoundManager._();
  SoundManager._();

  final List<AudioPlayer> _sfxPlayers = [];
  int _currentSfxIndex = 0;
  static const int _sfxPoolSize = 4;

  AudioPlayer? _bgmPlayer;
  bool isMuted = false;
  bool isMusicMuted = false;
  double bgmVolume = 0.40;
  bool _isBgmPlaying = false;
  bool _bgmPausedBySleep = false;
  bool _isObserverRegistered = false;
  bool get isBgmPlaying => _bgmPlayer?.state == PlayerState.playing || _isBgmPlaying;

  String? _bgmFilePath;
  String? _popFilePath;
  String? _rewardFilePath;
  String? _hazardFilePath;
  final Map<int, String> _pitchedPopFilePaths = {};

  Uint8List? _popWavBytes;
  Uint8List? _rewardWavBytes;
  Uint8List? _hazardWavBytes;
  Uint8List? _joyfulBgmWavBytes;
  final Map<int, Uint8List> _pitchedPopWavs = {};

  // Pentatonic frequency multipliers for rapid musical pops
  static const List<double> pentatonicMultipliers = [
    1.0,      // Root (Do)
    1.122,    // Major 2nd (Re)
    1.260,    // Major 3rd (Mi)
    1.498,    // Perfect 5th (Sol)
    1.682,    // Major 6th (La)
    2.0,      // Octave (High Do)
  ];

  Future<void> initialize() async {
    try {
      // 1. Set GLOBAL AudioContext with AndroidAudioFocus.none so Android NEVER
      // ducks or pauses BGM when any other player plays a pop/reward sound!
      try {
        await AudioPlayer.global.setAudioContext(
          AudioContext(
            android: const AudioContextAndroid(
              isSpeakerphoneOn: false,
              stayAwake: false, // Don't hold CPU wake lock in sleep mode
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.game,
              audioFocus: AndroidAudioFocus.none,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.ambient, // Ambient pauses gracefully on sleep/lock
              options: const {},
            ),
          ),
        );
      } catch (e) {
        debugPrint('SoundManager global AudioContext config note: $e');
      }

      // Register lifecycle observer to automatically pause BGM on sleep / screen lock
      if (!_isObserverRegistered) {
        WidgetsBinding.instance.addObserver(this);
        _isObserverRegistered = true;
      }

      // 2. Initialize BGM player
      try {
        _bgmPlayer ??= AudioPlayer();
        unawaited(_bgmPlayer?.setReleaseMode(ReleaseMode.loop));
        unawaited(_bgmPlayer?.setVolume(bgmVolume));
        _bgmPlayer?.onPlayerStateChanged.listen((state) {
          _isBgmPlaying = (state == PlayerState.playing);
        });
      } catch (e) {
        debugPrint('SoundManager BGM player init note: $e');
      }

      // 3. Initialize SFX player pool
      _sfxPlayers.clear();
      for (int i = 0; i < _sfxPoolSize; i++) {
        try {
          final player = AudioPlayer();
          unawaited(player.setReleaseMode(ReleaseMode.stop));
          _sfxPlayers.add(player);
        } catch (e) {
          debugPrint('SoundManager SFX pool item note: $e');
        }
      }

      // 4. Synthesize procedural WAV bytes
      _popWavBytes = _generatePopSoundWav(pitchMultiplier: 1.0);
      _rewardWavBytes = _generateChimeSoundWav();
      _hazardWavBytes = _generateHazardSoundWav();
      _joyfulBgmWavBytes = _generateJoyfulBgmWav();

      for (int i = 0; i < pentatonicMultipliers.length; i++) {
        _pitchedPopWavs[i] = _generatePopSoundWav(pitchMultiplier: pentatonicMultipliers[i]);
      }

      // 5. On native devices (Android / iOS), cache WAVs to local temp directory
      await _ensureFilesCached();
    } catch (e) {
      debugPrint('SoundManager initialize error: $e');
    }
  }

  Future<void> _ensureFilesCached() async {
    if (kIsWeb) return;
    try {
      final tempDir = await getTemporaryDirectory();

      _joyfulBgmWavBytes ??= _generateJoyfulBgmWav();
      final bgmFile = File('${tempDir.path}/bgm_joyful.wav');
      if (!bgmFile.existsSync() || bgmFile.lengthSync() == 0) {
        bgmFile.writeAsBytesSync(_joyfulBgmWavBytes!);
      }
      _bgmFilePath = bgmFile.path;

      _popWavBytes ??= _generatePopSoundWav(pitchMultiplier: 1.0);
      final popFile = File('${tempDir.path}/pop.wav');
      if (!popFile.existsSync() || popFile.lengthSync() == 0) {
        popFile.writeAsBytesSync(_popWavBytes!);
      }
      _popFilePath = popFile.path;

      _rewardWavBytes ??= _generateChimeSoundWav();
      final chimeFile = File('${tempDir.path}/chime.wav');
      if (!chimeFile.existsSync() || chimeFile.lengthSync() == 0) {
        chimeFile.writeAsBytesSync(_rewardWavBytes!);
      }
      _rewardFilePath = chimeFile.path;

      _hazardWavBytes ??= _generateHazardSoundWav();
      final hazardFile = File('${tempDir.path}/hazard.wav');
      if (!hazardFile.existsSync() || hazardFile.lengthSync() == 0) {
        hazardFile.writeAsBytesSync(_hazardWavBytes!);
      }
      _hazardFilePath = hazardFile.path;

      for (int i = 0; i < pentatonicMultipliers.length; i++) {
        _pitchedPopWavs[i] ??= _generatePopSoundWav(pitchMultiplier: pentatonicMultipliers[i]);
        final pitchedFile = File('${tempDir.path}/pop_$i.wav');
        if (!pitchedFile.existsSync() || pitchedFile.lengthSync() == 0) {
          pitchedFile.writeAsBytesSync(_pitchedPopWavs[i]!);
        }
        _pitchedPopFilePaths[i] = pitchedFile.path;
      }
    } catch (e) {
      debugPrint('SoundManager _ensureFilesCached note: $e');
    }
  }

  AudioPlayer _getSfxPlayer() {
    if (_sfxPlayers.isEmpty) {
      final p = AudioPlayer();
      _sfxPlayers.add(p);
      return p;
    }
    final player = _sfxPlayers[_currentSfxIndex % _sfxPlayers.length];
    _currentSfxIndex++;
    return player;
  }

  void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      pauseBgm();
    } else {
      resumeBgm();
    }
  }

  Future<void> playPopSound({double pitch = 1.0, int? scaleDegree}) async {
    if (isMuted) return;
    try {
      final player = _getSfxPlayer();

      int? selectedDegree = scaleDegree;
      if (selectedDegree == null && pitch != 1.0) {
        int bestIdx = 0;
        double minDiff = (pentatonicMultipliers[0] - pitch).abs();
        for (int i = 1; i < pentatonicMultipliers.length; i++) {
          final diff = (pentatonicMultipliers[i] - pitch).abs();
          if (diff < minDiff) {
            minDiff = diff;
            bestIdx = i;
          }
        }
        selectedDegree = bestIdx;
      }

      unawaited(player.stop());

      final effectiveRate = (selectedDegree != null)
          ? pentatonicMultipliers[selectedDegree]
          : pitch;
      try {
        unawaited(player.setPlaybackRate(effectiveRate.clamp(0.5, 2.0)));
      } catch (_) {}

      // 1. On Android/iOS, use physical cached device file FIRST (100% reliable!)
      if (!kIsWeb) {
        if (selectedDegree != null &&
            _pitchedPopFilePaths.containsKey(selectedDegree) &&
            File(_pitchedPopFilePaths[selectedDegree]!).existsSync()) {
          unawaited(player.play(DeviceFileSource(_pitchedPopFilePaths[selectedDegree]!)).catchError((_) {}));
          return;
        } else if (_popFilePath != null && File(_popFilePath!).existsSync()) {
          unawaited(player.play(DeviceFileSource(_popFilePath!)).catchError((_) {}));
          return;
        }
      }

      // 2. Try bundled asset source
      try {
        unawaited(player.play(AssetSource('audio/pop.wav')).catchError((_) {}));
        return;
      } catch (_) {}

      // 3. Fallback to in-memory bytes
      final Uint8List? bytesToPlay = (selectedDegree != null)
          ? (_pitchedPopWavs[selectedDegree] ?? _popWavBytes)
          : _popWavBytes;
      if (bytesToPlay != null) {
        unawaited(player.play(BytesSource(bytesToPlay, mimeType: 'audio/wav')).catchError((_) {}));
      }
    } catch (e) {
      debugPrint('Audio play pop note: $e');
    }
  }

  Future<void> playHazardSound() async {
    if (isMuted) return;
    try {
      final player = _getSfxPlayer();
      unawaited(player.stop());
      try {
        unawaited(player.setPlaybackRate(1.0));
      } catch (_) {}

      // 1. On Android/iOS, use physical cached device file FIRST
      if (!kIsWeb && _hazardFilePath != null && File(_hazardFilePath!).existsSync()) {
        unawaited(player.play(DeviceFileSource(_hazardFilePath!)));
        return;
      }

      // 2. Try bundled asset source
      try {
        unawaited(player.play(AssetSource('audio/hazard.wav')));
        return;
      } catch (_) {}

      // 3. Fallback bytes
      if (_hazardWavBytes != null) {
        unawaited(player.play(BytesSource(_hazardWavBytes!, mimeType: 'audio/wav')));
      }
    } catch (e) {
      debugPrint('Audio play hazard note: $e');
    }
  }

  Future<void> playRewardSound() async {
    if (isMuted) return;
    try {
      final player = _getSfxPlayer();
      unawaited(player.stop());
      try {
        unawaited(player.setPlaybackRate(1.0));
      } catch (_) {}

      // 1. On Android/iOS, use physical cached device file FIRST
      if (!kIsWeb && _rewardFilePath != null && File(_rewardFilePath!).existsSync()) {
        unawaited(player.play(DeviceFileSource(_rewardFilePath!)).catchError((_) {}));
        return;
      }

      // 2. Try bundled asset source
      try {
        unawaited(player.play(AssetSource('audio/chime.wav')).catchError((_) {}));
        return;
      } catch (_) {}

      // 3. Fallback bytes
      if (_rewardWavBytes != null) {
        unawaited(player.play(BytesSource(_rewardWavBytes!, mimeType: 'audio/wav')).catchError((_) {}));
      }
    } catch (e) {
      debugPrint('Audio play reward note: $e');
    }
  }

  Future<void> startBgm() async {
    if (isMuted || isMusicMuted) return;
    if (_bgmPlayer?.state == PlayerState.playing) {
      try {
        unawaited(_bgmPlayer?.setVolume(bgmVolume));
      } catch (_) {}
      return;
    }

    try {
      _bgmPlayer ??= AudioPlayer();
      unawaited(_bgmPlayer?.setReleaseMode(ReleaseMode.loop));
      unawaited(_bgmPlayer?.setVolume(bgmVolume));

      // Ensure cache files exist on disk on mobile
      if (!kIsWeb && (_bgmFilePath == null || !File(_bgmFilePath!).existsSync())) {
        await _ensureFilesCached();
      }

      // 1. On Android/iOS, use physical cached device file FIRST!
      // This is 100% reliable on all Android versions and does not depend on APK asset bundling!
      if (!kIsWeb && _bgmFilePath != null && File(_bgmFilePath!).existsSync()) {
        try {
          unawaited(_bgmPlayer?.play(DeviceFileSource(_bgmFilePath!)).catchError((_) {}));
          _isBgmPlaying = true;
          return;
        } catch (e) {
          debugPrint('SoundManager DeviceFileSource BGM error: $e');
        }
      }

      // 2. Try bundled asset source
      try {
        unawaited(_bgmPlayer?.play(AssetSource('audio/bgm_joyful.wav')).catchError((_) {}));
        _isBgmPlaying = true;
        return;
      } catch (e) {
        debugPrint('SoundManager AssetSource BGM error: $e');
      }

      // 3. Fallback to in-memory bytes with explicit mimeType (for Web)
      _joyfulBgmWavBytes ??= _generateJoyfulBgmWav();
      if (_joyfulBgmWavBytes != null) {
        unawaited(_bgmPlayer?.play(BytesSource(_joyfulBgmWavBytes!, mimeType: 'audio/wav')).catchError((_) {}));
        _isBgmPlaying = true;
      }
    } catch (e) {
      debugPrint('SoundManager startBgm error: $e');
    }
  }

  Future<void> pauseBgm() async {
    try {
      _isBgmPlaying = false;
      unawaited(_bgmPlayer?.pause().catchError((_) {}));
    } catch (e) {
      debugPrint('SoundManager pauseBgm error: $e');
    }
  }

  Future<void> resumeBgm() async {
    if (isMuted || isMusicMuted) return;
    try {
      if (_bgmPlayer?.state == PlayerState.playing) return;
      _isBgmPlaying = true;
      unawaited(_bgmPlayer?.resume().catchError((_) {}));
    } catch (e) {
      debugPrint('SoundManager resumeBgm error: $e');
    }
  }

  Future<void> stopBgm() async {
    try {
      _isBgmPlaying = false;
      _bgmPausedBySleep = false;
      unawaited(_bgmPlayer?.stop().catchError((_) {}));
    } catch (e) {
      debugPrint('SoundManager stopBgm error: $e');
    }
  }

  /// Observes system lifecycle events: pauses BGM when device locks / sleeps or app
  /// goes to background, and resumes BGM when device wakes up / app resumes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Device sleep mode / screen turned off / app sent to background
        if (isBgmPlaying) {
          _bgmPausedBySleep = true;
          pauseBgm();
        }
        break;
      case AppLifecycleState.resumed:
        // Device unlocked / woke from sleep / app brought back to foreground
        if (_bgmPausedBySleep) {
          _bgmPausedBySleep = false;
          if (!isMuted && !isMusicMuted) {
            resumeBgm();
          }
        }
        break;
      case AppLifecycleState.detached:
        stopBgm();
        break;
    }
  }

  void setBgmVolume(double volume) {
    bgmVolume = volume.clamp(0.0, 1.0);
    try {
      _bgmPlayer?.setVolume(bgmVolume);
    } catch (_) {}
  }

  void toggleMusicMute() {
    isMusicMuted = !isMusicMuted;
    if (isMusicMuted) {
      pauseBgm();
    } else {
      resumeBgm();
    }
  }

  /// Synthesizes a joyful, uplifting 8-bar C Major Marimba & Chimes BGM loop (116 BPM)
  Uint8List _generateJoyfulBgmWav() {
    const int sampleRate = 22050;
    const double beatDur = 60.0 / 116.0; // 0.51724 s per beat at 116 BPM
    const int totalBeats = 32; // 8 bars of 4 beats
    final double totalDuration = totalBeats * beatDur;
    final int numSamples = (sampleRate * totalDuration).toInt();
    final Float32List mix = Float32List(numSamples);

    void addNote({
      required double startBeat,
      required double durationBeats,
      required double freq,
      required int instrument, // 0: bass, 1: marimba, 2: bell, 3: woodblock, 4: shaker
    }) {
      final int startSample = (startBeat * beatDur * sampleRate).toInt();
      final int noteSamples = (durationBeats * beatDur * sampleRate).toInt();
      final rng = math.Random(startSample + 17);

      for (int s = 0; s < noteSamples; s++) {
        final int targetIdx = startSample + s;
        if (targetIdx >= numSamples) break;
        final double t = s / sampleRate;

        double sample = 0.0;
        if (instrument == 0) {
          // Warm pizzicato bass (fundamental + soft 2nd harmonic)
          final double env = math.exp(-4.2 * t);
          sample = (math.sin(2 * math.pi * freq * t) * 0.72 +
                    math.sin(4 * math.pi * freq * t) * 0.28) *
              env *
              0.32;
        } else if (instrument == 1) {
          // Warm woody marimba mallet (fundamental + 3rd harmonic)
          final double env = math.exp(-6.8 * t);
          sample = (math.sin(2 * math.pi * freq * t) * 0.82 +
                    math.sin(6 * math.pi * freq * t) * 0.18) *
              env *
              0.34;
        } else if (instrument == 2) {
          // Sparkling glockenspiel / bell chime with gentle chorus
          final double env = math.exp(-3.8 * t);
          sample = (math.sin(2 * math.pi * freq * t) * 0.55 +
                    math.sin(2 * math.pi * (freq * 1.004) * t) * 0.25 +
                    math.sin(4 * math.pi * freq * t) * 0.20) *
              env *
              0.26;
        } else if (instrument == 3) {
          // Woodblock tap
          final double env = math.exp(-30.0 * t);
          sample = math.sin(2 * math.pi * 780.0 * t) * env * 0.16;
        } else if (instrument == 4) {
          // Soft whisper shaker
          final double env = math.exp(-42.0 * t);
          sample = (rng.nextDouble() * 2.0 - 1.0) * env * 0.07;
        }

        mix[targetIdx] += sample;
      }
    }

    // Note frequencies
    const double c3 = 130.81, d3 = 146.83, e3 = 164.81, f3 = 174.61, g3 = 196.00, a3 = 220.00, b3 = 246.94;
    const double c4 = 261.63, d4 = 293.66, e4 = 329.63, f4 = 349.23, g4 = 392.00, a4 = 440.00, b4 = 493.88;
    const double c5 = 523.25, d5 = 587.33, e5 = 659.25, f5 = 698.46, g5 = 783.99, b5 = 987.77, c6 = 1046.50;

    // 1. Bass Line (Roots on beats 1 and 3 of each bar)
    const List<double> bassNotes = [
      c3, g3, // Bar 0: C
      g3, d3, // Bar 1: G
      a3, e3, // Bar 2: Am
      f3, c3, // Bar 3: F
      c3, g3, // Bar 4: C
      g3, d3, // Bar 5: G
      f3, c3, // Bar 6: F
      g3, b3, // Bar 7: G turnaround
    ];
    for (int i = 0; i < bassNotes.length; i++) {
      addNote(
        startBeat: i * 2.0,
        durationBeats: 1.8,
        freq: bassNotes[i],
        instrument: 0,
      );
    }

    // 2. Marimba Arpeggios (8th-note bouncy flow: 8 steps per bar)
    const List<List<double>> barArps = [
      [c4, e4, g4, c5, g4, e4, c4, e4], // Bar 0: C
      [b3, d4, g4, b4, g4, d4, b3, d4], // Bar 1: G
      [a3, c4, e4, a4, e4, c4, a3, c4], // Bar 2: Am
      [f3, a3, c4, f4, c4, a3, f3, a3], // Bar 3: F
      [c4, e4, g4, c5, g4, e4, c4, e4], // Bar 4: C
      [b3, d4, g4, d5, b4, g4, d4, g4], // Bar 5: G
      [f3, a3, c4, a4, f4, c4, f3, a3], // Bar 6: F
      [g3, b3, d4, g4, b4, d5, g4, b4], // Bar 7: G turnaround
    ];
    for (int bar = 0; bar < 8; bar++) {
      final arp = barArps[bar];
      for (int step = 0; step < 8; step++) {
        addNote(
          startBeat: bar * 4.0 + step * 0.5,
          durationBeats: 0.48,
          freq: arp[step],
          instrument: 1,
        );
      }
    }

    // 3. Bell Chime Sparkles (Cheerful melodic accents)
    final List<Map<String, dynamic>> chimes = [
      {'b': 0.0, 'f': e5}, {'b': 2.0, 'f': g5},
      {'b': 4.0, 'f': d5}, {'b': 6.0, 'f': b4},
      {'b': 8.0, 'f': c5}, {'b': 10.0, 'f': e5},
      {'b': 12.0, 'f': a4}, {'b': 13.5, 'f': c5}, {'b': 14.0, 'f': f5},
      {'b': 16.0, 'f': g5}, {'b': 18.0, 'f': c5},
      {'b': 20.0, 'f': b4}, {'b': 21.5, 'f': d5}, {'b': 22.0, 'f': g5},
      {'b': 24.0, 'f': a4}, {'b': 26.0, 'f': c5},
      {'b': 28.0, 'f': d5}, {'b': 29.0, 'f': g5}, {'b': 30.0, 'f': b5}, {'b': 31.0, 'f': c6},
    ];
    for (final c in chimes) {
      addNote(
        startBeat: c['b'] as double,
        durationBeats: 1.2,
        freq: c['f'] as double,
        instrument: 2,
      );
    }

    // 4. Rhythm Percussion (Woodblock on 1 & 3 of every bar, Shaker on eighth notes)
    for (int beat = 0; beat < totalBeats; beat++) {
      if (beat % 2 == 1) {
        addNote(
          startBeat: beat.toDouble(),
          durationBeats: 0.3,
          freq: 780.0,
          instrument: 3,
        );
      }
      addNote(
        startBeat: beat.toDouble(),
        durationBeats: 0.25,
        freq: 0.0,
        instrument: 4,
      );
      addNote(
        startBeat: beat + 0.5,
        durationBeats: 0.25,
        freq: 0.0,
        instrument: 4,
      );
    }

    // Seamless crossfade on boundaries (first & last 20ms) to ensure smooth infinite looping
    final int fadeSamples = (sampleRate * 0.02).toInt();
    for (int i = 0; i < fadeSamples; i++) {
      final double factor = i / fadeSamples;
      mix[i] *= factor;
      mix[numSamples - 1 - i] *= factor;
    }

    // Write to 16-bit PCM WAV ByteData
    final ByteData byteData = ByteData(44 + numSamples * 2);
    _writeWavHeader(byteData, numSamples, sampleRate);
    for (int i = 0; i < numSamples; i++) {
      final int sampleInt16 = (mix[i] * 24000).clamp(-32768, 32767).toInt();
      byteData.setInt16(44 + i * 2, sampleInt16, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }

  /// Synthesizes a bubbly frequency-swept pop tone scaled by pitchMultiplier
  Uint8List _generatePopSoundWav({double pitchMultiplier = 1.0}) {
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
      final double baseFreq = 550 + 400 * math.sin(progress * math.pi) - 200 * progress;
      final double freq = baseFreq * pitchMultiplier;
      final double envelope = math.pow(1.0 - progress, 2.0).toDouble();
      final double sample = math.sin(2 * math.pi * freq * t) * envelope;
      final int sampleInt16 = (sample * 30000).clamp(-32768, 32767).toInt();
      byteData.setInt16(44 + i * 2, sampleInt16, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }

  /// Synthesizes a soft cartoon puff/thud sound for hazard/bomb balloons
  Uint8List _generateHazardSoundWav() {
    const int sampleRate = 22050;
    const double duration = 0.18; // 180ms low puff
    final int numSamples = (sampleRate * duration).toInt();
    final ByteData byteData = ByteData(44 + numSamples * 2);

    _writeWavHeader(byteData, numSamples, sampleRate);

    final rng = math.Random(42);
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double progress = i / numSamples;
      final double freq = 160.0 - 70.0 * progress;
      final double envelope = math.exp(-12 * progress);
      final double noise = (rng.nextDouble() * 2 - 1) * 0.25;
      final double sample = (math.sin(2 * math.pi * freq * t) * 0.75 + noise) * envelope;
      final int sampleInt16 = (sample * 26000).clamp(-32768, 32767).toInt();
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
    if (_isObserverRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _isObserverRegistered = false;
    }
    for (final p in _sfxPlayers) {
      p.dispose();
    }
    _sfxPlayers.clear();
    _bgmPlayer?.dispose();
  }
}
