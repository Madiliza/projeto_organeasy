import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:organeasy_app/model/members.dart';
import 'package:organeasy_app/model/tasks.dart';
import 'package:organeasy_app/utils/members_helpers.dart';
import 'package:organeasy_app/utils/tasks.helpers.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const DashboardScreen({super.key, required this.onTabChange});

  // =================== Funções ===================

  Future<List<Task>> _getTasksThisWeek() async {
    final tasks = await TasksHelper().getAllTasks();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return tasks.where((t) {
      return t.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          t.date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  Future<List<Task>> _getTodayTasks() async {
    final tasks = await TasksHelper().getAllTasks();
    final today = DateTime.now();

    return tasks.where((task) =>
        task.date.year == today.year &&
        task.date.month == today.month &&
        task.date.day == today.day).toList();
  }

  // =================== Build ===================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildSectionHeader('Resumo de Hoje'),
          GestureDetector(
            onTap: () => onTabChange(2), // Vai para a aba de Tarefas
            child: _todayTasksCard(),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _weeklyProgressCard()),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabChange(3), // Vai para a aba de Membros
                  child: _memberActivityCard(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =================== UI ===================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // =================== Card Tarefas de Hoje ===================

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
                    Icon(Icons.check_circle_outline,
                        size: 50, color: Colors.grey),
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
                  subtitle: Text("Responsável: ${task.memberName}"),
                  trailing: Icon(
                    task.status == "Concluído"
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: task.status == "Concluído"
                        ? Colors.green
                        : Colors.grey,
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  // =================== Card Progresso da Semana ===================

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
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                Text(
                  "${(progress * 100).toInt()}% Completo",
                  style: const TextStyle(color: Colors.green),
                ),
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
    return days[date.weekday == 7 ? 0 : date.weekday];
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

  // =================== Card Membros ===================

  Widget _memberActivityCard() {
    return FutureBuilder<List<Member>>(
      future: MembersHelper().getMembers(),
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
                  name: member.name,
                  progress: member.completion,
                  color: member.color,
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  Widget _memberProgress({
    required String name,
    required double progress,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
