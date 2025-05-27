import 'package:organeasy_app/utils/database_helpers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../model/members.dart';

class MembersHelper {
  static const table = 'members';

  // 🔸 Inserir Member
  Future<int> insertMember(Member member) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(
      table,
      member.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 🔸 Buscar todos os Members
  Future<List<Member>> getMembers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table);
    return result.map((e) => Member.fromMap(e)).toList();
  }

  // 🔸 Atualizar Member
  Future<int> updateMember(Member member) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  // 🔸 Deletar Member por ID
  Future<int> deleteMember(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 🔸 Buscar cor do Member pelo ID
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
    return 0; // Se não encontrar, retorna 0 (pode ser uma cor default)
  }

  // 🔸 Deletar todos os Members
  Future<void> clearMembers() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(table);
  }

  // 🔸 Buscar todos os Members (redundante, mas deixa claro)
  Future<List<Member>> getAllMembers() async {
    return await getMembers();
  }
}
