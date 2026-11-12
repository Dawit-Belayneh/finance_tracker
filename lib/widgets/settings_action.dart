import 'package:flutter/material.dart';

/// Builds an optional Settings action button list for top-level [AppBar]s.
List<Widget>? buildSettingsActions(VoidCallback? onOpenSettings) {
  if (onOpenSettings == null) return null;
  return [
    IconButton(
      tooltip: 'Settings',
      onPressed: onOpenSettings,
      icon: const Icon(Icons.settings_outlined),
    ),
  ];
}
