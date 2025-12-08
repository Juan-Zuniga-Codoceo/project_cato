import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  final _initialInvestmentController = TextEditingController();
  final _monthlyContributionController = TextEditingController();
  final _annualRateController = TextEditingController();
  final _yearsController = TextEditingController();

  double? _totalAmount;
  double? _totalContributed;
  double? _totalInterest;

  void _calculate() {
    final initialInvestment =
        double.tryParse(_initialInvestmentController.text) ?? 0.0;
    final monthlyContribution =
        double.tryParse(_monthlyContributionController.text) ?? 0.0;
    final annualRate = double.tryParse(_annualRateController.text) ?? 0.0;
    final years = int.tryParse(_yearsController.text) ?? 0;

    if (years <= 0) return;

    final monthlyRate = annualRate / 100 / 12;
    final months = years * 12;

    double futureValueInitial =
        initialInvestment * pow(1 + monthlyRate, months);
    double futureValueContributions = 0.0;

    if (monthlyRate > 0) {
      futureValueContributions =
          monthlyContribution *
          (pow(1 + monthlyRate, months) - 1) /
          monthlyRate;
    } else {
      futureValueContributions = monthlyContribution * months;
    }

    final total = futureValueInitial + futureValueContributions;
    final contributed = initialInvestment + (monthlyContribution * months);
    final interest = total - contributed;

    setState(() {
      _totalAmount = total;
      _totalContributed = contributed;
      _totalInterest = interest;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interés Compuesto'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _initialInvestmentController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Inversión Inicial (\$)',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _monthlyContributionController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Aporte Mensual (\$)',
                        prefixIcon: Icon(Icons.savings),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _annualRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Tasa Anual (%)',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _yearsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Años a proyectar',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'CALCULAR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_totalAmount != null) ...[
              const Text(
                'Resultados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _ResultCard(
                title: 'Total Final',
                value: currencyFormat.format(_totalAmount),
                color: Colors.green,
                icon: Icons.monetization_on,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ResultCard(
                      title: 'Total Aportado',
                      value: currencyFormat.format(_totalContributed),
                      color: Colors.blue,
                      icon: Icons.account_balance_wallet,
                      isSmall: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ResultCard(
                      title: 'Interés Ganado',
                      value: currencyFormat.format(_totalInterest),
                      color: Colors.orange,
                      icon: Icons.trending_up,
                      isSmall: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final bool isSmall;

  const _ResultCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: isSmall ? 24 : 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isSmall ? 12 : 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: isSmall ? 16 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
