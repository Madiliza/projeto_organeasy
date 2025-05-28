class Room {
  final int? id;
  final String name;
  final int icon;

  Room({this.id, required this.name, required this.icon});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

 factory Room.fromMap(Map<String, dynamic> map) {
  return Room(
    id: map['id'] as int?,
    name: map['name'] as String,
    icon: map['icon']! as int, 
  );
}
}

