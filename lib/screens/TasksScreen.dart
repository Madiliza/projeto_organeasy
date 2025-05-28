import 'package:flutter/material.dart';
import 'package:organeasy_app/model/members.dart';
import 'package:organeasy_app/model/rooms.dart';
import 'package:organeasy_app/model/tasks.dart';
import 'package:organeasy_app/utils/members_helpers.dart';
import 'package:organeasy_app/utils/rooms_helpers.dart';
import 'package:organeasy_app/utils/tasks.helpers.dart';// Corrigido nome do helper

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = [];
  List<Member> members = [];
  List<Room> rooms = [];

  final dbHelper = TasksHelper();
  final membersHelper = MembersHelper();
  final roomsHelper = RoomsHelper();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadTasks(),
      _loadMembers(),
      _loadRooms(),
    ]);
  }

  Future<void> _loadTasks() async {
    final data = await dbHelper.getTasks();
    setState(() {
      tasks = data;
    });
  }

  Future<void> _loadMembers() async {
    final data = await membersHelper.getMembers();
    setState(() {
      members = data;
    });
  }

  Future<void> _loadRooms() async {
    final data = await roomsHelper.getAllRooms();
    setState(() {
      rooms = data;
    });
  }

  /// Alterar status da tarefa
  void _changeTaskStatus(Task task) {
    final statuses = ['Não realizada', 'Em andamento', 'Concluída'];
    String? selectedStatus = task.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar Status'),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: const InputDecoration(labelText: 'Selecione o status'),
            items: statuses
                .map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status)),
                )
                .toList(),
            onChanged: (value) {
              selectedStatus = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedStatus != null) {
                  final updatedTask = task.copyWith(status: selectedStatus, member: '');
                  await dbHelper.updateTask(updatedTask);
                  Navigator.of(context).pop();
                  _loadTasks();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  /// Adicionar ou editar tarefa
  void _addOrEditTask({Task? task}) async {
    final nameController = TextEditingController(text: task?.name);
    String? selectedStatus = task?.status ?? 'Não realizada';
    String? selectedRoom = task?.room;
    Color selectedColor = task?.color ?? Colors.grey;

    final roomsList = await roomsHelper.getAllRooms();
    final roomsNames = roomsList.map((e) => e.name).toList();

    if (selectedRoom != null && !roomsNames.contains(selectedRoom)) {
      selectedRoom = null;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? 'Adicionar Tarefa' : 'Editar Tarefa'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRoom,
                      decoration: const InputDecoration(labelText: 'Cômodo'),
                      items: roomsNames
                          .map(
                            (room) => DropdownMenuItem(
                              value: room,
                              child: Text(room),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRoom = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: ['Concluída', 'Em andamento', 'Não realizada']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty || selectedRoom == null) return;

                if (task == null) {
                  final newTask = Task(
                    name: name,
                    room: selectedRoom!,
                    member: '',
                    memberId: 0,
                    memberName: '',
                    status: selectedStatus!,
                    color: selectedColor,
                    date: DateTime.now(),
                  );
                  await dbHelper.insertTask(newTask);
                } else {
                  final updatedTask = task.copyWith(
                    name: name,
                    room: selectedRoom,
                    status: selectedStatus!, member: '',
                  );
                  await dbHelper.updateTask(updatedTask);
                }

                Navigator.of(context).pop();
                _loadTasks();
              },
              child: Text(task == null ? 'Adicionar' : 'Salvar'),
            ),
          ],
        );
      },
    );
  }

  /// Atribuir membro à tarefa
  void _assignMemberToTask(Task task) async {
    final membersList = await membersHelper.getMembers();
    final membersNames = membersList.map((e) => e.name).toList();
    String? selectedMember = task.memberName.isNotEmpty ? task.memberName : null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atribuir Membro'),
          content: DropdownButtonFormField<String>(
            value: selectedMember,
            decoration: const InputDecoration(labelText: 'Selecione um membro'),
            items: membersNames
                .map(
                  (member) =>
                      DropdownMenuItem(value: member, child: Text(member)),
                )
                .toList(),
            onChanged: (value) {
              selectedMember = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedMember != null) {
                  final member = membersList.firstWhere(
                    (m) => m.name == selectedMember,
                  );

                  final updatedTask = task.copyWith(
                    member: selectedMember!,
                    memberId: member.id,
                    memberName: member.name,
                    color: member.color,
                  );

                  await dbHelper.updateTask(updatedTask);
                  Navigator.of(context).pop();
                  _loadTasks();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  /// Deletar tarefa
  void _deleteTask(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deletar Tarefa'),
          content: const Text('Quer mesmo deletar esta tarefa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Find the task by id to get the name or other required value
                final task = tasks.firstWhere((t) => t.id == id);
                await dbHelper.deleteTask(id, task.memberId);
                // Atualizar o progresso do membro após deletar a tarefa  
                Navigator.of(context).pop();
                _loadTasks();
              },
              child: const Text('Deletar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Progresso
  double _getMemberCompletedPercentage(String memberName) {
    final memberTasks =
        tasks.where((task) => task.memberName == memberName).toList();
    if (memberTasks.isEmpty) return 0;
    final completedTasks =
        memberTasks.where((task) => task.status == 'Concluída').length;
    return completedTasks / memberTasks.length;
  }

  double _getOverallCompletedPercentage() {
    if (tasks.isEmpty) return 0;
    final completed = tasks.where((t) => t.status == 'Concluída').length;
    return completed / tasks.length;
  }

  /// Cores do status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Concluída':
        return Colors.green;
      case 'Em andamento':
        return Colors.yellow;
      case 'Não realizada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Texto do status
  String _getStatusText(String status) {
    switch (status) {
      case 'Concluída':
      case 'Em andamento':
      case 'Não realizada':
        return status;
      default:
        return 'Status desconhecido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final overallProgress = _getOverallCompletedPercentage();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gerenciar Tarefas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _addOrEditTask(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar tarefa'),
              ),
            ),
            const SizedBox(height: 16),

            // Progresso geral
            const Text(
              'Progresso Geral:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: overallProgress,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            Text(
              '${(overallProgress * 100).toStringAsFixed(0)}% concluídas no total',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),

            const SizedBox(height: 24),

            // Progresso dos membros
            const Text(
              'Progresso dos membros:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ...members.map((member) {
              final progress = _getMemberCompletedPercentage(member.name);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% concluídas',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),

            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('Nenhuma tarefa cadastrada.'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: task.color,
                              child: const Icon(
                                Icons.task,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(task.name),
                            subtitle: GestureDetector(
                              onTap: () => _changeTaskStatus(task),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        _getStatusColor(task.status),
                                    radius: 6,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getStatusText(task.status),
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Cômodo: ${task.room} | Membro: ${task.memberName.isNotEmpty ? task.memberName : 'Não atribuído'}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.person_add),
                                  onPressed: () =>
                                      _assignMemberToTask(task),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _addOrEditTask(task: task),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteTask(task.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
