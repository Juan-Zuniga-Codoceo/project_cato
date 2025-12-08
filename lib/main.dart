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

// Screens
import 'src/features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es');
  Intl.defaultLocale = 'es';

  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MyApp(
      storageService: storageService,
      notificationService: notificationService,
    ),
  );
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
        ChangeNotifierProvider(create: (_) => GarageProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => HabitProvider(storageService, notificationService),
        ),
        ChangeNotifierProvider(create: (_) => TaskProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => LifestyleProvider(storageService),
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
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueGrey,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                backgroundColor: Color(0xFF1F1F1F),
                foregroundColor: Colors.white,
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
