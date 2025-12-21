import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/finance_provider.dart';
import 'statistics_screen.dart';
import 'subscriptions_screen.dart';
import 'transactions_screen.dart';
import 'savings_screen.dart';
import 'budgets_screen.dart';
import 'wallet_management_screen.dart';
import 'card_detail_screen.dart'; // [NUEVO] Para navegación al detalle

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  void _showInfoDialog(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(description, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ENTENDIDO',
              style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores específicos para el dashboard (Cyberpunk muted)
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade300;

    final cyanColor = isDark ? Colors.cyanAccent : Colors.teal.shade700;

    return Scaffold(
      body: Column(
        children: [
          // --- HEADER FINANCIERO ---
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/module_finance.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Colors.transparent,
                  ],
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(20),
              child: Text(
                "BÓVEDA PRINCIPAL",
                style: GoogleFonts.spaceMono(
                  color: const Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),

          // --- BALANCE LIQUIDEZ ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Consumer<FinanceProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIQUIDEZ (EFECTIVO/DÉBITO)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        letterSpacing: 1.5,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${provider.totalBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Indicador de Deuda Global
                    if (provider.totalCreditDebt > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.credit_card_off,
                            color: Colors.redAccent,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'DEUDA TOTAL: -\$${provider.totalCreditDebt.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                            style: GoogleFonts.spaceMono(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),

          // --- SECCIÓN BILLETERA (CARRUSEL DE FAVORITAS) ---
          Consumer<FinanceProvider>(
            builder: (context, finance, _) {
              // [CAMBIO CLAVE] Usar getDashboardCards() para mostrar solo favoritas
              final dashboardCards = finance.getDashboardCards();
              if (dashboardCards.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BILLETERA TÁCTICA',
                        style: GoogleFonts.spaceMono(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WalletManagementScreen(),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 14, color: cyanColor),
                            const SizedBox(width: 4),
                            Text(
                              'AGREGAR',
                              style: GoogleFonts.spaceMono(
                                fontSize: 10,
                                color: cyanColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BILLETERA TÁCTICA',
                          style: GoogleFonts.spaceMono(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WalletManagementScreen(),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.settings, size: 14, color: cyanColor),
                              const SizedBox(width: 4),
                              Text(
                                'GESTIONAR',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 10,
                                  color: cyanColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 120,
                    margin: const EdgeInsets.only(top: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: dashboardCards.length,
                      itemBuilder: (context, index) {
                        final card = dashboardCards[index];
                        // Calcular balance o deuda según tipo de tarjeta
                        final displayBalance = card.isCredit
                            ? finance.getRemainingDebtForCard(card.name)
                            : finance.getCardBalance(card.name);

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CardDetailScreen(card: card),
                            ),
                          ),
                          child: Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFF1A1A1A),
                                        const Color(0xFF000000),
                                      ]
                                    : [Colors.white, Colors.grey.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    (card.isCredit ? Colors.cyan : Colors.green)
                                        .withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.2 : 0.05,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      card.isCredit
                                          ? Icons.credit_card
                                          : Icons.account_balance_wallet,
                                      color: card.isCredit
                                          ? Colors.cyan
                                          : Colors.green,
                                      size: 18,
                                    ),
                                    Row(
                                      children: [
                                        if (card.isFavorite)
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 12,
                                          ),
                                        const SizedBox(width: 4),
                                        Text(
                                          card.bankName.toUpperCase(),
                                          style: GoogleFonts.blackOpsOne(
                                            color: Colors.grey,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  card.name.toUpperCase(),
                                  style: GoogleFonts.spaceMono(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card.isCredit
                                          ? 'DEUDA PENDIENTE'
                                          : 'SALDO',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '\$${displayBalance.toStringAsFixed(0)}',
                                      style: GoogleFonts.spaceMono(
                                        color: card.isCredit
                                            ? Colors.redAccent
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          // --- GRID DE MENÚ ---
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildDashboardCard(
                  context,
                  title: 'REGISTRO',
                  icon: Icons.receipt_long,
                  accentColor: Colors.tealAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionsScreen(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  title: 'SUSCRIPCIONES',
                  icon: Icons.repeat,
                  accentColor: Colors.purpleAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionsScreen(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  title: 'METAS',
                  icon: Icons.flag,
                  accentColor: Colors.indigoAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SavingsScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  title: 'PRESUPUESTOS',
                  icon: Icons.speed,
                  accentColor: Colors.orangeAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BudgetsScreen(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  title: 'ESTADÍSTICAS',
                  icon: Icons.bar_chart,
                  accentColor: Colors.blueGrey,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '\$${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      // El tema ya define el color de fondo y borde, pero aquí podemos personalizar el borde para que coincida con el acento si queremos,
      // o mantenerlo sutil como pide el usuario ("borde fino del color de la categoría").
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: accentColor.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: accentColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCardDetails(
    BuildContext context,
    FinanceProvider finance,
    String cardName,
  ) {
    final debts = finance.getCreditDetails(cardName);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black87
          : Colors.grey.shade50,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  color: Colors.grey,
                  margin: const EdgeInsets.only(bottom: 20),
                ),
              ),
              Text(
                'DETALLE: $cardName',
                style: GoogleFonts.spaceMono(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: debts.length,
                  itemBuilder: (context, index) {
                    final debt = debts[index];
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final cyanColor = isDark
                        ? Colors.cyanAccent
                        : Colors.teal.shade700;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(color: cyanColor, width: 4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                debt['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: cyanColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${debt['installmentsLeft']} Cuotas Restantes',
                                  style: TextStyle(
                                    color: cyanColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PAGO MENSUAL',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '\$${debt['monthlyAmount'].toStringAsFixed(0)}',
                                    style: GoogleFonts.spaceMono(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'DEUDA TOTAL',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '\$${debt['totalRemaining'].toStringAsFixed(0)}',
                                    style: GoogleFonts.spaceMono(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
