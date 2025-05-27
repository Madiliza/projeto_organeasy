import 'package:flutter/material.dart';
import 'RoomsScreen.dart';
import 'package:organeasy_app/screens/TasksScreen.dart';
import 'MembersScreen.dart';  
import 'package:flutter/material.dart';
import 'package:organeasy_app/screens/RoomsScreen.dart'; // Importando o arquivo com os dados das salas


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}



// Dashboard screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildCard(
            title: "tarefas do dia", 
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text("Não há tarefas para hoje",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _weeklyProgressCard()),
              const SizedBox(width: 16),
              Expanded(child: _memberActivityCard()),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _weeklyProgressCard() {
    return _buildCard(
      title: "Progresso da semana",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: 0, minHeight: 8),
          const SizedBox(height: 8),
          const Text("0% Completo", style: TextStyle(color: Colors.blue)),
          const SizedBox(height: 16),
          _dayTask("Tuesday", 0),
          _dayTask("Wednesday", 0),
          _dayTask("Thursday", 0),
        ],
      ),
    );
  }

  Widget _dayTask(String day, int tasks) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today, color: Colors.blue),
      title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("$tasks tarefas",
          style: const TextStyle(color: Colors.grey)),  
    );
  }

  Widget _memberActivityCard() {
    return _buildCard(
      title: "Membros ativos",
      child: Column(
        children: [
          _memberProgress("Liza", 0, Colors.purple),
          _memberProgress("Bruno", 0, Colors.green),
          _memberProgress("Mary", 0, Colors.teal),
        ],
      ),
    );
  }

  Widget _memberProgress(String name, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Text(name[0], style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(value: progress, minHeight: 8),
          ),
          const SizedBox(width: 8),
          Text("${(progress * 100).toInt()}%"),
        ],
      ),
    );
  }
}


class RoomPage extends StatelessWidget {
  const RoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoomsScreen();
  }
}


class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TasksScreen(); // Certifique-se de que a classe Tasks está definida em tasks.dart
  }
}


@override
Widget build(BuildContext context) {
  return MembersScreen();
}

//@override
//Widget build(BuildContext context) {
 // return settings();
//}
