import 'package:flutter/material.dart';
import '../services/app_settings.dart';

/// Passcode Lock Screen requiring 4-digit PIN entry to unlock the application.
class PinLockScreen extends StatefulWidget {
  final Widget child;

  const PinLockScreen({super.key, required this.child});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _enteredPin = '';
  String _errorMessage = '';

  void _onKeyPress(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = '';
      });

      if (_enteredPin.length == 4) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  void _submitPin() {
    final success = AppSettings.instance.unlockApp(_enteredPin);
    if (!success) {
      setState(() {
        _errorMessage = 'Incorrect PIN code. Please try again.';
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        if (!settings.isPinEnabled || !settings.isAppLocked) {
          return widget.child;
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const Spacer(),
                // Lock Icon & Title
                Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Finance Tracker Pro Locked',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter 4-digit passcode PIN to unlock',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 32),

                // PIN Dots Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _enteredPin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: isFilled ? theme.colorScheme.primary : theme.colorScheme.outline,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),

                // Error Message
                SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const Spacer(),

                // Numpad Keypad
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Column(
                    children: [
                      _buildNumpadRow(['1', '2', '3']),
                      const SizedBox(height: 16),
                      _buildNumpadRow(['4', '5', '6']),
                      const SizedBox(height: 16),
                      _buildNumpadRow(['7', '8', '9']),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 72, height: 72), // Spacer
                          _buildNumpadButton('0'),
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: IconButton(
                              icon: const Icon(Icons.backspace_outlined, size: 28),
                              onPressed: _onBackspace,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumpadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) => _buildNumpadButton(digit)).toList(),
    );
  }

  Widget _buildNumpadButton(String digit) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 72,
      height: 72,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        onPressed: () => _onKeyPress(digit),
        child: Text(
          digit,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
