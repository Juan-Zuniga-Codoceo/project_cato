import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Services
import 'src/core/services/storage_service.dart';
import 'src/core/services/notification_service.dart';
import 'src/core/utils/avatar_migration.dart';

// Providers
import 'src/core/providers/theme_provider.dart';
import 'src/core/providers/finance_provider.dart';
import 'src/core/providers/garage_provider.dart';
import 'src/core/providers/habit_provider.dart';
import 'src/features/tasks/providers/task_provider.dart';

import 'src/features/lifestyle/providers/lifestyle_provider.dart';
import 'src/features/responsibility/providers/responsibility_provider.dart';
import 'src/features/social/providers/social_provider.dart';
import 'src/features/academic/providers/academic_provider.dart';
import 'src/features/gamification/providers/achievement_provider.dart';
import 'src/features/gamification/providers/reward_provider.dart'; // [NUEVO IMPORT]
import 'src/core/providers/subscription_provider.dart';
import 'src/core/theme/app_theme.dart';

// Screens
// Screens
import 'src/features/home/presentation/screens/home_screen.dart';
import 'src/features/auth/presentation/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("🚀 INICIANDO SISTEMA CATO...");
    await initializeDateFormatting('es');
    Intl.defaultLocale = 'es';

    final storageService = StorageService();
    print("📦 Inicializando Storage...");
    await storageService.init();
    print("✅ Storage OK");

    // [MIGRATION] Actualizar avatares de .jpg a .png (ONE-TIME)
    await AvatarMigration.migrateAvatarPaths();

    final notificationService = NotificationService();
    await notificationService.init();
    print("🔔 Notificaciones OK");

    runApp(
      // Envolvemos la app en RestartWidget para permitir reinicio en caliente
      RestartWidget(
        child: MyApp(
          storageService: storageService,
          notificationService: notificationService,
        ),
      ),
    );
  } catch (e, stack) {
    print("🔥 ERROR CRÍTICO AL INICIAR: $e");
    print(stack);
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "ERROR DE INICIO:\n$e\n\nIntenta reinstalar la app.",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget utilitario para reiniciar la aplicación completamente.
class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.storageService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    // Verificar configuración de seguridad
    final bool isBiometricEnabled = storageService.settingsBox.get(
      'isBiometricEnabled',
      defaultValue: false,
    );

    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
        ChangeNotifierProvider(create: (_) => FinanceProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => GarageProvider(storageService, notificationService),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitProvider(storageService, notificationService),
        ),
        ChangeNotifierProvider(create: (_) => TaskProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => LifestyleProvider(storageService, notificationService),
        ),
        ChangeNotifierProvider(
          create: (_) => ResponsibilityProvider(storageService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => SocialProvider(storageService, notificationService),
        ),
        ChangeNotifierProvider(create: (_) => AcademicProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) =>
              AchievementProvider(storageService, notificationService),
        ),
        // [NUEVO PROVIDER]
        ChangeNotifierProvider(create: (_) => RewardProvider(storageService)),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'CATO: Life OS',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            // Lógica de Inicio:
            home: isBiometricEnabled ? const AuthScreen() : const HomeScreen(),
          );
        },
      ),
    );
  }
}
