import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Center(
        child: SwitchListTile(
          title: const Text('Modo de tela'),
          subtitle: const Text('Ativar ou desativar o modo escuro'),
          secondary: Icon(
            Icons.dark_mode,
            color: isDarkMode ? Colors.amber : null,
          ),
          value: isDarkMode, // Sempre lê diretamente do pai
          onChanged: onThemeChanged, // Atualiza diretamente no pai
        ),
      ),
    );
  }
}
