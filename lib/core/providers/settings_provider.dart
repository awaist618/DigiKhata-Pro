import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final String currency;
  final String dateFormat;
  final bool isDarkMode;
  final String languageCode;

  AppSettings({
    this.currency = 'PKR',
    this.dateFormat = 'dd/MM/yyyy',
    this.isDarkMode = false,
    this.languageCode = 'en',
  });

  AppSettings copyWith({
    String? currency,
    String? dateFormat,
    bool? isDarkMode,
    String? languageCode,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings());

  void setCurrency(String currency) => state = state.copyWith(currency: currency);
  void setDateFormat(String format) => state = state.copyWith(dateFormat: format);
  void toggleDarkMode(bool isDark) => state = state.copyWith(isDarkMode: isDark);
  void setLanguage(String code) => state = state.copyWith(languageCode: code);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
