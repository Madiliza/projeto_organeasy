import 'package:flutter/material.dart';
import 'package:organeasy_app/model/members.dart';
import 'package:organeasy_app/model/rooms.dart';
import 'package:organeasy_app/model/tasks.dart';
import 'package:organeasy_app/utils/members_helpers.dart';
import 'package:organeasy_app/utils/rooms_helpers.dart';
import 'package:organeasy_app/utils/tasks.helpers.dart';

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
    await Future.wait([_loadTasks(), _loadMembers(), _loadRooms()]);
  }

  Future<void> _loadTasks() async {
    final data = await dbHelper.getTasks();
    setState(() {
      tasks = data;
    });
  }

  Future<void> _loadMembers() async {
    final data = await membersHelper.getAllMembers();
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

  void _addOrEditTask({Task? task}) async {
    final nameController = TextEditingController(text: task?.name);
    String? selectedStatus = task?.status ?? 'Não realizada';
    String? selectedRoom = task?.room;
    Color? selectedColor = task?.color ?? Colors.grey;

    // ⚠️ Aguarda carregar os cômodos corretamente
    final roomsList = await roomsHelper.getAllRooms();
    final roomsNames = roomsList.map((e) => e.name).toList();

    // ✅ Se o cômodo salvo não estiver na lista, define como null
    if (selectedRoom != null && !roomsNames.contains(selectedRoom)) {
      selectedRoom = null;
    }

    if (mounted) {
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
                        value: roomsNames.contains(selectedRoom)
                            ? selectedRoom
                            : null,
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
                        value:
                            [
                              'Concluída',
                              'Em andamento',
                              'Não realizada',
                            ].contains(selectedStatus)
                            ? selectedStatus
                            : 'Não realizada',
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Concluída',
                            child: Text('Concluída'),
                          ),
                          DropdownMenuItem(
                            value: 'Em andamento',
                            child: Text('Em andamento'),
                          ),
                          DropdownMenuItem(
                            value: 'Não realizada',
                            child: Text('Não realizada'),
                          ),
                        ],
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
                  final status = selectedStatus ?? 'Não realizada';

                  if (name.isEmpty || selectedRoom == null) return;

                  if (task == null) {
                    final newTask = Task(
                      name: name,
                      room: selectedRoom!,
                      member: '',
                      status: status,
                      color: selectedColor,
                    );
                    await dbHelper.insertTask(newTask);
                  } else {
                    final updatedTask = Task(
                      id: task.id,
                      name: name,
                      room: selectedRoom!,
                      member: task.member,
                      status: status,
                      color: selectedColor,
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
  }

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

  String _getStatusText(String status) {
    switch (status) {
      case 'Concluída':
        return 'Concluída';
      case 'Em andamento':
        return 'Em andamento';
      case 'Não realizada':
        return 'Não realizada';
      default:
        return 'Status desconhecido';
    }
  }

  void _assignMemberToTask(Task task) async {
    final membersList = await membersHelper.getAllMembers();
    final membersNames = membersList.map((e) => e.name).toList();
    String? selectedMember = membersNames.contains(task.member)
        ? task.member
        : null;

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
                    orElse: () =>
                        Member(name: '', initial: '', color: Colors.grey),
                  );

                  final updatedTask = Task(
                    id: task.id,
                    name: task.name,
                    room: task.room,
                    member: selectedMember!,
                    status: task.status,
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

  void _deleteTask(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deletar Tarefa'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text('Quer mesmo deletar esta tarefa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await dbHelper.deleteTask(id);
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

  @override
  Widget build(BuildContext context) {
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
                            subtitle: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _getStatusColor(task.status),
                                  radius: 6,
                                ),
                                const SizedBox(width: 8),
                                Text(_getStatusText(task.status)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Cômodo: ${task.room} | Membro: ${task.member.isNotEmpty ? task.member : 'Não atribuído'}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.person_add),
                                  onPressed: () => _assignMemberToTask(task),
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
