import 'package:sqflite/sqflite.dart';
import 'package:organeasy_app/utils/database_helpers.dart';
import '../model/tasks.dart';

class TasksHelper {
  static const String table = 'tasks';

  // 🔸 Inserir tarefa
  Future<int> insertTask(Task task) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(
      table,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 🔸 Buscar todas as tarefas ordenadas por data
  Future<List<Task>> getTasks() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      table,
      orderBy: 'date DESC',
    );

    return result.map((map) => Task.fromMap(map)).toList();
  }

  // 🔸 Atualizar tarefa
  Future<int> updateTask(Task task) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // 🔸 Deletar tarefa por ID
  Future<int> deleteTask(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 🔸 Buscar todas as tarefas (sem ordenação)
  Future<List<Task>> getAllTasks() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table);
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // 🔸 Deletar todas as tarefas
  Future<int> deleteAllTasks() async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(table);
  }

  // 🔸 Contagem total de tarefas
  Future<int> getTasksCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
