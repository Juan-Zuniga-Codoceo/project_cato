import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/category.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';

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

  // --- LÓGICA DE VALORACIÓN (RATE APP) ---
  void _checkReviewRequest(BuildContext context) {
    final box = Hive.box(StorageService.settingsBoxName);
    int opsCount = box.get('opsCount', defaultValue: 0) + 1;
    box.put('opsCount', opsCount);

    bool dontShow = box.get('dontShowReview', defaultValue: false);

    if (!dontShow && (opsCount == 5 || opsCount % 20 == 0)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            "¿Te sirve CATO?",
            style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Si la aplicación te está ayudando a organizar tu vida, ¿nos regalarías 5 estrellas? Nos ayuda mucho a seguir mejorando.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                box.put('dontShowReview', true);
                Navigator.pop(ctx);
              },
              child: const Text(
                "No volver a mostrar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Más tarde"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                box.put('dontShowReview', true);
                Navigator.pop(ctx);
                final url = Uri.parse(
                  "market://details?id=com.example.mens_lifestyle_app",
                );
                launchUrl(url, mode: LaunchMode.externalApplication);
              },
              child: const Text("CALIFICAR"),
            ),
          ],
        ),
      );
    }
  }

  // --- MODAL DE AGREGAR TRANSACCIÓN ---
  void _showAddTransactionDialog(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores dinámicos
    final textColor = theme.colorScheme.onSurface;
    final hintColor = theme.hintColor;
    final inputFillColor = isDark ? Colors.black26 : Colors.grey.shade100;
    final cardColor = theme.cardColor;

    // Datos
    final cards = finance.getAvailablePaymentMethods();
    final categories = finance.categories;

    // Validación inicial
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Primero debes crear una categoría.")),
      );
      return;
    }

    // Controladores
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    // Estado inicial
    CategoryModel selectedCategory = categories.first;
    String selectedCard = cards.isNotEmpty ? cards.first : 'Efectivo';
    bool isExpense = true;
    DateTime selectedDate = DateTime.now();
    int selectedInstallments = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // [FIX] Refetch data to ensure updates (e.g. new category) are reflected
          final categories = finance.categories;
          final cards = finance.getAvailablePaymentMethods();

          // [FIX] Protección contra Dropdown Crash: Si la categoría seleccionada no existe en la lista, resetear.
          if (!categories.contains(selectedCategory)) {
            if (categories.isNotEmpty) selectedCategory = categories.first;
          }

          // Verificar si es Crédito para mostrar slider de cuotas
          bool isCreditSelected = finance.isCreditMethod(selectedCard);

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

                  // Inputs de Texto
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

                  // Selector de Categoría + Botón Crear
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<CategoryModel>(
                          value: selectedCategory,
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
                                  value: cat,
                                  child: Row(
                                    children: [
                                      Icon(
                                        cat.icon,
                                        color: cat.color,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        cat.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setModalState(() => selectedCategory = val);
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
                            // Diálogo rápido para crear categoría
                            _showQuickAddCategoryDialog(context, finance, (
                              newCat,
                            ) {
                              setModalState(() {
                                // Al volver, seleccionar la nueva
                                if (finance.categories.contains(newCat)) {
                                  selectedCategory = newCat;
                                }
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
                      selectedInstallments =
                          1; // Resetear cuotas al cambiar tarjeta
                    }),
                  ),

                  // Slider de Cuotas (Solo si es Gasto + Tarjeta de Crédito)
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
                            max: 36, // Hasta 36 cuotas
                            divisions: 35,
                            activeColor: Colors.cyan,
                            onChanged: (val) {
                              setModalState(() {
                                selectedInstallments = val.toInt();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  // Selector de Fecha
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      // Label dinámico: "Fecha 1ª Cuota" si es en cuotas, sino "Fecha"
                      "${(isExpense && isCreditSelected && selectedInstallments > 1) ? "Fecha 1ª Cuota" : "Fecha"}: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
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

                      // LÓGICA DE GUARDADO
                      if (selectedInstallments > 1 &&
                          isCreditSelected &&
                          isExpense) {
                        // Caso Cuotas: Usar el método especial que genera N transacciones
                        finance.addInstallmentTransaction(
                          title: titleController.text,
                          totalAmount: double.parse(amountController.text),
                          date: selectedDate,
                          category: selectedCategory,
                          paymentMethod: selectedCard,
                          installments: selectedInstallments,
                        );
                      } else {
                        // Caso Normal (1 cuota o ingreso)
                        final newTx = Transaction(
                          id: DateTime.now().toString(),
                          title: titleController.text,
                          amount: double.parse(amountController.text),
                          date: selectedDate,
                          isExpense: isExpense,
                          category: selectedCategory,
                          paymentMethod: selectedCard,
                          installments: 1,
                        );
                        finance.addTransaction(newTx);
                      }

                      Navigator.pop(context);
                      _checkReviewRequest(context); // Pedir valoración
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

  // --- WIDGETS AUXILIARES DEL MODAL ---

  void _showQuickAddCategoryDialog(
    BuildContext context,
    FinanceProvider finance,
    Function(CategoryModel) onCreated,
  ) {
    final controller = TextEditingController();

    // Predefined colors
    final List<Color> colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    // Predefined icons
    final List<IconData> icons = [
      Icons.fastfood,
      Icons.restaurant,
      Icons.local_cafe,
      Icons.local_bar,
      Icons.directions_car,
      Icons.directions_bus,
      Icons.flight,
      Icons.local_gas_station,
      Icons.shopping_bag,
      Icons.shopping_cart,
      Icons.credit_card,
      Icons.attach_money,
      Icons.home,
      Icons.build,
      Icons.pets,
      Icons.child_friendly,
      Icons.fitness_center,
      Icons.pool,
      Icons.sports_soccer,
      Icons.videogame_asset,
      Icons.movie,
      Icons.music_note,
      Icons.book,
      Icons.school,
      Icons.work,
      Icons.business,
      Icons.computer,
      Icons.phone_android,
      Icons.medical_services,
      Icons.local_hospital,
      Icons.favorite,
      Icons.spa,
      Icons.lightbulb,
      Icons.wifi,
      Icons.security,
      Icons.warning,
    ];

    Color selectedColor = colors[5]; // Default blue
    IconData selectedIcon = icons[0]; // Default icon

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Nueva Categoría",
                    style: GoogleFonts.spaceMono(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Color',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: colors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: selectedColor == color
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                            child: selectedColor == color
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Icono',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: icons.length,
                      itemBuilder: (context, index) {
                        final icon = icons[index];
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedIcon = icon;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedIcon == icon
                                  ? selectedColor.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: selectedIcon == icon
                                  ? Border.all(color: selectedColor, width: 2)
                                  : Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(
                              icon,
                              color: selectedIcon == icon
                                  ? selectedColor
                                  : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        finance
                            .addCategory(
                              controller.text.trim(),
                              selectedColor.value,
                              selectedIcon.codePoint,
                            )
                            .then((_) {
                              final newCat = finance.categories.last;
                              onCreated(newCat);
                              Navigator.pop(ctx);
                            });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      "CREAR CATEGORÍA",
                      style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
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

    // Colores de alto contraste para Light Mode
    final bgColor = isDark
        ? theme.scaffoldBackgroundColor
        : const Color(0xFFF5F5F5);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Limpiar SnackBars al salir de la pantalla
        if (didPop) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
      },
      child: Scaffold(
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

            // Separación de fechas
            final now = DateTime.now();
            final endOfToday = DateTime(
              now.year,
              now.month,
              now.day,
              23,
              59,
              59,
            );

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
            futureTxs.sort(
              (a, b) => a.date.compareTo(b.date),
            ); // Futuro: Ascendente (Próximo primero)
            historyTxs.sort(
              (a, b) => b.date.compareTo(a.date),
            ); // Pasado: Descendente (Reciente primero)

            return TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(historyTxs, isFuture: false),
                _buildTransactionList(futureTxs, isFuture: true),
              ],
            );
          },
        ),
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

        // [FIX] Limpiar SnackBars acumulados para que el botón Deshacer sea visible
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${tx.title} eliminado."),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'DESHACER',
              textColor: Colors.cyanAccent,
              onPressed: () => finance.addTransaction(deletedTx),
            ),
          ),
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

    // Formato
    final dateStr = DateFormat(
      'EEE d MMM',
      'es_ES',
    ).format(tx.date).toUpperCase();
    final isExpense = tx.isExpense;

    return Card(
      elevation: 0,
      // Alto Contraste para Light Mode (Blanco) y Dark Mode (Oscuro con tinte)
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
            // Badge Medio de Pago
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
            // Badge Cuotas
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
            // Badge Pendiente
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
