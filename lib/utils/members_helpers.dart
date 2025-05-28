import 'package:organeasy_app/utils/database_helpers.dart';
import 'package:sqflite/sqflite.dart';
import '../model/members.dart';

class MembersHelper {
  static const String table = 'members';

  // 🔸 Inserir membro
  Future<int> insertMember(Member member) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(
      table,
      member.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 🔸 Buscar todos os membros
  Future<List<Member>> getMembers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table);
    return result.map((e) => Member.fromMap(e)).toList();
  }

  // 🔸 Atualizar membro
  Future<int> updateMember(Member member) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  // 🔸 Deletar membro por ID
  Future<int> deleteMember(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 🔸 Deletar todos os membros
  Future<void> clearMembers() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(table);
  }


  // 🔸 Buscar cor do membro pelo ID
  Future<int> getSelectedColor(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      table,
      columns: ['color'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first['color'] as int;
    }
    return 0;
  }

  // 🔥 Atualizar progresso do membro específico
  Future<void> updateMemberProgress(int memberId) async {
    final db = await DatabaseHelper.instance.database;

    final totalTasks = await getTotalTasksForMember(memberId);
    final completedTasks = await getCompletedTasksForMember(memberId);

    final completion = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    await db.update(
      table,
      {
        'assigned_tasks': totalTasks,
        'completion': completion,
      },
      where: 'id = ?',
      whereArgs: [memberId],
    );
  }

  // 🔥 Atualizar progresso de todos os membros
  Future<void> updateAllMembersProgress() async {
    final members = await getMembers();
    for (var member in members) {
      await updateMemberProgress(member.id!);
    }
  }

  // 🔸 Calcular progresso (opcional, uso interno)
  Future<double> calculateCompletion(int memberId) async {
    final totalTasks = await getTotalTasksForMember(memberId);
    final completedTasks = await getCompletedTasksForMember(memberId);

    if (totalTasks == 0) return 0.0;

    return completedTasks / totalTasks;
  }

  // 🔸 Total de tarefas para o membro
  Future<int> getTotalTasksForMember(int memberId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM tasks WHERE memberId = ?',
      [memberId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 🔸 Total de tarefas concluídas para o membro
  Future<int> getCompletedTasksForMember(int memberId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) FROM tasks WHERE memberId = ? AND status = 'Concluída'",
      [memberId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 🔥 Atualizar quantidade de tarefas e progresso de um membro
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

}
