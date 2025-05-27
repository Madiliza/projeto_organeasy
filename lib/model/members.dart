import 'dart:ui';

class Member {
  int? id; // Para suportar banco de dados
  final String name;
  final String initial;
  final Color color;
  final int assignedTasks;
  final double completion;

  Member({
    this.id,
    required this.name,
    required this.initial,
    required this.color,
    this.assignedTasks = 0,
    this.completion = 0,
  });

  // Converter para mapa (para inserir no banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'initial': initial,
      'color': color.value, // <- salva como inteiro
      'assigned_tasks': assignedTasks,
      'completion': completion,
    };
  }


  // Criar um objeto a partir do banco
  factory Member.fromMap(Map<String, dynamic> map) {
  return Member(
    id: map['id'] as int,
    name: map['name'] as String,
    initial: map['initial'] as String,
    color: Color(map['color'] as int), // <- recupera como inteiro para Color
    assignedTasks: map['assigned_tasks'] as int,
    completion: map['completion'] as double,
  );
}

}
