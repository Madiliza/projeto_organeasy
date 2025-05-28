import 'package:sqflite/sqflite.dart';
import 'package:organeasy_app/utils/database_helpers.dart';
import '../model/tasks.dart';
import 'members_helpers.dart';

class TasksHelper {
  static const String table = 'tasks';
  final MembersHelper membersHelper = MembersHelper();

  // 🔸 Inserir tarefa
  Future<int> insertTask(Task task) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert(
      table,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Atualizar progresso do membro após inserir
    await updateMemberProgress(task.memberId);

    return id;
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
    final result = await db.update(
      table,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );

    // Atualizar progresso do membro após atualizar
    await updateMemberProgress(task.memberId);

    return result;
  }

  // 🔸 Deletar tarefa por ID
  Future<int> deleteTask(int id, int memberId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    // Atualizar progresso do membro após deletar
    await updateMemberProgress(memberId);

    return result;
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
    final result = await db.delete(table);

    // Atualizar progresso de todos os membros
    await membersHelper.updateAllMembersProgress();

    return result;
  }

  // 🔸 Contagem total de tarefas
  Future<int> getTasksCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 🔸 Buscar tarefas por membro
  Future<List<Task>> getTasksByMember(int memberId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      table,
      where: 'memberId = ?',
      whereArgs: [memberId],
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // 🔥 Atualizar progresso do membro
  Future<void> updateMemberProgress(int memberId) async {
    final tasks = await getTasksByMember(memberId);
    final assignedTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.status == 'Concluída').length;

    final completion = assignedTasks == 0 ? 0.0 : completedTasks / assignedTasks;

    await membersHelper.updateMemberTasksAndCompletion(
      memberId: memberId,
      assignedTasks: assignedTasks,
      completion: completion,
    );
  }

  // 🔥 Atualizar progresso de todos os membros
  Future<void> updateAllTasksAndMembers() async {
    final tasks = await getTasks();
    for (var task in tasks) {
      await updateMemberProgress(task.memberId);
    }
  }
}
