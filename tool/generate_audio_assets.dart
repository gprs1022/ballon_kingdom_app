// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main() async {
  final dir = Directory('assets/audio');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  print('Generating bgm_joyful.wav...');
  final bgmBytes = generateJoyfulBgmWav();
  File('assets/audio/bgm_joyful.wav').writeAsBytesSync(bgmBytes);

  print('Generating pop.wav...');
  final popBytes = generatePopSoundWav(pitchMultiplier: 1.0);
  File('assets/audio/pop.wav').writeAsBytesSync(popBytes);

  print('Generating chime.wav...');
  final chimeBytes = generateChimeSoundWav();
  File('assets/audio/chime.wav').writeAsBytesSync(chimeBytes);

  print('Generating hazard.wav...');
  final hazardBytes = generateHazardSoundWav();
  File('assets/audio/hazard.wav').writeAsBytesSync(hazardBytes);

  print('Successfully generated all audio assets in assets/audio/ !');
}

void writeWavHeader(ByteData b, int numSamples, int sampleRate) {
  const int channels = 1;
  const int bitsPerSample = 16;
  final int subChunk2Size = numSamples * channels * (bitsPerSample ~/ 8);
  final int chunkSize = 36 + subChunk2Size;

  b.setUint8(0, 0x52);
  b.setUint8(1, 0x49);
  b.setUint8(2, 0x46);
  b.setUint8(3, 0x46);
  b.setUint32(4, chunkSize, Endian.little);
  b.setUint8(8, 0x57);
  b.setUint8(9, 0x41);
  b.setUint8(10, 0x56);
  b.setUint8(11, 0x45);
  b.setUint8(12, 0x66);
  b.setUint8(13, 0x6D);
  b.setUint8(14, 0x74);
  b.setUint8(15, 0x20);
  b.setUint32(16, 16, Endian.little);
  b.setUint16(20, 1, Endian.little);
  b.setUint16(22, channels, Endian.little);
  b.setUint32(24, sampleRate, Endian.little);
  b.setUint32(28, sampleRate * channels * (bitsPerSample ~/ 8), Endian.little);
  b.setUint16(32, channels * (bitsPerSample ~/ 8), Endian.little);
  b.setUint16(34, bitsPerSample, Endian.little);
  b.setUint8(36, 0x64);
  b.setUint8(37, 0x61);
  b.setUint8(38, 0x74);
  b.setUint8(39, 0x61);
  b.setUint32(40, subChunk2Size, Endian.little);
}

Uint8List generateJoyfulBgmWav() {
  const int sampleRate = 22050;
  const double beatDur = 60.0 / 116.0;
  const int totalBeats = 32;
  final double totalDuration = totalBeats * beatDur;
  final int numSamples = (sampleRate * totalDuration).toInt();
  final Float32List mix = Float32List(numSamples);

  void addNote({
    required double startBeat,
    required double durationBeats,
    required double freq,
    required int instrument,
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
        final double env = math.exp(-4.2 * t);
        sample = (math.sin(2 * math.pi * freq * t) * 0.72 +
                  math.sin(4 * math.pi * freq * t) * 0.28) *
            env *
            0.32;
      } else if (instrument == 1) {
        final double env = math.exp(-6.8 * t);
        sample = (math.sin(2 * math.pi * freq * t) * 0.82 +
                  math.sin(6 * math.pi * freq * t) * 0.18) *
            env *
            0.34;
      } else if (instrument == 2) {
        final double env = math.exp(-3.8 * t);
        sample = (math.sin(2 * math.pi * freq * t) * 0.55 +
                  math.sin(2 * math.pi * (freq * 1.004) * t) * 0.25 +
                  math.sin(4 * math.pi * freq * t) * 0.20) *
            env *
            0.26;
      } else if (instrument == 3) {
        final double env = math.exp(-30.0 * t);
        sample = math.sin(2 * math.pi * 780.0 * t) * env * 0.16;
      } else if (instrument == 4) {
        final double env = math.exp(-42.0 * t);
        sample = (rng.nextDouble() * 2.0 - 1.0) * env * 0.07;
      }

      mix[targetIdx] += sample;
    }
  }

  const double c3 = 130.81, d3 = 146.83, e3 = 164.81, f3 = 174.61, g3 = 196.00, a3 = 220.00, b3 = 246.94;
  const double c4 = 261.63, d4 = 293.66, e4 = 329.63, f4 = 349.23, g4 = 392.00, a4 = 440.00, b4 = 493.88;
  const double c5 = 523.25, d5 = 587.33, e5 = 659.25, f5 = 698.46, g5 = 783.99, b5 = 987.77, c6 = 1046.50;

  const List<double> bassNotes = [
    c3, g3,
    g3, d3,
    a3, e3,
    f3, c3,
    c3, g3,
    g3, d3,
    f3, c3,
    g3, b3,
  ];
  for (int i = 0; i < bassNotes.length; i++) {
    addNote(
      startBeat: i * 2.0,
      durationBeats: 1.8,
      freq: bassNotes[i],
      instrument: 0,
    );
  }

  const List<List<double>> barArps = [
    [c4, e4, g4, c5, g4, e4, c4, e4],
    [b3, d4, g4, b4, g4, d4, b3, d4],
    [a3, c4, e4, a4, e4, c4, a3, c4],
    [f3, a3, c4, f4, c4, a3, f3, a3],
    [c4, e4, g4, c5, g4, e4, c4, e4],
    [b3, d4, g4, d5, b4, g4, d4, g4],
    [f3, a3, c4, a4, f4, c4, f3, a3],
    [g3, b3, d4, g4, b4, d5, g4, b4],
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

  final int fadeSamples = (sampleRate * 0.02).toInt();
  for (int i = 0; i < fadeSamples; i++) {
    final double factor = i / fadeSamples;
    mix[i] *= factor;
    mix[numSamples - 1 - i] *= factor;
  }

  final ByteData byteData = ByteData(44 + numSamples * 2);
  writeWavHeader(byteData, numSamples, sampleRate);
  for (int i = 0; i < numSamples; i++) {
    final int sampleInt16 = (mix[i] * 24000).clamp(-32768, 32767).toInt();
    byteData.setInt16(44 + i * 2, sampleInt16, Endian.little);
  }

  return byteData.buffer.asUint8List();
}

Uint8List generatePopSoundWav({double pitchMultiplier = 1.0}) {
  const int sampleRate = 22050;
  const double duration = 0.12;
  final int numSamples = (sampleRate * duration).toInt();
  final ByteData byteData = ByteData(44 + numSamples * 2);

  writeWavHeader(byteData, numSamples, sampleRate);

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

Uint8List generateHazardSoundWav() {
  const int sampleRate = 22050;
  const double duration = 0.18;
  final int numSamples = (sampleRate * duration).toInt();
  final ByteData byteData = ByteData(44 + numSamples * 2);

  writeWavHeader(byteData, numSamples, sampleRate);

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

Uint8List generateChimeSoundWav() {
  const int sampleRate = 22050;
  const double duration = 0.35;
  final int numSamples = (sampleRate * duration).toInt();
  final ByteData byteData = ByteData(44 + numSamples * 2);

  writeWavHeader(byteData, numSamples, sampleRate);

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
