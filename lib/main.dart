import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'src/core/providers/finance_provider.dart';
import 'src/features/tasks/providers/task_provider.dart';
import 'src/core/providers/garage_provider.dart';
import 'src/core/providers/habit_provider.dart';
import 'src/core/services/storage_service.dart';
import 'src/core/services/notification_service.dart';
import 'src/features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

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
        ChangeNotifierProvider(create: (_) => FinanceProvider(storageService)),
        ChangeNotifierProvider(create: (_) => TaskProvider(storageService)),
        ChangeNotifierProvider(create: (_) => GarageProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => HabitProvider(storageService, notificationService),
        ),
      ],
      child: MaterialApp(
        title: 'Men\'s Lifestyle App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: HomeScreen(),
      ),
    );
  }
}
