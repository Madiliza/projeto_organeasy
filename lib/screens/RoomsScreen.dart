import 'package:flutter/material.dart';
import '../model/rooms.dart';
import '../utils/rooms_helpers.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<Room> rooms = [];
  final dbHelper = RoomsHelper();

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final data = await dbHelper.getRooms();
    setState(() {
      rooms = data;
    });
  }

  void _addOrEditRoom({Room? room}) {
    final nameController = TextEditingController(text: room?.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(room == null ? 'Adicionar sala' : 'Editar sala'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome da sala'),
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

                if (name.isEmpty) return;

                if (room == null) {
                  final newRoom = Room(name: name);
                  await dbHelper.insertRoom(newRoom);
                } else {
                  final updatedRoom = Room(id: room.id, name: name);
                  await dbHelper.updateRoom(updatedRoom);
                }

                Navigator.of(context).pop();
                _loadRooms();
              },
              child: Text(room == null ? 'Adicionar' : 'Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteRoom(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deletar sala'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text('Quer mesmo deletar esta sala?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await dbHelper.deleteRoom(id);
                Navigator.of(context).pop();
                _loadRooms();
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
            const Text('Gerenciar Salas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _addOrEditRoom(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar sala'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: rooms.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.home, size: 32, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(room.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () =>
                                  _addOrEditRoom(room: room)),
                          IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              onPressed: () => _deleteRoom(room.id!)),
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
