import 'dart:ui';

class Member {
  int? id;
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
    this.completion = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'initial': initial,
      'color': color.value, // Salva a cor como inteiro
      'assigned_tasks': assignedTasks,
      'completion': completion,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as int?,
      name: map['name'] as String,
      initial: map['initial'] as String,
      color: Color(map['color'] as int),
      assignedTasks: (map['assigned_tasks'] ?? 0) as int,
      completion: (map['completion'] ?? 0.0).toDouble(),
    );
  }
}
