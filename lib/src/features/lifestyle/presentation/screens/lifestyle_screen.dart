import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../providers/lifestyle_provider.dart';

class LifestyleScreen extends StatelessWidget {
  const LifestyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estilo de Vida'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Vitalidad', icon: Icon(Icons.favorite)),
              Tab(text: 'Estilo', icon: Icon(Icons.checkroom)),
            ],
          ),
        ),
        body: const TabBarView(children: [_VitalityTab(), _StyleTab()]),
      ),
    );
  }
}

class _VitalityTab extends StatelessWidget {
  const _VitalityTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Chequeos de Salud',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _CheckupCard(
            title: 'Médico General',
            type: LifestyleProvider.checkupGeneral,
            icon: Icons.medical_services,
          ),
          const SizedBox(height: 12),
          _CheckupCard(
            title: 'Dentista',
            type: LifestyleProvider.checkupDental,
            icon: Icons.cleaning_services,
          ),
          const SizedBox(height: 12),
          _CheckupCard(
            title: 'Vista',
            type: LifestyleProvider.checkupVision,
            icon: Icons.visibility,
          ),
          const SizedBox(height: 24),
          const Text(
            'Calculadora IMC',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: statusColor, width: 2),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(icon, color: statusColor),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              lastDate != null
                  ? 'Último: ${dateFormat.format(lastDate)}'
                  : 'Sin registro',
            ),
            trailing: const Icon(Icons.calendar_today, color: Colors.grey),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: lastDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
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

  void _calculate() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;

    if (weight > 0 && height > 0) {
      final result = Provider.of<LifestyleProvider>(
        context,
        listen: false,
      ).calculateBMI(height, weight);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Resultado IMC'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result['bmi'].toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                result['category'],
                style: TextStyle(
                  fontSize: 20,
                  color: _getBMIColor(result['bmi']),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_weight),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Altura (cm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.height),
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
              ),
              child: const Text('Calcular IMC'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleTab extends StatelessWidget {
  const _StyleTab();

  static const List<String> _tips = [
    "Combina el color de tu cinturón con el de tus zapatos.",
    "La regla de los 3 colores: No uses más de 3 colores principales en tu outfit.",
    "Asegúrate de que la costura del hombro de tu camisa termine justo donde termina tu hombro.",
    "Invierte en básicos de calidad: una buena camisa blanca, jeans oscuros y un blazer azul marino.",
    "Usa calcetines que combinen con tus pantalones, no con tus zapatos.",
    "El reloj es el accesorio más importante de un hombre.",
    "Mantén tu calzado limpio y lustrado.",
    "La talla correcta es el 90% del estilo.",
  ];

  static const List<String> _guide = [
    "1. Conoce tu talla y úsala.",
    "2. Menos es más.",
    "3. La calidad supera a la cantidad.",
    "4. Cuida los detalles (reloj, cinturón, calcetines).",
    "5. Vístete para la ocasión.",
    "6. Ten confianza en lo que llevas puesto.",
    "7. Cuida tu aseo personal (pelo, barba, uñas).",
    "8. Experimenta, pero con moderación.",
  ];

  @override
  Widget build(BuildContext context) {
    final randomTip = _tips[Random().nextInt(_tips.length)];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tip del Día',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.indigo.shade50,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    randomTip,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mandamientos del Estilo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _guide.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.check, color: Colors.green),
                  title: Text(_guide[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
