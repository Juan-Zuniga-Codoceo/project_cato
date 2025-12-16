import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/finance_provider.dart';
// Asegúrate que esta ruta siga siendo correcta tras tu fix anterior
import '../../../finance/domain/models/category.dart';
import '../../providers/reward_provider.dart';
import '../../domain/models/reward_model.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  void _showAddRewardDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddRewardForm(),
    );
  }

  void _showStoreInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.storefront, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'FILOSOFÍA DE TIENDA',
                style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EL PRECIO DEL PLACER',
              style: GoogleFonts.spaceMono(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta tienda conecta tus deseos con tu realidad. Aquí no compras con puntos ficticios, compras con tu SALDO REAL de finanzas.\n\n'
              '1. Define recompensas (Juegos, Salidas, Caprichos).\n'
              '2. Asigna su costo real.\n'
              '3. Cómpralas solo si tienes liquidez.\n\n'
              'Al canjear, se crea automáticamente un GASTO en tu registro financiero. Si no puedes pagarlo aquí, no deberías comprarlo en la vida real.',
              style: GoogleFonts.inter(height: 1.5),
            ),
          ],
        ),
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
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MARKETPLACE',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showStoreInfo(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRewardDialog(context),
        label: const Text('NUEVO ITEM'),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Consumer2<RewardProvider, FinanceProvider>(
        builder: (context, rewardProvider, financeProvider, child) {
          final balance = financeProvider.totalBalance;
          final rewards = rewardProvider.availableRewards;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'CRÉDITOS DISPONIBLES',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(balance),
                      style: GoogleFonts.spaceMono(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rewards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.storefront,
                              size: 64,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'INVENTARIO VACÍO',
                              style: GoogleFonts.spaceMono(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Agrega recompensas para motivarte',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: rewards.length,
                        itemBuilder: (context, index) {
                          final reward = rewards[index];
                          return _RewardCard(
                            reward: reward,
                            currentBalance: balance,
                            onRedeem: () async {
                              final success = await rewardProvider.redeemReward(
                                context,
                                reward,
                              );
                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '¡${reward.title} ADQUIRIDO!',
                                        style: GoogleFonts.spaceMono(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Créditos insuficientes para esta operación.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            onDelete: () {
                              rewardProvider.deleteReward(reward.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final RewardModel reward;
  final double currentBalance;
  final VoidCallback onRedeem;
  final VoidCallback onDelete;

  const _RewardCard({
    required this.reward,
    required this.currentBalance,
    required this.onRedeem,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAfford = currentBalance >= reward.cost;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: canAfford
                  ? reward.color.withOpacity(0.5)
                  : theme.disabledColor.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (canAfford ? reward.color : Colors.grey).withOpacity(
                    0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  reward.icon,
                  size: 32,
                  color: canAfford ? reward.color : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  reward.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceMono(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: canAfford
                        ? theme.colorScheme.onSurface
                        : theme.disabledColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(reward.cost),
                style: GoogleFonts.spaceMono(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: canAfford ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: canAfford ? onRedeem : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: reward.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      canAfford ? 'COMPRAR' : 'BLOQUEADO',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: theme.disabledColor.withOpacity(0.5),
            ),
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}

class _AddRewardForm extends StatefulWidget {
  const _AddRewardForm();

  @override
  State<_AddRewardForm> createState() => _AddRewardFormState();
}

class _AddRewardFormState extends State<_AddRewardForm> {
  final _titleController = TextEditingController();
  final _costController = TextEditingController();
  int _selectedColor = Colors.blue.value;
  int _selectedIcon = Icons.card_giftcard.codePoint;
  CategoryModel? _selectedCategory;

  final List<Color> _colors = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.green,
    Colors.teal,
  ];

  final Map<String, IconData> _icons = {
    'Regalo': Icons.card_giftcard,
    'Juego': Icons.videogame_asset,
    'Comida': Icons.fastfood,
    'Ropa': Icons.checkroom,
    'Viaje': Icons.flight,
    'Tech': Icons.devices,
    'Relax': Icons.spa,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );
      if (financeProvider.categories.isNotEmpty) {
        try {
          setState(() {
            _selectedCategory = financeProvider.categories.firstWhere(
              (c) => c.name.toLowerCase().contains('entretenimiento'),
              orElse: () => financeProvider.categories.first,
            );
          });
        } catch (_) {}
      }
    });
  }

  // [SPRINT 136] Método para crear categoría rápida
  void _showQuickAddCategoryDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Nueva Categoría',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Ej: Videojuegos',
            prefixIcon: Icon(Icons.category),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final provider = Provider.of<FinanceProvider>(
                  context,
                  listen: false,
                );
                // Creamos una categoría básica (Icono y color por defecto o aleatorios si quisieras mejorar)
                final newCategory = CategoryModel(
                  id: DateTime.now().toString(),
                  name: nameController.text.trim(),
                  iconCode: Icons.local_offer.codePoint, // Icono genérico
                  colorValue: Colors.purpleAccent.value, // Color genérico
                  isDefault: false,
                );
                provider.addCategory(newCategory);

                // Actualizar selección
                setState(() {
                  _selectedCategory = newCategory;
                });

                Navigator.pop(context);
              }
            },
            child: const Text('CREAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final categories = financeProvider.categories;

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
              'DEFINIR RECOMPENSA',
              style: GoogleFonts.spaceMono(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nombre del item',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Costo (Créditos)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // [SPRINT 136] Row con Dropdown y Botón de Añadir
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<CategoryModel>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría Financiera',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((CategoryModel category) {
                      return DropdownMenuItem<CategoryModel>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              category.icon,
                              color: category.color,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 120, // Limit width to avoid overflow
                              child: Text(
                                category.name,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (CategoryModel? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Botón para crear categoría rápida
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.indigo,
                    ),
                    onPressed: _showQuickAddCategoryDialog,
                    tooltip: 'Crear nueva categoría',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              'ICONO',
              style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _icons.entries.map((entry) {
                final isSelected = _selectedIcon == entry.value.codePoint;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedIcon = entry.value.codePoint),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(_selectedColor).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Color(_selectedColor), width: 2)
                          : null,
                    ),
                    child: Icon(
                      entry.value,
                      color: isSelected ? Color(_selectedColor) : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'RAREZA (COLOR)',
              style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              alignment: WrapAlignment.center,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color.value),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final cost = double.tryParse(_costController.text) ?? 0;

                if (title.isNotEmpty && cost > 0) {
                  Provider.of<RewardProvider>(context, listen: false).addReward(
                    title: title,
                    cost: cost,
                    iconCode: _selectedIcon,
                    colorValue: _selectedColor,
                    categoryId: _selectedCategory?.id,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'CREAR ITEM',
                style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
