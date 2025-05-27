import 'package:flutter/material.dart';

class Task {
  int? id;
  String name;
  String room;
  String member;
  String status;
  Color color;

  Task({
    this.id,
    required this.name,
    required this.room,
    required this.member,
    required this.status,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'room': room,
      'member': member,
      'status': status,
      'color': color.value,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      room: map['room'],
      member: map['member'],
      status: map['status'],
      color: Color(map['color']),
    );
  }
}
