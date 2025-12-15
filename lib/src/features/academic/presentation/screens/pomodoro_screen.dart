import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart'; // Asegúrate de tener esta librería

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Audio Logic
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _selectedSound = 'Silencio';

  // URLs de Sonidos Ambientales (Cyberpunk/Focus)
  final Map<String, String> _soundUrls = {
    'Silencio': '',
    'Lluvia': 'https://luan.xyz/files/audio/ambient_c_motion.mp3',
    'White Noise': 'https://luan.xyz/files/audio/nasa_on_a_beam.mp3',
    'Drone': 'https://luan.xyz/files/audio/coins_on_table.mp3',
  };

  // Timer Logic
  int _mode = 0; // 0: Focus, 1: Short, 2: Long
  late int _remainingSeconds;
  Timer? _timer;
  bool _isActive = false;

  final Map<int, int> _durations = {0: 25 * 60, 1: 5 * 60, 2: 15 * 60};

  final Map<int, Color> _modeColors = {
    0: Colors.cyanAccent,
    1: Colors.amberAccent,
    2: Colors.purpleAccent,
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

      // Start Audio if not silent
      if (_selectedSound != 'Silencio' &&
          _soundUrls.containsKey(_selectedSound)) {
        try {
          if (_soundUrls[_selectedSound]!.isNotEmpty) {
            await _audioPlayer.setUrl(_soundUrls[_selectedSound]!);
            await _audioPlayer.setLoopMode(LoopMode.one);
            await _audioPlayer.play();
          }
        } catch (e) {
          print("Error playing audio: $e");
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
    final color = _modeColors[_mode]!;
    final maxSeconds = _durations[_mode]!;
    final progress = _remainingSeconds / maxSeconds;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'MODO ENFOQUE',
          style: GoogleFonts.spaceMono(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mode Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeButton(0, 'FOCUS'),
              const SizedBox(width: 10),
              _buildModeButton(1, 'SHORT'),
              const SizedBox(width: 10),
              _buildModeButton(2, 'LONG'),
            ],
          ),
          const SizedBox(height: 40),

          // Timer
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 280,
                height: 280,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 15,
                  backgroundColor: Colors.grey[900],
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
                      color: Colors.white,
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
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSound,
                dropdownColor: Colors.grey[900],
                style: GoogleFonts.spaceMono(color: Colors.white),
                icon: Icon(Icons.headphones, color: color),
                items: _soundUrls.keys.map((String value) {
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
                    // Restart audio with new track if running
                    await _audioPlayer.stop();
                    if (_selectedSound != 'Silencio') {
                      await _audioPlayer.setUrl(_soundUrls[_selectedSound]!);
                      await _audioPlayer.play();
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
                icon: const Icon(Icons.refresh, color: Colors.grey, size: 40),
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

  Widget _buildModeButton(int mode, String label) {
    final isSelected = _mode == mode;
    final color = _modeColors[mode]!;
    return GestureDetector(
      onTap: () => _setMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey[800]!),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceMono(
            color: isSelected ? color : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
