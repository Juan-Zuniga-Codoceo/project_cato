import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
// Importamos main.dart para acceder a RestartWidget
import '../../../../../../main.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/habit_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/data_seeder.dart';
import '../../../../core/providers/finance_provider.dart';
import 'manifest_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleRestore(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ ¿Restaurar copia?'),
        content: const Text(
          'Esto sobrescribirá todos los datos actuales. La app se reiniciará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('RESTAURAR'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );

    try {
      await BackupService.restoreBackup(context);
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ DATOS RESTAURADOS.'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) RestartWidget.restartApp(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditNameDialog(BuildContext context, HabitProvider habitProvider) {
    final controller = TextEditingController(
      text: habitProvider.userStats.userName,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✏️ Editar Nombre'),
        content: TextField(controller: controller, autofocus: true),
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
        title: const Text('⚠️ BORRADO TOTAL'),
        content: const Text(
          'Esta acción eliminará TODOS tus datos y es irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<HabitProvider>(
                context,
                listen: false,
              ).factoryReset();
              if (context.mounted) RestartWidget.restartApp(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('BORRAR TODO'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitProvider = Provider.of<HabitProvider>(context);
    final userStats = habitProvider.userStats;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'CONFIGURACIÓN',
          style: GoogleFonts.spaceMono(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. TARJETA DE PERFIL (Header)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
                      : [Colors.white, Colors.grey.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: ClipOval(
                      child: Image.asset(
                        userStats.avatarPath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userStats.userName.toUpperCase(),
                          style: GoogleFonts.spaceMono(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFFFC107).withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            'OPERADOR FUNDADOR',
                            style: GoogleFonts.spaceMono(
                              fontSize: 10,
                              color: const Color(0xFFFFC107), // Always Gold
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () =>
                        _showEditNameDialog(context, habitProvider),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. SECCIÓN SISTEMA
            _SectionHeader(title: 'SISTEMA OPERATIVO'),
            _SettingsGroup(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Modo Oscuro'),
                  value: Provider.of<ThemeProvider>(context).isDarkMode,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (val) => Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleTheme(val),
                ),
                _SettingsTile(
                  icon: Icons.fingerprint,
                  title: 'Seguridad Biométrica',
                  trailing: ValueListenableBuilder(
                    valueListenable: Hive.box(
                      StorageService.settingsBoxName,
                    ).listenable(keys: ['isBiometricEnabled']),
                    builder: (context, box, _) {
                      return Switch(
                        value: box.get(
                          'isBiometricEnabled',
                          defaultValue: false,
                        ),
                        activeThumbColor: Colors.green,
                        onChanged: (val) => box.put('isBiometricEnabled', val),
                      );
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Hora Recordatorio',
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (picked != null) {
                      Hive.box(
                        StorageService.settingsBoxName,
                      ).put('defaultReminderHour', picked.hour);
                      Hive.box(
                        StorageService.settingsBoxName,
                      ).put('defaultReminderMinute', picked.minute);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. SECCIÓN DATOS
            _SectionHeader(title: 'GESTIÓN DE DATOS'),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Crear Respaldo',
                  subtitle: 'Exportar archivo JSON',
                  onTap: () => BackupService.createBackup(context),
                ),
                _SettingsTile(
                  icon: Icons.cloud_download_outlined,
                  title: 'Restaurar Datos',
                  subtitle: 'Importar archivo JSON',
                  onTap: () => _handleRestore(context),
                ),
                _SettingsTile(
                  icon: Icons.table_chart_outlined,
                  title: 'Exportar Finanzas',
                  subtitle: 'Generar CSV para Excel',
                  onTap: () => Provider.of<FinanceProvider>(
                    context,
                    listen: false,
                  ).exportTransactionsToCSV(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4. SECCIÓN INFORMACIÓN
            _SectionHeader(title: 'INFORMACIÓN'),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.school_outlined,
                  title: 'Escala de Notas',
                  onTap: () {
                    // Lógica simple para cambiar escala (puedes expandirla)
                    final box = Hive.box(StorageService.settingsBoxName);
                    int current = box.get('gradingScale', defaultValue: 0);
                    box.put('gradingScale', (current + 1) % 3);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Escala cambiada (Reinicia para aplicar en todas partes)',
                        ),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Manual de Operaciones',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManifestScreen()),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'Acerca de CATO',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 5. ZONA DE PELIGRO
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.red.withOpacity(0.05),
              ),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'ZONA DE PELIGRO',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text('Borrar todos los datos o inyectar demo'),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.science,
                            color: Colors.blue,
                          ),
                          title: const Text('Inyectar Datos Demo'),
                          onTap: () {
                            Navigator.pop(ctx);
                            DataSeeder.seedData(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          title: const Text('Formatear Sistema (Borrar Todo)'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showDeleteConfirmationDialog(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "CATO OS v1.0.0",
              style: GoogleFonts.spaceMono(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES PARA EL DISEÑO ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.spaceMono(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: theme.iconTheme.color?.withOpacity(0.8),
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color,
              ),
            )
          : null,
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
