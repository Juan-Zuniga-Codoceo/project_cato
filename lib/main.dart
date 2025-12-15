import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Services
import 'src/core/services/storage_service.dart';
import 'src/core/services/notification_service.dart';

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
import 'src/features/social/providers/social_provider.dart';
import 'src/features/academic/providers/academic_provider.dart';
import 'src/features/gamification/providers/achievement_provider.dart';
import 'src/core/theme/app_theme.dart';

// Screens
import 'src/features/home/presentation/screens/home_screen.dart';

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

    final notificationService = NotificationService();
    await notificationService.init();
    print("🔔 Notificaciones OK");

    runApp(
      MyApp(
        storageService: storageService,
        notificationService: notificationService,
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
    return MultiProvider(
      providers: [
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
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
