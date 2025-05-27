import 'package:flutter/material.dart';
import 'package:organeasy_app/model/members.dart';
import 'package:organeasy_app/model/tasks.dart';
import 'package:organeasy_app/utils/members_helpers.dart';
import 'package:organeasy_app/utils/tasks.helpers.dart';
import 'RoomsScreen.dart';
import 'TasksScreen.dart';
import 'MembersScreen.dart';

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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ---------- FILTRAR TAREFAS DA SEMANA ----------
  Future<List<Task>> _getTasksThisWeek() async {
    final tasks = await TasksHelper().getAllTasks();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Segunda
    final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Domingo

    return tasks.where((t) {
      return t.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          t.date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  // ---------- FILTRAR TAREFAS DE HOJE ----------
  Future<List<Task>> _getTodayTasks() async {
    final tasks = await TasksHelper().getAllTasks();
    final today = DateTime.now();

    return tasks.where((task) =>
        task.date.year == today.year &&
        task.date.month == today.month &&
        task.date.day == today.day).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const TasksScreen()));
            },
            child: _todayTasksCard(),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _weeklyProgressCard()),
              const SizedBox(width: 16),
              Expanded(child: _memberActivityCard(context)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Cards ----------

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // ---------- Tarefas de Hoje ----------
  Widget _todayTasksCard() {
    return FutureBuilder<List<Task>>(
      future: _getTodayTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard(
            title: "Tarefas do dia",
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return _buildCard(
            title: "Tarefas do dia",
            child: const Center(child: Text('Erro ao carregar tarefas')),
          );
        } else {
          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return _buildCard(
              title: "Tarefas do dia",
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Não há tarefas para hoje",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildCard(
            title: "Tarefas do dia",
            child: Column(
              children: tasks.map((task) {
                return ListTile(
                  leading: Icon(Icons.task, color: task.color),
                  title: Text(task.name),
                  subtitle: Text("Responsável: ${task.member}"),
                  trailing: Icon(
                    task.status == "Concluído"
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: task.status == "Concluído" ? Colors.green : Colors.grey,
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  // ---------- Progresso Semanal ----------
  Widget _weeklyProgressCard() {
    return FutureBuilder<List<Task>>(
      future: _getTasksThisWeek(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard(
            title: "Progresso da semana",
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return _buildCard(
            title: "Progresso da semana",
            child: const Center(child: Text('Erro ao carregar tarefas')),
          );
        } else {
          final tasks = snapshot.data!;
          final total = tasks.length;
          final completed = tasks.where((t) => t.status == "Concluído").length;
          final progress = total == 0 ? 0.0 : completed / total;

          return _buildCard(
            title: "Progresso da semana",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(value: progress, minHeight: 8),
                const SizedBox(height: 8),
                Text("${(progress * 100).toInt()}% Completo",
                    style: const TextStyle(color: Colors.blue)),
                const SizedBox(height: 16),
                ..._groupTasksByDay(tasks),
              ],
            ),
          );
        }
      },
    );
  }

  List<Widget> _groupTasksByDay(List<Task> tasks) {
    final Map<String, int> tasksPerDay = {};

    for (var task in tasks) {
      final day = _formatDay(task.date);
      tasksPerDay.update(day, (value) => value + 1, ifAbsent: () => 1);
    }

    return tasksPerDay.entries.map((entry) {
      return _dayTask(entry.key, entry.value);
    }).toList();
  }

  String _formatDay(DateTime date) {
    final days = [
      "Domingo",
      "Segunda-feira",
      "Terça-feira",
      "Quarta-feira",
      "Quinta-feira",
      "Sexta-feira",
      "Sábado"
    ];
    return days[date.weekday % 7];
  }

  Widget _dayTask(String day, int tasks) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today, color: Colors.blue),
      title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        "$tasks tarefas",
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  // ---------- Membros ----------
  Widget _memberActivityCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MembersScreen()));
      },
      child: FutureBuilder<List<Member>>(
        future: MembersHelper().getAllMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildCard(
              title: "Membros ativos",
              child: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return _buildCard(
              title: "Membros ativos",
              child: const Center(child: Text('Erro ao carregar membros')),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildCard(
              title: "Membros ativos",
              child: const Center(child: Text('Nenhum membro encontrado')),
            );
          } else {
            final members = snapshot.data!;
            return _buildCard(
              title: "Membros ativos",
              child: Column(
                children: members.map((member) {
                  return _memberProgress(
                    member.name,
                    member.completion,
                    member.color,
                  );
                }).toList(),
              ),
            );
          }
        },
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
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: color,
              backgroundColor: color.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 8),
          Text("${(progress * 100).toInt()}%"),
        ],
      ),
    );
  }
}
