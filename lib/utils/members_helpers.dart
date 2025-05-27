import 'package:organeasy_app/utils/database_helpers.dart';
import 'package:sqflite/sqflite.dart';
import '../model/members.dart';


class MembersHelper {
  static const table = 'members';

  Future<int> insertMember(Member member) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(table, member.toMap());
  }

  Future<List<Member>> getMembers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table);
    return result.map((e) => Member.fromMap(e)).toList();
  }

  Future<int> updateMember(Member member) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  //metodo para selecionar cor pré selecionada
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
    return 0; // Retorna 0 se não encontrar a cor
  }

  Future<void> clearMembers() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(table);
  }

//criar classe para buscar todos os membros e retornar uma lista de membros
  Future<List<Member>> getAllMembers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table);
    return result.map((e) => Member.fromMap(e)).toList();
  }

}
