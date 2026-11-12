import 'package:flutter/material.dart';
import 'data/app_settings.dart';
import 'screens/home_shell.dart';
import 'utils/formatters.dart';

void main() {
  runApp(const FinanceTrackerApp());
}

class FinanceTrackerApp extends StatefulWidget {
  const FinanceTrackerApp({super.key});

  @override
  State<FinanceTrackerApp> createState() => _FinanceTrackerAppState();
}

class _FinanceTrackerAppState extends State<FinanceTrackerApp> {
  AppSettings _settings = const AppSettings();

  @override
  void initState() {
    super.initState();
    _syncFormatterSettings(_settings);
  }

  void _syncFormatterSettings(AppSettings settings) {
    activeCurrencySymbol = settings.currency.symbol;
    activeShowDecimals = settings.showDecimals;
  }

  void _handleSettingsChanged(AppSettings updated) {
    setState(() {
      _settings = updated;
      _syncFormatterSettings(updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: _settings.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeShell(
        settings: _settings,
        onSettingsChanged: _handleSettingsChanged,
      ),
    );
  }
}
