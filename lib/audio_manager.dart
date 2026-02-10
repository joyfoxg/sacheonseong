import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  Future<void> init() async {
    // 미리 로드하거나 설정할 것이 있으면 여기서 처리
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBgm() async {
    try {
      if (_bgmPlayer.state == PlayerState.playing) {
        return; // 이미 재생 중이면 아무것도 안 함
      }
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
    } catch (e) {
      print("Error playing BGM: $e");
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
       print("Error stopping BGM: $e");
    }
  }

  Future<void> playSelect() async {
    try {
       // 효과음은 중첩 재생을 위해 매번 새로운 플레이어를 쓸 수도 있지만
       // 여기서는 단일 플레이어로 하되, 짧은 간격이면 끊길 수 있음.
       // 동시 재생이 중요하다면 매번 AudioPlayer()를 생성하거나 Pool방식을 써야 함.
       // audioplayers 0.20.x 이후로는 모드 설정이 다를 수 있음.
       // 간단하게 구현:
       await _sfxPlayer.stop(); // 이전 소리 끔
       await _sfxPlayer.play(AssetSource('audio/select.mp3'));
    } catch (e) {
      print("Error playing Select SFX: $e");
    }
  }
  
  Future<void> playSuccess() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/sucess.mp3'));
    } catch (e) {
      print("Error playing Success SFX: $e");
    }
  }

  Future<void> playFail() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/fail.mp3'));
    } catch (e) {
      print("Error playing Fail SFX: $e");
    }
  }
  
  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
