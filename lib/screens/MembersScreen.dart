import 'package:flutter/material.dart';
import '../utils/members_helpers.dart';
import '../model/members.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<Member> members = [];
  final dbHelper = MembersHelper();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final data = await dbHelper.getMembers();
    setState(() {
      members = data;
    });
  }


  void _addOrEditMember({Member? member}) {
    final nameController = TextEditingController(text: member?.name);
    final initialController = TextEditingController(text: member?.initial);
    Color selectedColor = member?.color ?? Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(member == null ? 'Adicionar membro' : 'Editar membro'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: initialController,
                  decoration: const InputDecoration(labelText: 'Inicial'),
                  maxLength: 1,
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selecione uma cor:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.teal,
                    Colors.pink,
                    Colors.brown,
                    Colors.cyan,
                    Colors.amber,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        selectedColor = color;
                        (context as Element).markNeedsBuild();
                      },
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 18,
                        child: selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final initial = initialController.text.trim();

                if (name.isEmpty || initial.isEmpty) return;

                if (member == null) {
                  final newMember = Member(
                    name: name,
                    initial: initial,
                    color: selectedColor,
                  );
                  await dbHelper.insertMember(newMember);
                } else {
                  final updatedMember = Member(
                    id: member.id,
                    name: name,
                    initial: initial,
                    color: selectedColor,
                    assignedTasks: member.assignedTasks,
                    completion: member.completion,
                  );
                  await dbHelper.updateMember(updatedMember);
                }

                Navigator.of(context).pop();
                _loadMembers();
              },
              child: Text(member == null ? 'Adicionar' : 'Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMember(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deletar membro'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text('Quer mesmo deletar este membro?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await dbHelper.deleteMember(id);
                Navigator.of(context).pop();
                _loadMembers();
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
              'Gerenciar Membros',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _addOrEditMember(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar membro'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: members.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final member = members[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: member.color,
                                child: Text(
                                  member.initial,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    '${member.assignedTasks} tarefas atribuídas',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () =>
                                      _addOrEditMember(member: member)),
                              IconButton(
                                  icon: const Icon(Icons.delete, size: 18),
                                  onPressed: () => _deleteMember(member.id!)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Tarefas concluídas',
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: member.completion,
                            backgroundColor: Colors.grey[300],
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(member.completion * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
