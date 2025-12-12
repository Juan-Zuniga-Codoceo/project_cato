import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'statistics_screen.dart';
import 'subscriptions_screen.dart';
import 'transactions_screen.dart';
import 'savings_screen.dart';
import 'budgets_screen.dart';

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

    return Scaffold(
      body: Column(
        children: [
          // Header - Balance Total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              24,
              60,
              24,
              24,
            ), // SafeArea top padding manual
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showInfoDialog(
                    context,
                    'CAPITAL DE OPERACIÓN',
                    'Es tu liquidez actual. Un balance positivo te da libertad de maniobra; uno negativo te hace esclavo de las deudas. Cuídalo.',
                    Icons.account_balance_wallet,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BALANCE TOTAL',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<FinanceProvider>(
                        builder: (context, provider, child) {
                          final isZeroState =
                              provider.totalBalance == 0 &&
                              provider.totalIncome == 0 &&
                              provider.totalExpenses == 0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${provider.totalBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isZeroState) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '"Tu imperio empieza con la primera moneda."',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildBreakdownItem(
                                    context,
                                    'INGRESOS',
                                    provider.totalIncome,
                                    Colors.greenAccent,
                                    Icons.arrow_upward,
                                    onTap: () => _showInfoDialog(
                                      context,
                                      'FLUJO DE ENTRADA',
                                      'El combustible de tu sistema. Busca diversificar tus fuentes, no solo aumentar el caudal.',
                                      Icons.arrow_upward,
                                    ),
                                  ),
                                  _buildBreakdownItem(
                                    context,
                                    'GASTOS',
                                    provider.totalExpenses,
                                    AppTheme.danger,
                                    Icons.arrow_downward,
                                    onTap: () => _showInfoDialog(
                                      context,
                                      'FUGAS DE CAPITAL',
                                      'Fugas de energía. No se trata de no gastar, sino de que cada moneda tenga un propósito estratégico.',
                                      Icons.arrow_downward,
                                    ),
                                  ),
                                  _buildBreakdownItem(
                                    context,
                                    'SUSCRIP.',
                                    provider.totalMonthlySubscriptions,
                                    AppTheme.secondary,
                                    Icons.repeat,
                                    onTap: () => _showInfoDialog(
                                      context,
                                      'COSTOS PASIVOS',
                                      'Costos pasivos. Revisalos mensualmente; son los asesinos silenciosos del ahorro.',
                                      Icons.repeat,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dashboard Grid (Menú Principal)
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4, // Más apaisado para estilo tarjeta técnica
              children: [
                // Tarjeta 1: Suscripciones
                _buildDashboardCard(
                  context,
                  title: 'SUSCRIPCIONES',
                  icon: Icons.repeat,
                  accentColor: Colors.purpleAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionsScreen(),
                      ),
                    );
                  },
                ),
                // Tarjeta 2: Registro Diario
                _buildDashboardCard(
                  context,
                  title: 'REGISTRO',
                  icon: Icons.receipt_long,
                  accentColor: Colors.tealAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsScreen(),
                      ),
                    );
                  },
                ),
                // Tarjeta 3: Metas
                _buildDashboardCard(
                  context,
                  title: 'METAS',
                  icon: Icons.flag,
                  accentColor: Colors.indigoAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SavingsScreen()),
                    );
                  },
                ),
                // Tarjeta 4: Presupuestos
                _buildDashboardCard(
                  context,
                  title: 'PRESUPUESTOS',
                  icon: Icons.speed,
                  accentColor: Colors.orangeAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BudgetsScreen(),
                      ),
                    );
                  },
                ),
                // Tarjeta 5: Estadísticas
                _buildDashboardCard(
                  context,
                  title: 'ESTADÍSTICAS',
                  icon: Icons.bar_chart,
                  accentColor: Colors.blueGrey,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatisticsScreen(),
                      ),
                    );
                  },
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
}
