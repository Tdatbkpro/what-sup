import 'package:just_audio/just_audio.dart';
import 'dart:async';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<PlayerState>? _playerStateSub;

  // Streams
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Khởi tạo âm thanh từ file path
  Future<void> init(String filePath) async {
    try {
      await _player.stop(); 
      await _player.setFilePath(filePath);

      _playerStateSub?.cancel(); // tránh trùng listener
      _playerStateSub = _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _player.seek(Duration.zero); // reset khi phát xong
        }
      });
    } catch (e) {
      print("Lỗi khi khởi tạo âm thanh: $e");
    }
  }

  /// Phát hoặc tạm dừng
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  /// Tua
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Đang phát?
  bool get isPlaying => _player.playing;

  /// Dừng phát
  Future<void> stop() async {
    await _player.stop();
  }

  /// Huỷ toàn bộ audio
  Future<void> dispose() async {
    await _playerStateSub?.cancel();
    await _player.dispose();
  }
}
