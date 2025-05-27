class Room {
  final int? id;
  final String name;

  Room({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }
}
