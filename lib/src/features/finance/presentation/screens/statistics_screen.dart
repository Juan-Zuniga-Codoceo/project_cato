import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/category.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Transaction> _getTransactionsForDay(
    DateTime day,
    FinanceProvider provider,
  ) {
    return provider.transactions.where((tx) {
      return isSameDay(tx.date, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Calendario'),
              Tab(text: 'Gráfico'),
            ],
          ),
        ),
        body: Consumer<FinanceProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [_buildCalendarTab(provider), _buildChartTab(provider)],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarTab(FinanceProvider provider) {
    final selectedTransactions = _getTransactionsForDay(
      _selectedDay!,
      provider,
    );

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) => _getTransactionsForDay(day, provider),
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;
              final transactions = events as List<Transaction>;
              final hasExpense = transactions.any((tx) => tx.isExpense);
              final hasIncome = transactions.any((tx) => !tx.isExpense);

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasIncome)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (hasExpense)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: selectedTransactions.length,
            itemBuilder: (context, index) {
              final tx = selectedTransactions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: tx.category.color.withOpacity(0.1),
                  child: Icon(tx.category.icon, color: tx.category.color),
                ),
                title: Text(
                  tx.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${tx.category.name} • ${DateFormat('HH:mm').format(tx.date)}',
                ),
                trailing: Text(
                  '\$${tx.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: tx.isExpense ? Colors.red : Colors.green,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartTab(FinanceProvider provider) {
    final expenses = provider.transactions.where((tx) => tx.isExpense).toList();
    if (expenses.isEmpty) {
      return const Center(child: Text('No hay gastos registrados'));
    }

    double totalExpenses = 0;
    final Map<String, double> totalsById = {};

    for (var tx in expenses) {
      totalsById[tx.category.id] =
          (totalsById[tx.category.id] ?? 0) + tx.amount;
      totalExpenses += tx.amount;
    }

    final List<PieChartSectionData> sections = totalsById.entries.map((entry) {
      final categoryId = entry.key;
      final total = entry.value;
      final category = provider.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => CategoryModel.getDefaultCategories().first, // Fallback
      );

      final percentage = (total / totalExpenses) * 100;

      return PieChartSectionData(
        color: category.color,
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: totalsById.entries.map((entry) {
                final categoryId = entry.key;
                final total = entry.value;
                final category = provider.categories.firstWhere(
                  (c) => c.id == categoryId,
                  orElse: () => CategoryModel.getDefaultCategories().first,
                );

                return ListTile(
                  leading: Icon(category.icon, color: category.color),
                  title: Text(category.name),
                  trailing: Text(
                    '\$${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
