import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _isBgmEnabled = true; // BGM 활성화 여부
  double _bgmVolume = 0.7; // BGM 볼륨 (0.0 ~ 1.0)
  double _sfxVolume = 1.0; // SFX 볼륨 (0.0 ~ 1.0)

  bool get isBgmEnabled => _isBgmEnabled;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> init() async {
    // SharedPreferences에서 설정 불러오기
    final prefs = await SharedPreferences.getInstance();
    _isBgmEnabled = prefs.getBool('bgm_enabled') ?? true;
    _bgmVolume = prefs.getDouble('bgm_volume') ?? 0.7;
    _sfxVolume = prefs.getDouble('sfx_volume') ?? 1.0;
    
    // 안드로이드 12 이상에서 효과음 재생 시 BGM이 멈추는 문제 해결
    // AudioContext 설정으로 오디오 포커스를 받지 않도록 함
    await _bgmPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none, // 포커스를 받지 않음 (중요!)
        ),
      ),
    );
    
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_bgmVolume);
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  Future<void> setBgmEnabled(bool enabled) async {
    _isBgmEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bgm_enabled', enabled);
    
    if (_isBgmEnabled) {
      await playBgm();
    } else {
      await stopBgm();
    }
  }

  Future<void> setBgmVolume(double volume) async {
    _bgmVolume = volume.clamp(0.0, 1.0);
    await _bgmPlayer.setVolume(_bgmVolume);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bgm_volume', _bgmVolume);
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxVolume);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sfx_volume', _sfxVolume);
  }

  Future<void> playBgm() async {
    try {
      if (!_isBgmEnabled) return; // 비활성화 상태면 재생 안 함
      if (_bgmPlayer.state == PlayerState.playing) {
        return; // 이미 재생 중이면 아무것도 안 함
      }
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'), volume: _bgmVolume);
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
       await _sfxPlayer.stop(); // 이전 소리 끔
       await _sfxPlayer.play(AssetSource('audio/select.mp3'), volume: _sfxVolume);
    } catch (e) {
      print("Error playing Select SFX: $e");
    }
  }
  
  Future<void> playSuccess() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/sucess.mp3'), volume: _sfxVolume);
    } catch (e) {
      print("Error playing Success SFX: $e");
    }
  }

  Future<void> playFail() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/fail.mp3'), volume: _sfxVolume);
    } catch (e) {
      print("Error playing Fail SFX: $e");
    }
  }
  
  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
