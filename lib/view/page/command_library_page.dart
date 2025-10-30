// lib/view/page/command_library_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:server_box/data/model/quick_command.dart';
import 'package:server_box/data/provider/quick_command.dart';
import 'package:server_box/data/provider/default_quick_commands.dart';

class CommandLibraryPage extends StatefulWidget {
  const CommandLibraryPage({super.key});

  @override
  State<CommandLibraryPage> createState() => _CommandLibraryPageState();
}

class _CommandLibraryPageState extends State<CommandLibraryPage> {
  final Map<String, bool> _selectedCommands = {};
  String _selectedCategory = 'all';

  final Map<String, Map<String, dynamic>> _categories = {
    'all': {'name': 'All Commands', 'icon': Icons.grid_view},
    'essential': {'name': 'Essential', 'icon': Icons.star},
    'system': {'name': 'System Info', 'icon': Icons.info},
    'disk': {'name': 'Disk & Memory', 'icon': Icons.storage},
    'process': {'name': 'Processes', 'icon': Icons.list},
    'network': {'name': 'Network', 'icon': Icons.network_check},
    'docker': {'name': 'Docker', 'icon': Icons.settings},
    'service': {'name': 'Services', 'icon': Icons.settings_applications},
    'security': {'name': 'Security', 'icon': Icons.security},
    'logs': {'name': 'Logs', 'icon': Icons.article},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Command Library'),
        actions: [
          if (_selectedCommands.values.any((v) => v))
            TextButton.icon(
              onPressed: _addSelectedCommands,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add (${_selectedCommands.values.where((v) => v).length})',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(child: _buildCommandList()),
        ],
      ),
      floatingActionButton: _selectedCommands.values.any((v) => v)
          ? FloatingActionButton.extended(
              onPressed: _addSelectedCommands,
              icon: Icon(Icons.add),
              label: Text('Add ${_selectedCommands.values.where((v) => v).length}'),
            )
          : null,
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories.keys.elementAt(index);
          final categoryData = _categories[category]!;
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    categoryData['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : null,
                  ),
                  SizedBox(width: 4),
                  Text(categoryData['name'] as String),
                ],
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommandList() {
    final commands = _getCommandsForCategory();
    final provider = Provider.of<QuickCommandProvider>(context);
    final existingIds = provider.commands.map((c) => c.id).toSet();

    if (commands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No commands in this category'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: commands.length,
      itemBuilder: (context, index) {
        final command = commands[index];
        final alreadyAdded = existingIds.contains(command.id);
        final isSelected = _selectedCommands[command.id] ?? false;

        return Card(
          color: alreadyAdded
              ? Colors.grey.withValues(alpha: 0.1)
              : isSelected
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : null,
          child: ListTile(
            enabled: !alreadyAdded,
            leading: Checkbox(
              value: alreadyAdded ? true : isSelected,
              onChanged: alreadyAdded
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCommands[command.id] = value ?? false;
                      });
                    },
            ),
            title: Row(
              children: [
                Icon(_getIcon(command.icon), size: 20),
                SizedBox(width: 8),
                Expanded(child: Text(command.name)),
                if (alreadyAdded)
                  Chip(
                    label: Text('Added', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.green.withValues(alpha: 0.2),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  command.command,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (command.description != null) ...[
                  SizedBox(height: 2),
                  Text(
                    command.description!,
                    style: TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            isThreeLine: command.description != null,
            onTap: alreadyAdded
                ? null
                : () {
                    setState(() {
                      _selectedCommands[command.id] =
                          !(_selectedCommands[command.id] ?? false);
                    });
                  },
          ),
        );
      },
    );
  }

  List<QuickCommand> _getCommandsForCategory() {
    switch (_selectedCategory) {
      case 'all':
        return DefaultQuickCommands.all;
      case 'essential':
        return DefaultQuickCommands.essential;
      default:
        return DefaultQuickCommands.getByCategory(_selectedCategory);
    }
  }

  IconData _getIcon(String? iconName) {
    final iconMap = {
      'terminal': Icons.terminal,
      'refresh': Icons.refresh,
      'info': Icons.info,
      'storage': Icons.storage,
      'memory': Icons.memory,
      'schedule': Icons.schedule,
      'list': Icons.list,
      'network': Icons.network_check,
      'security': Icons.security,
      'settings': Icons.settings,
    };
    return iconMap[iconName] ?? Icons.flash_on;
  }

  Future<void> _addSelectedCommands() async {
    final provider = Provider.of<QuickCommandProvider>(context, listen: false);
    final commands = _getCommandsForCategory();
    
    int addedCount = 0;
    for (var command in commands) {
      if (_selectedCommands[command.id] == true) {
        await provider.addCommand(command);
        addedCount++;
      }
    }

    if (addedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $addedCount command${addedCount > 1 ? 's' : ''}'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
      
      setState(() {
        _selectedCommands.clear();
      });
    }
  }
}
