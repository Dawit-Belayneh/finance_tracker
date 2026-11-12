import 'package:flutter/material.dart';

/// Supported display currencies.
enum AppCurrency {
  etb(code: 'ETB', name: 'Ethiopian Birr', symbol: 'Br'),
  usd(code: 'USD', name: 'US Dollar', symbol: '\$'),
  eur(code: 'EUR', name: 'Euro', symbol: '€'),
  gbp(code: 'GBP', name: 'British Pound', symbol: '£'),
  jpy(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  cad(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$');

  const AppCurrency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  final String code;
  final String name;
  final String symbol;

  String get displayLabel => '$name ($symbol)';
}

/// User profile, appearance, and preference settings for the app.
class AppSettings {
  const AppSettings({
    this.profileName = 'Alex Morgan',
    this.profileEmail = 'alex@example.com',
    this.currency = AppCurrency.usd,
    this.themeMode = ThemeMode.system,
    this.showDecimals = true,
    this.budgetAlerts = true,
    this.dailyReminders = false,
  });

  final String profileName;
  final String profileEmail;
  final AppCurrency currency;
  final ThemeMode themeMode;
  final bool showDecimals;
  final bool budgetAlerts;
  final bool dailyReminders;

  AppSettings copyWith({
    String? profileName,
    String? profileEmail,
    AppCurrency? currency,
    ThemeMode? themeMode,
    bool? showDecimals,
    bool? budgetAlerts,
    bool? dailyReminders,
  }) {
    return AppSettings(
      profileName: profileName ?? this.profileName,
      profileEmail: profileEmail ?? this.profileEmail,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      showDecimals: showDecimals ?? this.showDecimals,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      dailyReminders: dailyReminders ?? this.dailyReminders,
    );
  }
}
