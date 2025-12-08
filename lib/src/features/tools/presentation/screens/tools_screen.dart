import 'package:flutter/material.dart';
import 'currency_converter_screen.dart';
import 'compound_interest_screen.dart';
import 'debt_payoff_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Herramientas')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ToolCard(
            title: 'Conversor de Divisas',
            icon: Icons.currency_exchange,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CurrencyConverterScreen(),
              ),
            ),
          ),
          _ToolCard(
            title: 'Interés Compuesto',
            icon: Icons.trending_up,
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CompoundInterestScreen(),
              ),
            ),
          ),
          _ToolCard(
            title: 'Calculadora de Deuda',
            icon: Icons.money_off,
            color: Colors.redAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DebtPayoffScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
