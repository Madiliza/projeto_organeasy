import 'dart:ui';

class Task {
  int? id;
  String name;
  String room;
  int memberId; // <-- Adicionado ID do membro
  String memberName; // <-- Opcional: para exibir nome, se quiser
  String status;
  Color color;
  DateTime date;

  Task({
    this.id,
    required this.name,
    required this.room,
    required this.memberId,
    required this.memberName,
    required this.status,
    required this.color,
    required this.date, required String member,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'room': room,
      'memberId': memberId, // <-- Gravamos o ID
      'memberName': memberName, // <-- Nome apenas para exibição
      'status': status,
      'color': color.value,
      'date': date.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      name: (map['name'] ?? '') as String,
      room: (map['room'] ?? '') as String,
      memberId: (map['memberId'] ?? 0) as int, // <-- Importante
      memberName: (map['memberName'] ?? '') as String, // <-- Importante
      status: (map['status'] ?? 'Não realizada') as String,
      color: Color(map['color'] as int),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(), 
      member: '',
    );
  }
  Task copyWith({
    int? id,
    String? name,
    String? room,
    int? memberId,
    String? memberName,
    String? status,
    Color? color,
    DateTime? date, required String member,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      status: status ?? this.status,
      color: color ?? this.color,
      date: date ?? this.date, 
      member: '',
    );
  }

  // 🔥 Facilitar debug
  @override
  String toString() {
    return 'Task(id: $id, name: $name, room: $room, memberId: $memberId, memberName: $memberName, status: $status, color: ${color.value}, date: $date)';
  }
}
