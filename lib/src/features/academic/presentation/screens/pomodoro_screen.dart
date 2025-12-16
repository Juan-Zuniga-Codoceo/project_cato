import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Audio Logic
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _selectedSound = 'Silencio';

  // Mapa de Assets Locales
  final Map<String, String> _soundAssets = {
    'Silencio': '',
    'Lluvia': 'assets/audio/rain.mp3',
    'White Noise': 'assets/audio/white_noise.mp3',
    'Drone': 'assets/audio/cyber_drone.mp3',
  };

  // Timer Logic
  int _mode = 0; // 0: Focus, 1: Short, 2: Long
  late int _remainingSeconds;
  Timer? _timer;
  bool _isActive = false;

  final Map<int, int> _durations = {0: 25 * 60, 1: 5 * 60, 2: 15 * 60};

  final Map<int, Color> _modeColors = {
    0: Colors.cyan,
    1: Colors.amber,
    2: Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _resetTimer() {
    _timer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _isActive = false;
      _remainingSeconds = _durations[_mode]!;
    });
  }

  void _setMode(int mode) {
    setState(() {
      _mode = mode;
      _resetTimer();
    });
  }

  Future<void> _toggleTimer() async {
    if (_isActive) {
      // Pause
      _timer?.cancel();
      await _audioPlayer.stop();
      setState(() => _isActive = false);
    } else {
      // Start
      setState(() => _isActive = true);

      // Reproducir Audio Local
      if (_selectedSound != 'Silencio' &&
          _soundAssets.containsKey(_selectedSound)) {
        try {
          final assetPath = _soundAssets[_selectedSound];
          if (assetPath != null && assetPath.isNotEmpty) {
            // Usamos setAsset para archivos locales
            await _audioPlayer.setAsset(assetPath);
            await _audioPlayer.setLoopMode(LoopMode.one);
            await _audioPlayer.play();
          }
        } catch (e) {
          print("Error playing asset audio: $e");
          // Fallback visual si falla el audio
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error de audio: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          _audioPlayer.stop();
          setState(() => _isActive = false);
          HapticFeedback.heavyImpact();
          _showCompletionDialog();
        }
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'SESIÓN COMPLETADA',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        content: const Text('Has ganado XP de Intelecto.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    // Detectar tema actual
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = _modeColors[_mode]!;
    final maxSeconds = _durations[_mode]!;
    final progress = _remainingSeconds / maxSeconds;

    // Colores dinámicos
    final textColor = isDark ? Colors.white : Colors.black87;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'MODO ENFOQUE',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mode Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeButton(0, 'FOCUS', color, isDark),
              const SizedBox(width: 10),
              _buildModeButton(1, 'SHORT', color, isDark),
              const SizedBox(width: 10),
              _buildModeButton(2, 'LONG', color, isDark),
            ],
          ),
          const SizedBox(height: 40),

          // Timer Circular
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 280,
                height: 280,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 15,
                  // Color de fondo del círculo más suave
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: GoogleFonts.spaceMono(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: textColor, // Color dinámico
                    ),
                  ),
                  Text(
                    _isActive ? 'CONCENTRACIÓN' : 'PAUSADO',
                    style: GoogleFonts.spaceMono(
                      color: color,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Sound Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: surfaceColor, // Color de tarjeta del tema
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSound,
                dropdownColor: surfaceColor,
                style: GoogleFonts.spaceMono(color: textColor),
                icon: Icon(Icons.headphones, color: color),
                items: _soundAssets.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) async {
                  setState(() {
                    _selectedSound = newValue!;
                  });
                  if (_isActive) {
                    await _audioPlayer.stop();
                    if (_selectedSound != 'Silencio' &&
                        _soundAssets.containsKey(_selectedSound)) {
                      final path = _soundAssets[_selectedSound];
                      if (path != null && path.isNotEmpty) {
                        await _audioPlayer.setAsset(path);
                        await _audioPlayer.play();
                      }
                    }
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: isDark ? Colors.grey : Colors.grey[600],
                  size: 40,
                ),
                onPressed: _resetTimer,
              ),
              const SizedBox(width: 30),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _toggleTimer();
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.4), blurRadius: 20),
                    ],
                  ),
                  child: Icon(
                    _isActive ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 70), // Spacer balance
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(int mode, String label, Color color, bool isDark) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => _setMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceMono(
            color: isSelected
                ? color
                : (isDark ? Colors.grey : Colors.grey[600]),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
