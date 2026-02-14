import 'package:flutter/material.dart';
import 'dart:ui';
import '../audio_manager.dart';
import '../difficulty.dart';

class SettingsDialog extends StatefulWidget {
  final Difficulty currentDifficulty;
  final ValueChanged<Difficulty> onDifficultyChanged;
  
  const SettingsDialog({
    super.key,
    required this.currentDifficulty,
    required this.onDifficultyChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final AudioManager _audioManager = AudioManager();
  late bool _bgmEnabled;
  late double _bgmVolume;
  late double _sfxVolume;
  late Difficulty _difficulty;

  @override
  void initState() {
    super.initState();
    _bgmEnabled = _audioManager.isBgmEnabled;
    _bgmVolume = _audioManager.bgmVolume;
    _sfxVolume = _audioManager.sfxVolume;
    _difficulty = widget.currentDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 제목
                Text(
                  '⚙️ 설정',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // BGM ON/OFF 토글
                _buildToggleRow(
                  icon: '🎵',
                  label: 'BGM',
                  value: _bgmEnabled,
                  onChanged: (value) async {
                    setState(() => _bgmEnabled = value);
                    await _audioManager.setBgmEnabled(value);
                  },
                ),
                const SizedBox(height: 20),

                // BGM 볼륨 슬라이더
                _buildVolumeSlider(
                  icon: '🔊',
                  label: 'BGM 볼륨',
                  value: _bgmVolume,
                  enabled: _bgmEnabled,
                  onChanged: (value) async {
                    setState(() => _bgmVolume = value);
                    await _audioManager.setBgmVolume(value);
                  },
                ),
                const SizedBox(height: 25),

                // 효과음 볼륨 슬라이더
                _buildVolumeSlider(
                  icon: '🎶',
                  label: '효과음 볼륨',
                  value: _sfxVolume,
                  enabled: true,
                  onChanged: (value) async {
                    setState(() => _sfxVolume = value);
                    await _audioManager.setSfxVolume(value);
                    // 테스트용으로 효과음 재생
                    if (value > 0) {
                      await _audioManager.playSelect();
                    }
                  },
                ),
                const SizedBox(height: 30),

                // 난이도 설정
                _buildDifficultySection(),
                const SizedBox(height: 35),

                // 닫기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '닫기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.amber,
          activeTrackColor: Colors.amber.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _buildVolumeSlider({
    required String icon,
    required String label,
    required double value,
    required bool enabled,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: enabled ? Colors.white : Colors.white.withOpacity(0.4),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                color: enabled ? Colors.amber[300] : Colors.white.withOpacity(0.3),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: enabled ? Colors.amber : Colors.grey,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            thumbColor: enabled ? Colors.amber[300] : Colors.grey,
            overlayColor: Colors.amber.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            const Text(
              '난이도',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Difficulty>(
              value: _difficulty,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              items: Difficulty.values.map((Difficulty value) {
                return DropdownMenuItem<Difficulty>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(
                        value == Difficulty.easy
                            ? Icons.sentiment_satisfied_alt
                            : value == Difficulty.normal
                                ? Icons.sentiment_neutral
                                : Icons.sentiment_very_dissatisfied,
                        color: value == Difficulty.easy
                            ? Colors.green
                            : value == Difficulty.normal
                                ? Colors.blue
                                : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(value.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Difficulty? newValue) {
                if (newValue != null) {
                  setState(() => _difficulty = newValue);
                  widget.onDifficultyChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
