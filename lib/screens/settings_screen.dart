import 'package:flutter/material.dart';
import '../data/app_settings.dart';

/// Displays and updates user Profile, Currency, Theme, and Preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _settings = widget.settings;
    }
  }

  void _applySettings(AppSettings updated) {
    setState(() => _settings = updated);
    widget.onSettingsChanged(updated);
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _editProfile() async {
    final result = await showDialog<_ProfileResult>(
      context: context,
      builder: (_) => _EditProfileDialog(
        initialName: _settings.profileName,
        initialEmail: _settings.profileEmail,
      ),
    );
    if (result == null) return;

    _applySettings(
      _settings.copyWith(
        profileName: result.name,
        profileEmail: result.email,
      ),
    );
  }

  Future<void> _pickCurrency() async {
    final selected = await showDialog<AppCurrency>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Select Currency'),
          children: AppCurrency.values.map((currency) {
            final isSelected = currency == _settings.currency;
            return ListTile(
              leading: CircleAvatar(
                radius: 16,
                child: Text(
                  currency.symbol,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(currency.name),
              subtitle: Text(currency.code),
              trailing: isSelected
                  ? Icon(
                      Icons.check,
                      color: Theme.of(dialogContext).colorScheme.primary,
                    )
                  : null,
              onTap: () => Navigator.of(dialogContext).pop(currency),
            );
          }).toList(),
        );
      },
    );

    if (selected != null && selected != _settings.currency) {
      _applySettings(_settings.copyWith(currency: selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader('Profile'),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  _initials(_settings.profileName),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                _settings.profileName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(_settings.profileEmail),
              trailing: IconButton(
                key: const Key('edit_profile_button'),
                tooltip: 'Edit profile',
                onPressed: _editProfile,
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionHeader('Currency'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              key: const Key('currency_setting_tile'),
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Default Currency'),
              subtitle: Text(
                '${_settings.currency.code} • ${_settings.currency.displayLabel}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickCurrency,
            ),
          ),
          const SizedBox(height: 20),
          const _SectionHeader('Theme'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    key: const Key('theme_mode_selector'),
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {_settings.themeMode},
                    onSelectionChanged: (selection) {
                      _applySettings(
                        _settings.copyWith(themeMode: selection.first),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionHeader('Preferences'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  key: const Key('show_decimals_switch'),
                  secondary: const Icon(Icons.pin_outlined),
                  title: const Text('Show decimals'),
                  subtitle: const Text('Display cents in currency amounts'),
                  value: _settings.showDecimals,
                  onChanged: (value) {
                    _applySettings(_settings.copyWith(showDecimals: value));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  key: const Key('budget_alerts_switch'),
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Budget alerts'),
                  subtitle: const Text(
                    'Highlight approaching or exceeded budgets',
                  ),
                  value: _settings.budgetAlerts,
                  onChanged: (value) {
                    _applySettings(_settings.copyWith(budgetAlerts: value));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  key: const Key('daily_reminders_switch'),
                  secondary: const Icon(Icons.alarm_outlined),
                  title: const Text('Daily reminders'),
                  subtitle: const Text('Remind me to log daily expenses'),
                  value: _settings.dailyReminders,
                  onChanged: (value) {
                    _applySettings(_settings.copyWith(dailyReminders: value));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ProfileResult {
  const _ProfileResult({required this.name, required this.email});

  final String name;
  final String email;
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({
    required this.initialName,
    required this.initialEmail,
  });

  final String initialName;
  final String initialEmail;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('profile_name_field'),
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('profile_email_field'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty || !text.contains('@')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save_profile_button'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(
                _ProfileResult(
                  name: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
