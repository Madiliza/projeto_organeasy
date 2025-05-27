import 'package:organeasy_app/utils/database_helpers.dart';
import '../model/tasks.dart';

class TasksHelper {
  static const table = 'tasks';

  Future<int> insertTask(Task task) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(table, task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table);
    return result.map((e) => Task.fromMap(e)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
