import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'services/app_settings.dart';
import 'services/recurring_scheduler.dart';

/// Application entry point initializes Flutter bindings, checks recurring bills, and runs root app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Evaluate due recurring payments on startup
  await RecurringScheduler.checkAndScheduleRecurringExpenses();

  runApp(const ExpenseTrackerApp());
}

/// Root Application Widget configured with Material 3 dynamic themes & Passcode Security PIN Guard.
class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Finance Tracker Pro',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,

          // Dynamic Light Theme
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: settings.primaryColor,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Dynamic Dark Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: settings.primaryColor,
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          home: const PinLockScreen(
            child: MainNavigationScreen(),
          ),
        );
      },
    );
  }
}
