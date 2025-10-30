// lib/data/model/quick_command.dart
class QuickCommand {
  final String id;
  final String name;
  final String command;
  final String? description;
  final String? icon;
  final String? serverId;
  final int order;
  final DateTime createdAt;

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
