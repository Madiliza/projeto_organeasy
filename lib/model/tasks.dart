import 'dart:ui';

class Task {
  int? id;
  String name;
  String room;
  String member;
  String status;
  Color color;
  DateTime date;

  Task({
    this.id,
    required this.name,
    required this.room,
    required this.member,
    required this.status,
    required this.color,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'room': room,
      'member': member,
      'status': status,
      'color': color.value,
      'date': date.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      name: (map['name'] ?? 'Sem nome') as String,
      room: (map['room'] ?? 'Sem cômodo') as String,
      member: (map['member'] ?? '') as String,
      status: (map['status'] ?? 'Não realizada') as String,
      color: Color(map['color'] as int),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}
