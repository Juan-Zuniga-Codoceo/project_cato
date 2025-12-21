import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/category.dart';
import '../../../../core/theme/app_theme.dart';

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

  // --- SNACKBAR TÁCTICO SEGURO ---
  void _showTacticalSnackBar(String message, {VoidCallback? onUndo}) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars(); // Matar anteriores

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 1500),
        action: onUndo != null
            ? SnackBarAction(
                label: 'DESHACER',
                textColor: Colors.cyanAccent,
                onPressed: onUndo,
              )
            : null,
      ),
    );
  }

  // --- MODAL DE AGREGAR TRANSACCIÓN ---
  void _showAddTransactionDialog(BuildContext context) async {
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.colorScheme.onSurface;
    final hintColor = theme.hintColor;
    final inputFillColor = isDark ? Colors.black26 : Colors.grey.shade100;
    final cardColor = theme.cardColor;

    // 1. Asegurar categorías
    if (finance.categories.isEmpty) {
      await finance.addCategory(
        "General",
        Colors.grey.value,
        Icons.category.codePoint,
      );
    }

    // Datos iniciales
    final cards = finance.getAvailablePaymentMethods();
    final categories = finance.categories;

    // Controladores
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    // Estado inicial
    String? selectedCategoryId =
        categories.first.id; // Usamos ID para evitar errores de referencia
    String selectedCard = cards.isNotEmpty ? cards.first : 'Efectivo';
    bool isExpense = true;
    DateTime selectedDate = DateTime.now();
    int selectedInstallments = 1;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // [FIX CRÍTICO] Re-validación en cada renderizado del modal
          // Si la categoría seleccionada (por ID) no está en la lista actual, resetear a la primera.
          final categoryExists = categories.any(
            (c) => c.id == selectedCategoryId,
          );
          if (!categoryExists && categories.isNotEmpty) {
            selectedCategoryId = categories.first.id;
          }

          // Lo mismo para la tarjeta
          if (!cards.contains(selectedCard) && cards.isNotEmpty) {
            selectedCard = cards.first;
          }

          // Lógica de cuotas
          bool isCreditSelected = finance.isCreditMethod(selectedCard);

          String dateLabel = "Fecha";
          if (isExpense && isCreditSelected && selectedInstallments > 1) {
            dateLabel = "Fecha 1ª Cuota";
          }

          // Encontrar el objeto categoría real basado en el ID seleccionado
          final activeCategoryObj = categories.firstWhere(
            (c) => c.id == selectedCategoryId,
            orElse: () => categories.first,
          );

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
                    "REGISTRAR OPERACIÓN",
                    style: GoogleFonts.spaceMono(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Toggle Gasto/Ingreso
                  Row(
                    children: [
                      Expanded(
                        child: _buildToggleBtn(
                          "GASTO",
                          isExpense,
                          Colors.redAccent,
                          () => setModalState(() => isExpense = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildToggleBtn(
                          "INGRESO",
                          !isExpense,
                          Colors.green,
                          () => setModalState(() => isExpense = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Inputs
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

                  // Selector Categoría (POR ID)
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategoryId, // Usamos el ID como valor
                          dropdownColor: cardColor,
                          style: TextStyle(color: textColor, fontSize: 16),
                          decoration: _inputDecoration(
                            'Categoría',
                            Icons.category,
                            hintColor,
                            inputFillColor,
                          ),
                          items: categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat.id, // El valor es el ID
                                  child: Row(
                                    children: [
                                      Icon(
                                        cat.icon,
                                        color: cat.color,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          cat.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setModalState(() => selectedCategoryId = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: inputFillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.cyan),
                          onPressed: () {
                            _showQuickAddCategoryDialog(context, finance, (
                              newCat,
                            ) {
                              setModalState(() {
                                selectedCategoryId = newCat.id;
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Selector Medio de Pago
                  DropdownButtonFormField<String>(
                    value: selectedCard,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: _inputDecoration(
                      'Medio de Pago',
                      Icons.credit_card,
                      hintColor,
                      inputFillColor,
                    ),
                    items: cards
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setModalState(() {
                      selectedCard = val!;
                      selectedInstallments = 1;
                    }),
                  ),

                  // Slider Cuotas
                  if (isExpense && isCreditSelected) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: inputFillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                      ),
                      child: Column(
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
                                    ? "Contado"
                                    : "Mensuales",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hintColor,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: selectedInstallments.toDouble(),
                            min: 1,
                            max: 36,
                            divisions: 35,
                            activeColor: Colors.cyan,
                            onChanged: (val) => setModalState(
                              () => selectedInstallments = val.toInt(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  // Selector Fecha
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "$dateLabel: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Icon(Icons.calendar_today, color: hintColor),
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

                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isExpense
                          ? Colors.redAccent
                          : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          amountController.text.isEmpty)
                        return;

                      // Usamos el objeto categoría real encontrado arriba
                      final categoryToSave = activeCategoryObj;

                      if (selectedInstallments > 1 &&
                          isCreditSelected &&
                          isExpense) {
                        finance.addInstallmentTransaction(
                          title: titleController.text,
                          totalAmount: double.parse(amountController.text),
                          date: selectedDate,
                          category: categoryToSave,
                          paymentMethod: selectedCard,
                          installments: selectedInstallments,
                        );
                      } else {
                        final newTx = Transaction(
                          id: DateTime.now().toString(),
                          title: titleController.text,
                          amount: double.parse(amountController.text),
                          date: selectedDate,
                          isExpense: isExpense,
                          category: categoryToSave,
                          paymentMethod: selectedCard,
                          installments: 1,
                        );
                        finance.addTransaction(newTx);
                      }

                      Navigator.pop(context);
                    },
                    child: Text(
                      "GUARDAR",
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

  // --- WIDGETS AUXILIARES ---

  void _showQuickAddCategoryDialog(
    BuildContext context,
    FinanceProvider finance,
    Function(CategoryModel) onCreated,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nueva Categoría"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nombre"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                finance
                    .addCategory(
                      controller.text,
                      Colors.blue.value,
                      Icons.label.codePoint,
                    )
                    .then((_) {
                      try {
                        // Buscar la nueva y devolverla
                        final newCat = finance.categories.lastWhere(
                          (c) => c.name == controller.text,
                        );
                        onCreated(newCat);
                      } catch (e) {
                        print("Error: $e");
                      }
                      Navigator.pop(ctx);
                    });
              }
            },
            child: const Text("CREAR"),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(
    String text,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : null,
          border: Border.all(color: isSelected ? color : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? color : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    Color hintColor,
    Color fillColor,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: hintColor),
      prefixIcon: Icon(icon, color: hintColor),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label,
    IconData icon,
    Color text,
    Color hint,
    Color fill, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: text),
      decoration: _inputDecoration(label, icon, hint, fill),
    );
  }

  // --- BUILD PRINCIPAL ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? theme.scaffoldBackgroundColor
        : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "REGISTRO TÁCTICO",
          style: GoogleFonts.spaceMono(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyan,
          labelColor: Colors.cyan,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "EJECUTADO"),
            Tab(text: "PROYECCIONES"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _showAddTransactionDialog(context),
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, child) {
          final transactions = finance.transactions;
          if (transactions.isEmpty)
            return const Center(child: Text("Sin registros."));

          final now = DateTime.now();
          final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

          // Filtros
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

          // Ordenamiento
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
        return _buildDismissibleTransaction(
          context,
          txs[index],
          isFuture: isFuture,
        );
      },
    );
  }

  Widget _buildDismissibleTransaction(
    BuildContext context,
    Transaction tx, {
    required bool isFuture,
  }) {
    final finance = Provider.of<FinanceProvider>(context, listen: false);

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
              "ELIMINAR",
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

        // [FIX] Notificación segura
        _showTacticalSnackBar(
          "${tx.title} eliminado",
          onUndo: () => finance.addTransaction(deletedTx),
        );
      },
      child: _TransactionCard(tx: tx, isFuture: isFuture),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction tx;
  final bool isFuture;

  const _TransactionCard({required this.tx, required this.isFuture});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dateStr = DateFormat(
      'EEE d MMM',
      'es_ES',
    ).format(tx.date).toUpperCase();
    final isExpense = tx.isExpense;

    return Card(
      elevation: 0,
      color: isFuture
          ? (isDark ? const Color(0xFF102027) : Colors.blue.shade50)
          : theme.cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isFuture
            ? BorderSide(color: Colors.cyan.withOpacity(0.3))
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dateStr.split(' ')[0],
              style: GoogleFonts.blackOpsOne(fontSize: 10, color: Colors.grey),
            ),
            Text(
              dateStr.split(' ')[1],
              style: GoogleFonts.blackOpsOne(
                fontSize: 18,
                color: isFuture ? Colors.cyan : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        title: Text(
          tx.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            if (tx.paymentMethod != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tx.paymentMethod!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            if (tx.installments > 1) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  "PENDIENTE",
                  style: TextStyle(fontSize: 8, color: Colors.cyan),
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
                ? (isFuture ? Colors.orange : Colors.red)
                : Colors.green,
          ),
        ),
      ),
    );
  }
}
