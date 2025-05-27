import 'package:organeasy_app/utils/database_helpers.dart';
import '../model/rooms.dart';


class RoomsHelper {
  static const table = 'rooms';

  Future<int> insertRoom(Room room) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(table, room.toMap());
  }

  Future<List<Room>> getRooms() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table);
    return result.map((e) => Room.fromMap(e)).toList();
  }

  Future<int> updateRoom(Room room) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  Future<int> deleteRoom(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

//criar classe para buscar todos os rooms e retornar uma lista de rooms
  Future<List<Room>> getAllRooms() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table);
    return result.map((e) => Room.fromMap(e)).toList();
  }

}
