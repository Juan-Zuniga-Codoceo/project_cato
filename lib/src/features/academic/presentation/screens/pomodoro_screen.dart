import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Modes: 0 = Focus (25), 1 = Short Break (5), 2 = Long Break (15)
  int _mode = 0;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isActive = false;

  final Map<int, int> _durations = {0: 25 * 60, 1: 5 * 60, 2: 15 * 60};

  final Map<int, Color> _modeColors = {
    0: Colors.cyanAccent,
    1: Colors.amberAccent,
    2: Colors.purpleAccent,
  };

  final Map<int, String> _modeNames = {
    0: 'FOCUS',
    1: 'SHORT BREAK',
    2: 'LONG BREAK',
  };

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _remainingSeconds = _durations[_mode]!;
    });
  }

  void _toggleTimer() {
    if (_isActive) {
      _timer?.cancel();
      setState(() => _isActive = false);
    } else {
      setState(() => _isActive = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isActive = false);
          HapticFeedback.heavyImpact();
          _showCompletionDialog();
        }
      });
    }
  }

  void _setMode(int mode) {
    setState(() {
      _mode = mode;
      _resetTimer();
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '¡Tiempo Terminado!',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        content: const Text('Has completado tu sesión.'),
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _modeColors[_mode]!;
    final maxSeconds = _durations[_mode]!;
    final progress = _remainingSeconds / maxSeconds;

    return Scaffold(
      backgroundColor: Colors.black, // Cyber dark background
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
              const SizedBox(width: 16),
              _buildModeButton(1, 'SHORT'),
              const SizedBox(width: 16),
              _buildModeButton(2, 'LONG'),
            ],
          ),
          const SizedBox(height: 48),

          // Timer
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 20,
                  backgroundColor: Colors.grey[900],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: GoogleFonts.spaceMono(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _isActive ? 'EN PROGRESO' : 'PAUSADO',
                    style: GoogleFonts.spaceMono(
                      fontSize: 16,
                      color: Colors.grey,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh, size: 48, color: Colors.grey),
              ),
              const SizedBox(width: 32),
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
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isActive ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 80), // Balance spacing
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
