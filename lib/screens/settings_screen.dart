import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:island_royale/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _joystickSensitivity = 1.0;
  double _aimSensitivity = 1.0;
  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  bool _showFps = false;
  bool _autoPickup = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _joystickSensitivity = prefs.getDouble('joystick_sens') ?? 1.0;
      _aimSensitivity = prefs.getDouble('aim_sens') ?? 1.0;
      _sfxEnabled = prefs.getBool('sfx') ?? true;
      _musicEnabled = prefs.getBool('music') ?? true;
      _showFps = prefs.getBool('show_fps') ?? false;
      _autoPickup = prefs.getBool('auto_pickup') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('joystick_sens', _joystickSensitivity);
    await prefs.setDouble('aim_sens', _aimSensitivity);
    await prefs.setBool('sfx', _sfxEnabled);
    await prefs.setBool('music', _musicEnabled);
    await prefs.setBool('show_fps', _showFps);
    await prefs.setBool('auto_pickup', _autoPickup);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          backgroundColor: Color(0xFFFF6B00),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white54),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: AppConstants.primaryColor,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(label: 'CONTROLS'),
          _SliderTile(
            label: 'Move Joystick Sensitivity',
            value: _joystickSensitivity,
            onChanged: (v) => setState(() => _joystickSensitivity = v),
          ),
          _SliderTile(
            label: 'Aim Sensitivity',
            value: _aimSensitivity,
            onChanged: (v) => setState(() => _aimSensitivity = v),
          ),
          _ToggleTile(
            label: 'Auto-Pickup Items',
            value: _autoPickup,
            onChanged: (v) => setState(() => _autoPickup = v),
          ),
          const SizedBox(height: 24),

          _SectionHeader(label: 'AUDIO'),
          _ToggleTile(
            label: 'Sound Effects',
            value: _sfxEnabled,
            onChanged: (v) => setState(() => _sfxEnabled = v),
          ),
          _ToggleTile(
            label: 'Background Music',
            value: _musicEnabled,
            onChanged: (v) => setState(() => _musicEnabled = v),
          ),
          const SizedBox(height: 24),

          _SectionHeader(label: 'DISPLAY'),
          _ToggleTile(
            label: 'Show FPS Counter',
            value: _showFps,
            onChanged: (v) => setState(() => _showFps = v),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: const TextStyle(
          color: AppConstants.primaryColor,
          fontSize: 11,
          letterSpacing: 4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            activeColor: AppConstants.primaryColor,
            inactiveColor: Colors.white12,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }
}
