// lib/data/provider/quick_command.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:server_box/data/model/quick_command.dart';
import 'package:server_box/data/provider/default_quick_commands.dart';
import 'package:server_box/data/res/store.dart';

class QuickCommandProvider with ChangeNotifier {
  static const String _storeKey = 'quick_commands';

  List<QuickCommand> _commands = [];

  List<QuickCommand> get commands {
    return List.unmodifiable(_commands)
    ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> init() async {
    await _loadCommands();
  }

  Future<void> _loadCommands() async {
    final stored = Stores.setting.box.get(_storeKey);
    if (stored == null || stored.isEmpty) {
      _commands = [];
    } else {
      try {
        final List<dynamic> jsonList = json.decode(stored);
        _commands = jsonList
        .map((json) => QuickCommand.fromJson(json as Map<String, dynamic>))
        .toList();
      } catch (e) {
        _commands = [];
      }
    }
    notifyListeners();
  }

  Future<void> _saveCommands() async {
    final jsonString = json.encode(_commands.map((c) => c.toJson()).toList());
    await Stores.setting.box.put(_storeKey, jsonString);
  }

  List<QuickCommand> getCommandsForServer(String? serverId) {
    return _commands
    .where((cmd) => cmd.serverId == null || cmd.serverId == serverId)
    .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> addCommand(QuickCommand command) async {
    _commands.add(command);
    await _saveCommands();
    notifyListeners();
  }

  Future<void> updateCommand(QuickCommand command) async {
    final index = _commands.indexWhere((c) => c.id == command.id);
    if (index != -1) {
      _commands[index] = command;
      await _saveCommands();
      notifyListeners();
    }
  }

  Future<void> deleteCommand(String id) async {
    _commands.removeWhere((c) => c.id == id);
    await _saveCommands();
    notifyListeners();
  }

  Future<void> reorderCommands(List<QuickCommand> reordered) async {
    _commands = reordered.asMap().entries.map((entry) {
      return entry.value.copyWith(order: entry.key);
    }).toList();
    await _saveCommands();
    notifyListeners();
  }

  Future<void> addDefaultCommands() async {
    final defaults = DefaultQuickCommands.essential;
    for (var cmd in defaults) {
      if (!_commands.any((c) => c.id == cmd.id)) {
        await addCommand(cmd);
      }
    }
  }

  Future<void> addCommandsByCategory(String category) async {
    final commands = DefaultQuickCommands.getByCategory(category);
    for (var cmd in commands) {
      if (!_commands.any((c) => c.id == cmd.id)) {
        await addCommand(cmd);
      }
    }
  }

  Future<void> addAllDefaultCommands() async {
    for (var cmd in DefaultQuickCommands.all) {
      if (!_commands.any((c) => c.id == cmd.id)) {
        await addCommand(cmd);
      }
    }
  }
}
