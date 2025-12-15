import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/habit_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../../academic/providers/academic_provider.dart';
import '../../../../core/utils/data_seeder.dart';
import '../../../../core/providers/finance_provider.dart';
import 'manifest_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Configuración'), centerTitle: true),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Dark Mode Toggle
          SwitchListTile(
            title: const Text('🌙 Modo Oscuro'),
            subtitle: const Text('Cambia entre tema claro y oscuro'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),

          const Divider(),

          // Reminder Time
          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text('⏰ Hora de Recordatorio'),
            subtitle: const Text('Configura la hora de notificaciones diarias'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 9, minute: 0),
              );

              if (picked != null) {
                // Update the default notification time
                // This could be stored in settings and used as default for new habits
                final settingsBox = Hive.box(StorageService.settingsBoxName);
                settingsBox.put('defaultReminderHour', picked.hour);
                settingsBox.put('defaultReminderMinute', picked.minute);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ Hora configurada: ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  );
                }
              }
            },
          ),

          const Divider(),

          // Grading Scale Selector
          ValueListenableBuilder(
            valueListenable: Hive.box(
              StorageService.settingsBoxName,
            ).listenable(keys: ['gradingScale']),
            builder: (context, box, _) {
              return ListTile(
                leading: const Icon(Icons.school),
                title: const Text('🎓 Escala de Notas'),
                subtitle: const Text('Define el sistema de evaluación'),
                trailing: DropdownButton<int>(
                  value: box.get('gradingScale', defaultValue: 0),
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Chile (1.0 - 7.0)'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Latam (0.0 - 10.0)'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Porcentaje (0 - 100)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      box.put('gradingScale', value);
                      context.read<AcademicProvider>().refresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Escala de notas actualizada'),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),

          const Divider(),

          // User Name
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('👤 Nombre de Usuario'),
            subtitle: Text(
              habitProvider.userStats.userName.isEmpty
                  ? 'Sin nombre'
                  : habitProvider.userStats.userName,
            ),
            trailing: const Icon(Icons.edit),
            onTap: () {
              _showEditNameDialog(context, habitProvider);
            },
          ),

          const Divider(),
          const SizedBox(height: 16),

          // Data & System Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'DATOS Y SISTEMA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Exportar Finanzas (CSV)'),
            onTap: () async {
              final financeProvider = Provider.of<FinanceProvider>(
                context,
                listen: false,
              );
              await financeProvider.exportTransactionsToCSV();
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Manual de Operaciones'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManifestScreen()),
              );
            },
          ),

          const Divider(),
          const SizedBox(height: 32),

          // Danger Zone
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ Zona de Peligro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Esta acción es irreversible y eliminará todos tus datos.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await DataSeeder.seedData(context);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '✅ Datos inyectados. Reinicia la app si es necesario.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.science),
                    label: const Text('Inyectar Datos de Prueba'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showDeleteConfirmationDialog(context);
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Borrar todos los datos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  void _showEditNameDialog(BuildContext context, HabitProvider habitProvider) {
    final TextEditingController controller = TextEditingController(
      text: habitProvider.userStats.userName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✏️ Editar Nombre'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Ingresa tu nombre',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                habitProvider.updateUserName(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Nombre actualizado')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ ¿Estás seguro?'),
        content: const Text(
          'Esta acción eliminará TODOS tus datos, incluyendo hábitos, tareas, finanzas y vehículos. Esta acción NO se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final habitProvider = Provider.of<HabitProvider>(
                context,
                listen: false,
              );

              try {
                // Ejecutar el reset centralizado
                await habitProvider.factoryReset();

                if (context.mounted) {
                  navigator.pop(); // Cerrar diálogo
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        '☢️ SISTEMA FORMATEADO. Reiniciando protocolos...',
                      ),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                print("Error al borrar datos: $e");
                if (context.mounted) {
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
  }
}
