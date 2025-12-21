import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/category.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- MÉTODO PARA AGREGAR TRANSACCIÓN ---
  void _showAddTransactionDialog(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores dinámicos
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey : Colors.grey.shade600;
    final inputFillColor = isDark ? Colors.black26 : Colors.grey.shade100;

    final cards = finance.getAvailablePaymentMethods();
    final categories = finance.categories;

    // Controladores
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    CategoryModel? selectedCategory = categories.isNotEmpty
        ? categories.first
        : null;
    String selectedCard = cards.isNotEmpty ? cards.first : 'Efectivo';
    bool isExpense = true;
    DateTime selectedDate = DateTime.now();
    int selectedInstallments = 1; // [NUEVO] Variable para cuotas

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Verificar si la tarjeta seleccionada es de CRÉDITO
          bool isCreditSelected = false;
          try {
            final cardObj = finance.myCards.firstWhere(
              (c) => c.name == selectedCard,
            );
            isCreditSelected = cardObj.isCredit;
          } catch (_) {
            isCreditSelected = false;
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "NUEVA OPERACIÓN",
                    style: GoogleFonts.spaceMono(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Toggle Ingreso/Gasto
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => isExpense = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isExpense
                                  ? Colors.redAccent.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isExpense
                                    ? Colors.redAccent
                                    : (isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade300),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "GASTO",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isExpense
                                      ? Colors.redAccent
                                      : hintColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => isExpense = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isExpense
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: !isExpense
                                    ? Colors.green
                                    : (isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade300),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "INGRESO",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !isExpense ? Colors.green : hintColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildInput(
                    titleController,
                    'Concepto',
                    Icons.description,
                    textColor,
                    hintColor,
                    inputFillColor,
                  ),
                  const SizedBox(height: 16),
                  _buildInput(
                    amountController,
                    'Monto',
                    Icons.attach_money,
                    textColor,
                    hintColor,
                    inputFillColor,
                    isNumber: true,
                  ),
                  const SizedBox(height: 16),

                  // Selector de Categoría con botón de agregar
                  if (selectedCategory != null)
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<CategoryModel>(
                            value: selectedCategory,
                            dropdownColor: isDark
                                ? Colors.grey[850]
                                : Colors.white,
                            style: TextStyle(color: textColor, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Categoría',
                              labelStyle: TextStyle(color: hintColor),
                              prefixIcon: Icon(
                                Icons.category,
                                color: hintColor,
                              ),
                              filled: true,
                              fillColor: inputFillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            items: categories
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(
                                      cat.name,
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setModalState(() => selectedCategory = val),
                          ),
                        ),
                        // [NUEVO] Botón para crear categoría
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.cyanAccent,
                            size: 28,
                          ),
                          tooltip: 'Nueva Categoría',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                final catController = TextEditingController();
                                final colorNotifier = ValueNotifier<Color>(
                                  Colors.blue,
                                );

                                return AlertDialog(
                                  backgroundColor: isDark
                                      ? Colors.grey[900]
                                      : Colors.white,
                                  title: Text(
                                    "Nueva Categoría",
                                    style: GoogleFonts.spaceMono(
                                      color: textColor,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: catController,
                                        style: TextStyle(color: textColor),
                                        decoration: InputDecoration(
                                          labelText: 'Nombre',
                                          labelStyle: TextStyle(
                                            color: hintColor,
                                          ),
                                          filled: true,
                                          fillColor: inputFillColor,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ValueListenableBuilder<Color>(
                                        valueListenable: colorNotifier,
                                        builder: (context, selectedColor, _) {
                                          return Wrap(
                                            spacing: 8,
                                            children:
                                                [
                                                  Colors.blue,
                                                  Colors.red,
                                                  Colors.green,
                                                  Colors.orange,
                                                  Colors.purple,
                                                  Colors.pink,
                                                ].map((color) {
                                                  return GestureDetector(
                                                    onTap: () =>
                                                        colorNotifier.value =
                                                            color,
                                                    child: Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: color,
                                                        shape: BoxShape.circle,
                                                        border:
                                                            selectedColor ==
                                                                color
                                                            ? Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 3,
                                                              )
                                                            : null,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("CANCELAR"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.cyanAccent,
                                        foregroundColor: Colors.black,
                                      ),
                                      onPressed: () async {
                                        if (catController.text.isNotEmpty) {
                                          await finance.addCategory(
                                            catController.text,
                                            colorNotifier.value.value,
                                            Icons.category.codePoint,
                                          );
                                          Navigator.pop(ctx);

                                          setModalState(() {
                                            selectedCategory =
                                                finance.categories.last;
                                          });

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Categoría creada: ${catController.text}',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text("CREAR"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Selector de Tarjeta
                  DropdownButtonFormField<String>(
                    value: selectedCard,
                    dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Cuenta / Medio de Pago',
                      labelStyle: TextStyle(color: hintColor),
                      prefixIcon: Icon(
                        Icons.credit_card,
                        color: isExpense ? Colors.redAccent : Colors.green,
                      ),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items: cards
                        .map(
                          (card) => DropdownMenuItem(
                            value: card,
                            child: Text(
                              card,
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedCard = val!;
                        selectedInstallments = 1; // Resetear cuotas
                      });
                    },
                  ),

                  // [NUEVO] SELECTOR DE CUOTAS
                  if (isExpense && isCreditSelected) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: inputFillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "CUOTAS: $selectedInstallments",
                                style: GoogleFonts.spaceMono(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                selectedInstallments == 1
                                    ? "Sin interés"
                                    : "Mensuales",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: hintColor,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: selectedInstallments.toDouble(),
                            min: 1,
                            max: 48,
                            divisions: 47,
                            activeColor: Colors.cyan,
                            onChanged: (val) => setModalState(
                              () => selectedInstallments = val.toInt(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Selector de Fecha
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.calendar_today, color: hintColor),
                    title: Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: TextStyle(color: textColor),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null)
                        setModalState(() => selectedDate = picked);
                    },
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isExpense
                          ? Colors.redAccent
                          : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          amountController.text.isEmpty ||
                          selectedCategory == null)
                        return;

                      final newTx = Transaction(
                        id: DateTime.now().toString(),
                        title: titleController.text,
                        amount: double.tryParse(amountController.text) ?? 0,
                        date: selectedDate,
                        isExpense: isExpense,
                        category: selectedCategory!,
                        paymentMethod: selectedCard,
                        installments: selectedInstallments,
                      );

                      finance.addTransaction(newTx);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "REGISTRAR OPERACIÓN",
                      style: GoogleFonts.spaceMono(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper para inputs
  Widget _buildInput(
    TextEditingController ctrl,
    String label,
    IconData icon,
    Color textColor,
    Color hintColor,
    Color fillColor, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor),
        prefixIcon: Icon(icon, color: hintColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark
            ? theme.scaffoldBackgroundColor
            : const Color(0xFFF5F5F5),
        elevation: 0,
        title: Text(
          "REGISTRO TÁCTICO",
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: textColor.withOpacity(0.6),
          labelStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "EJECUTADO"),
            Tab(text: "PROYECCIONES"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _showAddTransactionDialog(context),
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, child) {
          final transactions = finance.transactions;
          final now = DateTime.now();
          final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

          final futureTxs = transactions
              .where((tx) => tx.date.isAfter(endOfToday))
              .toList();
          final historyTxs = transactions
              .where(
                (tx) =>
                    tx.date.isBefore(endOfToday) ||
                    tx.date.isAtSameMomentAs(endOfToday),
              )
              .toList();

          futureTxs.sort((a, b) => a.date.compareTo(b.date));
          historyTxs.sort((a, b) => b.date.compareTo(a.date));

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionList(historyTxs, isFuture: false),
              _buildTransactionList(futureTxs, isFuture: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionList(
    List<Transaction> txs, {
    required bool isFuture,
  }) {
    if (txs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFuture ? Icons.radar : Icons.history,
              size: 64,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isFuture
                  ? "Sin proyecciones futuras"
                  : "Sin registros ejecutados",
              style: GoogleFonts.spaceMono(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: txs.length,
      itemBuilder: (context, index) {
        final tx = txs[index];
        return _buildTransactionItem(context, tx, isFuture: isFuture);
      },
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Transaction tx, {
    required bool isFuture,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateStr = DateFormat(
      'EEE d MMM',
      'es_ES',
    ).format(tx.date).toUpperCase();
    final isExpense = tx.isExpense;
    final finance = Provider.of<FinanceProvider>(context, listen: false);

    // [NUEVO] Envolver en Dismissible para swipe-to-delete
    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "ELIMINAR OPERACIÓN",
              style: GoogleFonts.spaceMono(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.delete_forever, color: Colors.white, size: 28),
          ],
        ),
      ),
      onDismissed: (_) {
        final deletedTx = tx;
        finance.deleteTransaction(tx.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${tx.title} eliminado.",
              style: GoogleFonts.spaceMono(),
            ),
            backgroundColor: Colors.grey[900],
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'DESHACER',
              textColor: Colors.cyanAccent,
              onPressed: () => finance.addTransaction(deletedTx),
            ),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: isFuture
            ? (isDark ? const Color(0xFF102027) : Colors.blue.shade50)
            : theme.cardColor,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isFuture
              ? BorderSide(color: Colors.cyanAccent.withOpacity(0.3), width: 1)
              : BorderSide.none,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dateStr.split(' ')[0],
                style: GoogleFonts.blackOpsOne(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              Text(
                dateStr.split(' ')[1],
                style: GoogleFonts.blackOpsOne(
                  fontSize: 18,
                  color: isFuture
                      ? Colors.cyanAccent
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          title: Text(
            tx.title,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              if (tx.paymentMethod != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tx.paymentMethod!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (tx.installments > 1) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '${tx.installments}x CUOTAS',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (isFuture) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    "PENDIENTE",
                    style: TextStyle(fontSize: 8, color: Colors.cyanAccent),
                  ),
                ),
              ],
            ],
          ),
          trailing: Text(
            '\$${tx.amount.toStringAsFixed(0)}',
            style: GoogleFonts.spaceMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isExpense
                  ? (isFuture ? Colors.orangeAccent : Colors.redAccent)
                  : Colors.greenAccent,
            ),
          ),
        ),
      ),
    );
  }
}
