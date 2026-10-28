import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../widgets/backup_restore_dialog.dart';
import '../widgets/pin_setup_dialog.dart';

/// Preferences & Customization Screen for Themes, Primary Color, Privacy, Passcode Security, and Backup/Restore.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = AppSettings.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Preferences & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- APPEARANCE SECTION ---
              _buildSectionHeader(context, 'Appearance & Theme', Icons.palette),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.brightness_medium),
                      title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_getThemeName(settings.themeMode)),
                      trailing: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest, size: 16)),
                          ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 16)),
                          ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 16)),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (val) => settings.setThemeMode(val.first),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Accent Color Palette', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            children: settings.availableColors.map((color) {
                              final isSelected = settings.primaryColor.toARGB32() == color.toARGB32();
                              return GestureDetector(
                                onTap: () => settings.setPrimaryColor(color),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: color,
                                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- PRIVACY & PASSCODE SECURITY SECTION ---
              _buildSectionHeader(context, 'Privacy & Security', Icons.security),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: settings.isPrivacyMode,
                      onChanged: (val) => settings.setPrivacyMode(val),
                      title: const Text('Privacy Mode (Mask Balances)', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Masks all monetary figures as \$•••• on screens'),
                      secondary: const Icon(Icons.visibility_off),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: settings.isPinEnabled,
                      onChanged: (enabled) {
                        if (enabled) {
                          showDialog(
                            context: context,
                            builder: (ctx) => const PinSetupDialog(),
                          );
                        } else {
                          settings.disablePin();
                        }
                      },
                      title: const Text('Passcode PIN Lock', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(settings.isPinEnabled ? '4-digit PIN lock enabled' : 'Require PIN to open app'),
                      secondary: const Icon(Icons.lock_outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- BACKUP & DATA MANAGEMENT SECTION ---
              _buildSectionHeader(context, 'Data Backup & Sync', Icons.cloud_sync),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.restore_page),
                  title: const Text('Backup & Restore Data', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Export or import complete JSON database backups'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const BackupRestoreDialog(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // --- LANGUAGE SECTION ---
              _buildSectionHeader(context, 'Language & Regional', Icons.language),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.translate),
                  title: const Text('Display Language', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: DropdownButton<String>(
                    value: settings.language,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English (US)')),
                      DropdownMenuItem(value: 'es', child: Text('Español')),
                      DropdownMenuItem(value: 'fr', child: Text('Français')),
                    ],
                    onChanged: (val) {
                      if (val != null) settings.setLanguage(val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- ABOUT SECTION ---
              _buildSectionHeader(context, 'About Application', Icons.info_outline),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: const ListTile(
                  leading: Icon(Icons.account_balance_wallet),
                  title: Text('Finance Tracker Pro', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Version 1.0.0+1 • Production Build'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Theme';
      case ThemeMode.dark:
        return 'Dark Theme';
    }
  }
}
