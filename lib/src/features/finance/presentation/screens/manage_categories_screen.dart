import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/finance_provider.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  void _showAddCategoryModal(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final nameController = TextEditingController();

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
      Icons.computer,
      Icons.phone_android,
      Icons.wifi,
      Icons.local_hospital,
      Icons.healing,
      Icons.spa,
      Icons.favorite,
    ];

    Color selectedColor = colors[0];
    IconData selectedIcon = icons[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
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
                      'Nueva Categoría',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Color',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
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
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: selectedIcon == icon
                                        ? Colors.indigo.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: selectedIcon == icon
                                        ? Border.all(
                                            color: Colors.indigo,
                                            width: 2,
                                          )
                                        : Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      icon,
                                      color: selectedIcon == icon
                                          ? Colors.indigo
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                                if (selectedIcon == icon)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.indigo,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isNotEmpty) {
                          provider.addCategory(
                            name,
                            selectedColor.value,
                            selectedIcon.codePoint,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Crear Categoría'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Categorías')),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category.color,
                    child: Icon(category.icon, color: Colors.white),
                  ),
                  title: Text(category.name),
                  trailing: category.isDefault
                      ? const Icon(Icons.lock, color: Colors.grey)
                      : IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar Categoría'),
                                content: Text(
                                  '¿Seguro que deseas eliminar "${category.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      provider.deleteCategory(category.id);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryModal(context),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
