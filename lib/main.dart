import 'package:flutter/material.dart';
import 'package:organeasy_app/screens/DashboardScreen.dart';
import 'package:organeasy_app/screens/TasksScreen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/DashboardScreen.dart';
import 'screens/RoomsScreen.dart';
import 'screens/MembersScreen.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OrganeasyApp());
}

class OrganeasyApp extends StatefulWidget {
  const OrganeasyApp({super.key});

  @override
  State<OrganeasyApp> createState() => _OrganeasyAppState();
}

class _OrganeasyAppState extends State<OrganeasyApp> {
  bool isDarkMode = false;

  void toggleTheme(bool isDark) {
    setState(() {
      isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organeasy',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Dashboard(
        isDarkMode: isDarkMode,
        onThemeChanged: toggleTheme,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Dashboard extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const Dashboard({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Dashboard',
    'Salas',
    'Tarefas',
    'Membros',
    'Configurações',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
        const DashboardScreen(),
        const RoomsScreen(),
        const TasksScreen(),
        const MembersScreen(),
        SettingsScreen(
          isDarkMode: widget.isDarkMode,
          onThemeChanged: widget.onThemeChanged,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organeasy - ${_titles[_selectedIndex]}'),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Salas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Membros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}

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
          title: const Text('Modo escuro'),
          subtitle: const Text('Ativar ou desativar o modo escuro'),
          secondary: Icon(
            Icons.dark_mode,
            color: isDarkMode ? Colors.amber : null,
          ),
          value: isDarkMode,
          onChanged: onThemeChanged,
        ),
      ),
    );
  }
}

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Página de Tarefas',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
