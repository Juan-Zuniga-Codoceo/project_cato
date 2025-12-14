import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/lifestyle_provider.dart';

class LifestyleScreen extends StatelessWidget {
  const LifestyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'LIFE OS',
            style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            labelStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.spaceMono(),
            tabs: const [
              Tab(text: 'BIO-MONITOR', icon: Icon(Icons.monitor_heart)),
              Tab(text: 'EXTERIOR', icon: Icon(Icons.layers)),
            ],
          ),
        ),
        body: const TabBarView(children: [_VitalityTab(), _ExteriorTab()]),
      ),
    );
  }
}

// ... (Keeping _VitalityTab and _CheckupCard and _BMICalculator as they are, assuming they are correct from previous steps. I need to be careful not to delete them if I'm not viewing them.
// The previous view showed _VitalityTab starts at line 30.
// I will target the LifestyleScreen build method first, then the _StyleTab class separately to be safe.)

// Actually, I can do it in two chunks.
// Chunk 1: Update Tabs and TabBarView.
// Chunk 2: Replace _StyleTab class.

// Let's do Chunk 1 first.

class _VitalityTab extends StatelessWidget {
  const _VitalityTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'MANTENIMIENTO DE HARDWARE',
            style: GoogleFonts.spaceMono(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _CheckupCard(
            title: 'DIAGNÓSTICO GENERAL',
            type: LifestyleProvider.checkupGeneral,
            icon: Icons.medical_services_outlined,
          ),
          const SizedBox(height: 12),
          _CheckupCard(
            title: 'MANTENIMIENTO DENTAL',
            type: LifestyleProvider.checkupDental,
            icon: Icons.cleaning_services_outlined,
          ),
          const SizedBox(height: 12),
          _CheckupCard(
            title: 'CALIBRACIÓN ÓPTICA',
            type: LifestyleProvider.checkupVision,
            icon: Icons.visibility_outlined,
          ),
          const SizedBox(height: 32),
          Text(
            'ESCÁNER BIOMÉTRICO',
            style: GoogleFonts.spaceMono(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const _BMICalculator(),
        ],
      ),
    );
  }
}

class _CheckupCard extends StatelessWidget {
  final String title;
  final String type;
  final IconData icon;

  const _CheckupCard({
    required this.title,
    required this.type,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LifestyleProvider>(
      builder: (context, provider, child) {
        final lastDate = provider.getLastCheckup(type);
        final statusColor = provider.getHealthStatus(type);
        final dateFormat = DateFormat('dd/MM/yyyy');

        return Card(
          elevation: 0,
          color: Theme.of(context).cardColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: statusColor.withOpacity(0.5), width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Icon(icon, color: statusColor, size: 20),
            ),
            title: Text(
              title,
              style: GoogleFonts.spaceMono(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                lastDate != null
                    ? 'ÚLTIMO REGISTRO: ${dateFormat.format(lastDate)}'
                    : 'SIN DATOS',
                style: GoogleFonts.spaceMono(fontSize: 10, color: Colors.grey),
              ),
            ),
            trailing: Icon(
              Icons.edit_calendar,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              size: 20,
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: lastDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                provider.updateCheckup(type, picked);
              }
            },
          ),
        );
      },
    );
  }
}

class _BMICalculator extends StatefulWidget {
  const _BMICalculator();

  @override
  State<_BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<_BMICalculator> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  Map<String, dynamic>? _result;

  void _calculate() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;

    if (weight > 0 && height > 0) {
      setState(() {
        _result = Provider.of<LifestyleProvider>(
          context,
          listen: false,
        ).calculateBMI(height, weight);
      });
    }
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.spaceMono(),
                    decoration: InputDecoration(
                      labelText: 'PESO (KG)',
                      labelStyle: GoogleFonts.spaceMono(fontSize: 12),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.monitor_weight_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.spaceMono(),
                    decoration: InputDecoration(
                      labelText: 'ALTURA (CM)',
                      labelStyle: GoogleFonts.spaceMono(fontSize: 12),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.height),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
              ),
              child: Text(
                'EJECUTAR ESCÁNER',
                style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'IMC: ${_result!['bmi'].toStringAsFixed(1)}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getBMIColor(_result!['bmi']),
                    ),
                  ),
                  Text(
                    'ESTADO: ${_result!['category'].toString().toUpperCase()}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getBMIColor(_result!['bmi']),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_result!['bmi'] / 40).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  color: _getBMIColor(_result!['bmi']),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExteriorTab extends StatelessWidget {
  const _ExteriorTab();

  static const List<String> _tips = [
    "La postura comunica autoridad antes que las palabras.",
    "Menos es más: elimina lo que no aporta función.",
    "La regla del 3: máximo 3 colores en tu equipamiento.",
    "El ajuste (fit) es la base de toda arquitectura visual.",
    "Tu imagen es tu interfaz de usuario: mantenla limpia.",
    "La calidad del material define la durabilidad del sistema.",
    "El lenguaje corporal abierto indica un sistema receptivo.",
    "La coherencia visual genera confianza inmediata.",
  ];

  static const List<String> _guide = [
    "1. El ajuste (fit) es prioridad.",
    "2. Calidad sobre cantidad.",
    "3. Higiene es salud del sistema.",
    "4. Postura erguida = Confianza.",
    "5. Contexto define el equipamiento.",
    "6. Elimina el ruido visual.",
    "7. Cuida los detalles periféricos.",
    "8. Funcionalidad antes que adorno.",
  ];

  @override
  Widget build(BuildContext context) {
    final randomTip = _tips[Random().nextInt(_tips.length)];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'INTELIGENCIA VISUAL',
            style: GoogleFonts.spaceMono(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Dark background
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.visibility,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 40,
                  shadows: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  randomTip.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceMono(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'PROTOCOLOS DE PRESENCIA',
            style: GoogleFonts.spaceMono(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _guide.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                color: Theme.of(context).cardColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                  title: Text(
                    _guide[index],
                    style: GoogleFonts.spaceMono(fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
