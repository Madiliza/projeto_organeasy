import 'package:organeasy_app/utils/database_helpers.dart';
import 'package:organeasy_app/utils/tasks.helpers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../model/rooms.dart';

class RoomsHelper {
  static const table = 'rooms';

  // 🔸 Inserir Room
  Future<int> insertRoom(Room room) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(
      table,
      room.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 🔸 Buscar todos os Rooms
  Future<List<Room>> getRooms() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table);
    return result.map((e) => Room.fromMap(e)).toList();
  }

  // 🔸 Atualizar Room
  Future<int> updateRoom(Room room) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  // 🔸 Deletar Room por ID
  Future<int> deleteRoom(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 🔸 Buscar todos os Rooms (redundante mas mantém clareza)
  Future<List<Room>> getAllRooms() async {
    return await getRooms();
  }

  Future<void> updateMemberTasksAndCompletion({
  required int memberId,
  required int assignedTasks,
  required double completion,
}) async {
  final db = await DatabaseHelper.instance.database;
  await db.update(
    'members',
    {
      'assigned_tasks': assignedTasks,
      'completion': completion,
    },
    where: 'id = ?',
    whereArgs: [memberId],
  );
}

// 🔥 Atualizar todos os membros
Future<void> updateAllMembersProgress() async {
  final db = await DatabaseHelper.instance.database;
  final result = await db.query('members');
  for (var map in result) {
    final memberId = map['id'] as int;
    await TasksHelper().updateMemberProgress(memberId);
  }
}

}
