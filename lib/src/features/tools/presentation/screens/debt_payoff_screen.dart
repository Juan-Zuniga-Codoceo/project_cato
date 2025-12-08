import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class DebtPayoffScreen extends StatefulWidget {
  const DebtPayoffScreen({super.key});

  @override
  State<DebtPayoffScreen> createState() => _DebtPayoffScreenState();
}

class _DebtPayoffScreenState extends State<DebtPayoffScreen> {
  final _totalDebtController = TextEditingController();
  final _annualRateController = TextEditingController();
  final _monthlyPaymentController = TextEditingController();

  String? _timeToPayoff;
  double? _totalInterestPaid;
  String? _errorMessage;

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _timeToPayoff = null;
      _totalInterestPaid = null;
    });

    final totalDebt = double.tryParse(_totalDebtController.text) ?? 0.0;
    final annualRate = double.tryParse(_annualRateController.text) ?? 0.0;
    final monthlyPayment =
        double.tryParse(_monthlyPaymentController.text) ?? 0.0;

    if (totalDebt <= 0 || monthlyPayment <= 0) return;

    final monthlyRate = annualRate / 100 / 12;

    // Check if payment is sufficient to cover interest
    if (monthlyRate > 0 && monthlyPayment <= totalDebt * monthlyRate) {
      setState(() {
        _errorMessage =
            'Pago insuficiente. La deuda crecerá infinitamente porque el pago es menor que el interés mensual.';
      });
      return;
    }

    double months;
    if (monthlyRate == 0) {
      months = totalDebt / monthlyPayment;
    } else {
      // Formula: n = -log(1 - (r * P) / A) / log(1 + r)
      // P = Principal (Debt), A = Monthly Payment, r = Monthly Rate
      months =
          -log(1 - (monthlyRate * totalDebt) / monthlyPayment) /
          log(1 + monthlyRate);
    }

    final totalMonths = months.ceil();
    final years = totalMonths ~/ 12;
    final remainingMonths = totalMonths % 12;

    String timeString = '';
    if (years > 0) {
      timeString += '$years año${years > 1 ? 's' : ''} ';
    }
    if (remainingMonths > 0 || years == 0) {
      timeString += '$remainingMonths mes${remainingMonths != 1 ? 'es' : ''}';
    }

    final totalPaid = totalMonths * monthlyPayment; // Approximation
    // More accurate total paid calculation requires iterating or exact final payment
    // For simplicity, we'll use (months * payment) but correct the final payment logic if needed.
    // Actually, let's just use the simple approximation for "Total Interest" = (Total Paid - Principal)

    final totalInterest = (totalMonths * monthlyPayment) - totalDebt;

    setState(() {
      _timeToPayoff = timeString;
      _totalInterestPaid = totalInterest > 0 ? totalInterest : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Deuda'),
        backgroundColor: Colors.redAccent,
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
                      controller: _totalDebtController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Deuda Total (\$)',
                        prefixIcon: Icon(Icons.money_off),
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
                      controller: _monthlyPaymentController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Pago Mensual (\$)',
                        prefixIcon: Icon(Icons.payment),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
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
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            if (_timeToPayoff != null) ...[
              const Text(
                'Resultados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _ResultCard(
                title: 'Tiempo para pagar',
                value: _timeToPayoff!,
                color: Colors.blue,
                icon: Icons.timer,
              ),
              const SizedBox(height: 12),
              _ResultCard(
                title: 'Interés Total Pagado',
                value: currencyFormat.format(_totalInterestPaid),
                color: Colors.redAccent,
                icon: Icons.money_off,
                subtitle: 'Dinero "perdido" en intereses',
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
  final String? subtitle;

  const _ResultCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.subtitle,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
