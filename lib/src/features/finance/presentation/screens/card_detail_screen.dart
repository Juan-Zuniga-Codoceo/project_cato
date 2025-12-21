import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../domain/models/wallet_card.dart';

class CardDetailScreen extends StatelessWidget {
  final WalletCard card;

  const CardDetailScreen({super.key, required this.card});

  Color _getProgressColor(double p) {
    if (p < 0.5) return Colors.green;
    if (p < 0.8) return Colors.orange;
    return Colors.red;
  }

  void _showPayDialog(
    BuildContext context,
    FinanceProvider finance,
    WalletCard card,
  ) {
    final amountController = TextEditingController();
    final theme = Theme.of(context);

    // Obtener solo medios de pago con liquidez (Débito/Efectivo)
    final fundingSources =
        finance.myCards.where((c) => !c.isCredit).map((c) => c.name).toList()
          ..add('Efectivo');

    String selectedSource = fundingSources.isNotEmpty
        ? fundingSources.first
        : 'Efectivo';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            'Pagar ${card.name}',
            style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: "Monto a pagar",
                  prefixText: "\$ ",
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: theme.hintColor),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSource,
                dropdownColor: theme.cardColor,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: "Pagar desde (Origen)",
                  labelStyle: TextStyle(color: theme.hintColor),
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.account_balance_wallet,
                    color: theme.hintColor,
                  ),
                ),
                items: fundingSources
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => selectedSource = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (amountController.text.isNotEmpty) {
                  final amount = double.parse(amountController.text);

                  // [FIX] Usar método centralizado del Provider
                  finance.processCreditCardPayment(
                    cardName: card.name,
                    amount: amount,
                    sourceMethod: selectedSource,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pago registrado: \$${amount.toStringAsFixed(0)}',
                        style: GoogleFonts.spaceMono(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text("CONFIRMAR"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores Tácticos High Contrast
    final bgColor = isDark
        ? theme.scaffoldBackgroundColor
        : const Color(0xFFF5F5F5); // Gris muy claro
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.grey : Colors.grey[700];

    // 1. Filtrar transacciones de ESTA tarjeta
    final history =
        finance.transactions
            .where((tx) => tx.paymentMethod == card.name)
            .toList()
          ..sort(
            (a, b) => b.date.compareTo(a.date),
          ); // Ordenar por fecha (más reciente arriba)

    // 2. Calcular totales
    double totalIncome = 0;
    double totalExpense = 0;
    for (var tx in history) {
      if (tx.isExpense)
        totalExpense += tx.amount;
      else
        totalIncome += tx.amount;
    }

    // Cálculos para Cupo (Crédito) - [FIX] Usar método corregido
    double currentDebt = 0;
    if (card.isCredit) {
      currentDebt = finance.getRemainingDebtForCard(card.name);
    }

    double limit = card.limit;
    double progress = limit > 0 ? (currentDebt / limit).clamp(0.0, 1.0) : 0.0;

    // Si es débito, mostramos saldo. Si es crédito, mostramos deuda total pendiente.
    double displayBalance = card.isCredit
        ? currentDebt
        : finance.getCardBalance(card.name);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(
          card.name.toUpperCase(),
          style: GoogleFonts.spaceMono(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- HEADER DE LA TARJETA (HIGH CONTRAST) ---
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor, // Blanco en Light, Oscuro en Dark
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      card.isCredit
                          ? Icons.credit_card
                          : Icons.account_balance_wallet,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    Text(
                      card.bankName.toUpperCase(),
                      style: GoogleFonts.spaceMono(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // SI ES CRÉDITO: Mostrar Barra de Cupo
                if (card.isCredit) ...[
                  Text(
                    'DEUDA TOTAL PENDIENTE',
                    style: GoogleFonts.inter(
                      color: labelColor,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${displayBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: GoogleFonts.spaceMono(
                      color: Colors.redAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "CUPO UTILIZADO",
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${(progress * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: _getProgressColor(progress),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      _getProgressColor(progress),
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${currentDebt.toStringAsFixed(0)}",
                        style: GoogleFonts.spaceMono(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ), // Usado
                      Text(
                        "\$${limit.toStringAsFixed(0)}",
                        style: GoogleFonts.spaceMono(color: labelColor),
                      ), // Total
                    ],
                  ),
                  const SizedBox(height: 20),

                  // BOTÓN PAGAR
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                      ),
                      onPressed: () => _showPayDialog(context, finance, card),
                      child: const Text("PAGAR DEUDA (LIBERAR CUPO)"),
                    ),
                  ),
                ] else ...[
                  // Diseño Débito (Saldo)
                  Text(
                    'SALDO DISPONIBLE',
                    style: GoogleFonts.inter(
                      color: labelColor,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${displayBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: GoogleFonts.spaceMono(
                      color: Colors.greenAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // --- RESUMEN RÁPIDO ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                _buildSummaryItem(
                  context,
                  'INGRESOS',
                  totalIncome,
                  Colors.greenAccent,
                ),
                _buildSummaryItem(
                  context,
                  'GASTOS',
                  totalExpense,
                  Colors.redAccent,
                ),
              ],
            ),
          ),

          const Divider(height: 30),

          // --- LISTA DE MOVIMIENTOS ---
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "HISTORIAL DE BATALLA",
                style: GoogleFonts.spaceMono(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),

          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Text(
                      "Sin movimientos registrados",
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final tx = history[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.cardColor.withOpacity(0.5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: isDark
                              ? null
                              : Border.all(color: Colors.black12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (tx.isExpense ? Colors.red : Colors.green)
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tx.isExpense
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: tx.isExpense
                                  ? Colors.redAccent
                                  : Colors.greenAccent,
                              size: 16,
                            ),
                          ),
                          title: Text(
                            tx.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy').format(tx.date),
                            style: TextStyle(fontSize: 12, color: labelColor),
                          ),
                          trailing: Text(
                            '\$${tx.amount.toStringAsFixed(0)}',
                            style: GoogleFonts.spaceMono(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: tx.isExpense
                                  ? Colors.redAccent
                                  : Colors.greenAccent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
          ),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: GoogleFonts.spaceMono(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
