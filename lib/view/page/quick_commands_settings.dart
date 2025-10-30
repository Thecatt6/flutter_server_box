// lib/view/page/quick_commands_settings.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:server_box/data/model/quick_command.dart';
import 'package:server_box/data/provider/quick_command.dart';
import 'package:server_box/view/page/command_library_page.dart';

class QuickCommandsSettingsPage extends StatelessWidget {
  const QuickCommandsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Commands'),
        actions: [
          IconButton(
            icon: Icon(Icons.library_add),
            onPressed: () => _navigateToLibrary(context),
            tooltip: 'Browse command library',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCommandDialog(context),
            tooltip: 'Create custom command',
          ),
        ],
      ),
      body: Consumer<QuickCommandProvider>(
        builder: (context, provider, child) {
          final commands = provider.commands;

          if (commands.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.terminal, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No commands configured', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await provider.addDefaultCommands();
                    },
                    icon: Icon(Icons.add),
                    label: Text('Add Default Commands'),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: commands.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final items = List<QuickCommand>.from(commands);
              final item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
              provider.reorderCommands(items);
            },
            itemBuilder: (context, index) {
              final command = commands[index];
              return _buildCommandCard(context, command, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCommandDialog(context),
        icon: Icon(Icons.add),
        label: Text('Add Command'),
      ),
    );
  }

  Widget _buildCommandCard(
    BuildContext context,
    QuickCommand command,
    QuickCommandProvider provider,
  ) {
    return Card(
      key: ValueKey(command.id),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(_getIcon(command.icon)),
        title: Text(command.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            if (command.description != null)
              Text(
                command.description!,
                style: TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 20),
              onPressed: () => _showCommandDialog(context, command),
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _confirmDelete(context, command, provider),
            ),
          ],
        ),
        isThreeLine: command.description != null,
      ),
    );
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

  void _showCommandDialog(BuildContext context, [QuickCommand? existing]) {
    showDialog(
      context: context,
      builder: (context) => CommandEditDialog(command: existing),
    );
  }

  void _navigateToLibrary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommandLibraryPage()),
    );
  }

  void _confirmDelete(
    BuildContext context,
    QuickCommand command,
    QuickCommandProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Command'),
        content: Text('Are you sure you want to delete "${command.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCommand(command.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class CommandEditDialog extends StatefulWidget {
  final QuickCommand? command;

  const CommandEditDialog({super.key, this.command});

  @override
  State<CommandEditDialog> createState() => _CommandEditDialogState();
}

class _CommandEditDialogState extends State<CommandEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _commandController;
  late TextEditingController _descriptionController;
  String _selectedIcon = 'flash_on';

  final List<String> _availableIcons = [
    'flash_on', 'terminal', 'refresh', 'info', 'storage',
    'memory', 'schedule', 'list', 'network', 'security', 'settings'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.command?.name ?? '');
    _commandController = TextEditingController(text: widget.command?.command ?? '');
    _descriptionController = TextEditingController(text: widget.command?.description ?? '');
    _selectedIcon = widget.command?.icon ?? 'flash_on';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commandController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.command != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Command' : 'New Command'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _commandController,
              decoration: InputDecoration(
                labelText: 'Command',
                border: OutlineInputBorder(),
                hintText: 'e.g., df -h',
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('Icon', style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((iconName) {
                final isSelected = iconName == _selectedIcon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = iconName),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(_getIconData(iconName)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveCommand,
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
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
      'flash_on': Icons.flash_on,
    };
    return iconMap[iconName] ?? Icons.flash_on;
  }

  void _saveCommand() {
    final name = _nameController.text.trim();
    final command = _commandController.text.trim();

    if (name.isEmpty || command.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name and command are required')),
      );
      return;
    }

    final provider = Provider.of<QuickCommandProvider>(context, listen: false);
    
    final quickCommand = QuickCommand(
      id: widget.command?.id ?? Uuid().v4(),
      name: name,
      command: command,
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      icon: _selectedIcon,
      order: widget.command?.order ?? provider.commands.length,
    );

    if (widget.command != null) {
      provider.updateCommand(quickCommand);
    } else {
      provider.addCommand(quickCommand);
    }

    Navigator.pop(context);
  }
}
