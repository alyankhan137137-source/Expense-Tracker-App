import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// App settings state manager and ValueNotifier for instant theme, privacy & PIN security updates.
class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._init();

  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.indigo;
  bool _isPrivacyMode = false;
  String _language = 'en';

  bool _isPinEnabled = false;
  String _pinCode = '';
  bool _isAppLocked = false;

  AppSettings._init();

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get isPrivacyMode => _isPrivacyMode;
  String get language => _language;

  bool get isPinEnabled => _isPinEnabled;
  String get pinCode => _pinCode;
  bool get isAppLocked => _isAppLocked;

  final List<Color> availableColors = const [
    Colors.indigo,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.purple,
    Colors.blue,
  ];

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void togglePrivacyMode() {
    _isPrivacyMode = !_isPrivacyMode;
    notifyListeners();
  }

  void setPrivacyMode(bool value) {
    _isPrivacyMode = value;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void enablePin(String pin) {
    _pinCode = pin;
    _isPinEnabled = true;
    _isAppLocked = true;
    notifyListeners();
  }

  void disablePin() {
    _isPinEnabled = false;
    _pinCode = '';
    _isAppLocked = false;
    notifyListeners();
  }

  void lockApp() {
    if (_isPinEnabled) {
      _isAppLocked = true;
      notifyListeners();
    }
  }

  bool unlockApp(String enteredPin) {
    if (enteredPin == _pinCode) {
      _isAppLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Formats currency amounts with privacy masking if Privacy Mode is enabled.
  String formatAmount(double amount, {String currencySymbol = '\$'}) {
    if (_isPrivacyMode) {
      return '$currencySymbol••••';
    }
    final formatter = NumberFormat.currency(symbol: currencySymbol, decimalDigits: 2);
    return formatter.format(amount);
  }
}
