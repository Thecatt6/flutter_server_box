// lib/data/provider/quick_command.dart
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/quick_command.dart';
import 'default_quick_commands.dart';

class QuickCommandProvider extends ChangeNotifier {
  static const String _boxName = 'quick_commands';
  Box<QuickCommand>? _box;

  List<QuickCommand> get commands {
    if (_box == null) return [];
    return _box!.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> init() async {
    _box = await Hive.openBox<QuickCommand>(_boxName);
    notifyListeners();
  }

  List<QuickCommand> getCommandsForServer(String? serverId) {
    return commands.where((cmd) => 
      cmd.serverId == null || cmd.serverId == serverId
    ).toList();
  }

  Future<void> addCommand(QuickCommand command) async {
    await _box?.put(command.id, command);
    notifyListeners();
  }

  Future<void> updateCommand(QuickCommand command) async {
    await _box?.put(command.id, command);
    notifyListeners();
  }

  Future<void> deleteCommand(String id) async {
    await _box?.delete(id);
    notifyListeners();
  }

  Future<void> reorderCommands(List<QuickCommand> reordered) async {
    for (var i = 0; i < reordered.length; i++) {
      final updated = reordered[i].copyWith(order: i);
      await _box?.put(updated.id, updated);
    }
    notifyListeners();
  }

  Future<void> addDefaultCommands() async {
    // Importa i comandi essenziali predefiniti
    final defaults = DefaultQuickCommands.essential;

    for (var cmd in defaults) {
      if (!_box!.containsKey(cmd.id)) {
        await addCommand(cmd);
      }
    }
  }

  Future<void> addCommandsByCategory(String category) async {
    final commands = DefaultQuickCommands.getByCategory(category);
    
    for (var cmd in commands) {
      if (!_box!.containsKey(cmd.id)) {
        await addCommand(cmd);
      }
    }
  }

  Future<void> addAllDefaultCommands() async {
    for (var cmd in DefaultQuickCommands.all) {
      if (!_box!.containsKey(cmd.id)) {
        await addCommand(cmd);
      }
    }
  }
}
