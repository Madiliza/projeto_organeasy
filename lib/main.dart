import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/DashboardScreen.dart';
import 'screens/RoomsScreen.dart';
import 'screens/MembersScreen.dart';

void main() {
  
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized(); // Necessário para path_provider
  runApp(const OrganeasyApp());
}



class OrganeasyApp extends StatelessWidget {
  const OrganeasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organeasy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Dashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}



class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardScreen(),
    RoomsScreen(),
    TaskPage(),
    MembersScreen(),
    // A tela de configurações pode ser adicionada aqui
    Center(child: Text('Configurações')), // Placeholder
  ];

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
