// lib/view/widget/quick_commands_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:server_box/data/model/quick_command.dart';
import 'package:server_box/data/model/server/server.dart';
import 'package:server_box/data/provider/quick_command.dart';
import 'package:server_box/view/page/quick_commands_settings.dart';

class QuickCommandsCard extends StatefulWidget {
  final Server server;

  const QuickCommandsCard({
    super.key,
    required this.server,
  });

  @override
  State<QuickCommandsCard> createState() => _QuickCommandsCardState();
}

class _QuickCommandsCardState extends State<QuickCommandsCard> {
  final Map<String, CommandResult> _results = {};
  final Map<String, bool> _loading = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<QuickCommandProvider>(
      builder: (context, provider, child) {
        final commands = provider.getCommandsForServer(widget.server.spi.id);

        if (commands.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.terminal, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text(
                    'No quick commands configured',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToSettings(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Commands'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Commands',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings, size: 20),
                      onPressed: () => _navigateToSettings(context),
                      tooltip: 'Configure commands',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: commands.length,
                itemBuilder: (context, index) {
                  final command = commands[index];
                  return _buildCommandTile(command, index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommandTile(QuickCommand command, int index) {
    final isLoading = _loading[command.id] ?? false;
    final result = _results[command.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: Icon(_getIcon(command.icon)),
          title: Text(command.name),
          subtitle: command.description != null
              ? Text(command.description!, style: const TextStyle(fontSize: 12))
              : null,
          trailing: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _executeCommand(command),
                  tooltip: 'Execute',
                ),
          onTap: isLoading ? null : () => _executeCommand(command),
        ),
        if (result != null) _buildResultDisplay(command.id, result),
        if (index < _results.length - 1) const Divider(height: 1),
      ],
    );
  }

  Widget _buildResultDisplay(String commandId, CommandResult result) {
    final hasError = result.exitCode != 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasError
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasError
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasError ? Icons.error_outline : Icons.check_circle_outline,
                size: 16,
                color: hasError ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                hasError ? 'Error (exit: ${result.exitCode})' : 'Success',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hasError ? Colors.red : Colors.green,
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(result.timestamp),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () => _copyOutput(result.output),
                tooltip: 'Copy output',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => _clearResult(commandId),
                tooltip: 'Clear',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (result.output.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                result.output,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: hasError ? Colors.red[700] : Colors.black87,
                ),
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  Future<void> _executeCommand(QuickCommand command) async {
    setState(() {
      _loading[command.id] = true;
      _results.remove(command.id);
    });

    try {
      // Usa il client SSH di ServerBox
      final client = widget.server.client;

      if (client == null) {
        throw Exception('Server not connected');
      }

      final result = await client.run(command.command);
      
      setState(() {
        _results[command.id] = CommandResult(
          output: result.trim(),
          exitCode: 0,
          timestamp: DateTime.now(),
        );
      });
    } catch (e) {
      setState(() {
        _results[command.id] = CommandResult(
          output: 'Error: $e',
          exitCode: 1,
          timestamp: DateTime.now(),
        );
      });
    } finally {
      setState(() {
        _loading[command.id] = false;
      });
    }
  }

  void _copyOutput(String output) {
    Clipboard.setData(ClipboardData(text: output));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Output copied to clipboard')),
    );
  }

  void _clearResult(String commandId) {
    setState(() {
      _results.remove(commandId);
    });
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuickCommandsSettingsPage()),
    );
  }
}

class CommandResult {
  final String output;
  final int exitCode;
  final DateTime timestamp;

  CommandResult({
    required this.output,
    required this.exitCode,
    required this.timestamp,
  });
}
