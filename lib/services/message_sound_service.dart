import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:vibration/vibration.dart';

class MessageSoundService {
  MessageSoundService._();

  static final MessageSoundService instance = MessageSoundService._();

  static const String _messageSoundAsset = 'lib/assets/message.wav';
  static const Duration _alertCooldown = Duration(seconds: 3);

  FlutterSoundPlayer? _player;
  Uint8List? _messageSoundBytes;
  Future<void>? _initializing;
  DateTime? _lastAlertAt;

  Future<void> playMessageAlert({bool vibrate = true}) async {
    final now = DateTime.now();
    final lastAlertAt = _lastAlertAt;
    if (lastAlertAt != null && now.difference(lastAlertAt) < _alertCooldown) {
      return;
    }
    _lastAlertAt = now;

    if (vibrate) {
      _vibrate();
    }
    await playMessageSound();
  }

  Future<void> playMessageSound() async {
    try {
      await _ensureInitialized();
      final player = _player;
      final bytes = _messageSoundBytes;
      if (player == null || bytes == null) return;

      if (player.isPlaying) {
        await player.stopPlayer();
      }

      await player.startPlayer(fromDataBuffer: bytes, codec: Codec.pcm16WAV);
    } catch (_) {
      // Message popup should still be shown even if the prompt sound fails.
    }
  }

  Future<void> _ensureInitialized() {
    return _initializing ??= _init();
  }

  Future<void> _vibrate() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != true) return;

      final hasCustomSupport = await Vibration.hasCustomVibrationsSupport();
      if (hasCustomSupport == true) {
        await Vibration.vibrate(pattern: [0, 180, 90, 180]);
      } else {
        await Vibration.vibrate(duration: 350);
      }
    } catch (_) {
      // Ignore vibration failures; sound and popup still provide feedback.
    }
  }

  Future<void> _init() async {
    final player = FlutterSoundPlayer();
    await player.openPlayer();

    final data = await rootBundle.load(_messageSoundAsset);
    _messageSoundBytes = data.buffer.asUint8List();
    _player = player;
  }

  Future<void> dispose() async {
    final player = _player;
    _player = null;
    _messageSoundBytes = null;
    _initializing = null;
    _lastAlertAt = null;

    if (player == null) return;
    if (player.isPlaying) {
      await player.stopPlayer();
    }
    await player.closePlayer();
  }
}
