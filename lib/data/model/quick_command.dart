// lib/data/model/quick_command.dart
import 'package:hive/hive.dart';

part 'quick_command.g.dart';

@HiveType(typeId: 10) // Usa un typeId non ancora utilizzato nel progetto
class QuickCommand extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String command;

  @HiveField(3)
  String? description;

  @HiveField(4)
  String? icon; // Nome dell'icona (es: 'terminal', 'refresh', 'info')

  @HiveField(5)
  String? serverId; // Se null, comando disponibile per tutti i server

  @HiveField(6)
  int order;

  @HiveField(7)
  DateTime createdAt;

  QuickCommand({
    required this.id,
    required this.name,
    required this.command,
    this.description,
    this.icon,
    this.serverId,
    this.order = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  QuickCommand copyWith({
    String? id,
    String? name,
    String? command,
    String? description,
    String? icon,
    String? serverId,
    int? order,
    DateTime? createdAt,
  }) {
    return QuickCommand(
      id: id ?? this.id,
      name: name ?? this.name,
      command: command ?? this.command,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      serverId: serverId ?? this.serverId,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'command': command,
      'description': description,
      'icon': icon,
      'serverId': serverId,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QuickCommand.fromJson(Map<String, dynamic> json) {
    return QuickCommand(
      id: json['id'] as String,
      name: json['name'] as String,
      command: json['command'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      serverId: json['serverId'] as String?,
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
