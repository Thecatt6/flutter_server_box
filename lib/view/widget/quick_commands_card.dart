// lib/view/widget/quick_commands_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/model/quick_command.dart';
import '../../data/model/server.dart';
import '../../data/provider/quick_command.dart';

class QuickCommandsCard extends StatefulWidget {
  final Server server;

  const QuickCommandsCard({
    Key? key,
    required this.server,
  }) : super(key: key);

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
        final commands = provider.getCommandsForServer(widget.server.id);

        if (commands.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.terminal, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No quick commands configured',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToSettings(context),
                    icon: Icon(Icons.add),
                    label: Text('Add Commands'),
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
                    Icon(Icons.flash_on, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Quick Commands',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.settings, size: 20),
                      onPressed: () => _navigateToSettings(context),
                      tooltip: 'Configure commands',
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: commands.length,
                itemBuilder: (context, index) {
                  final command = commands[index];
                  return _buildCommandTile(command);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommandTile(QuickCommand command) {
    final isLoading = _loading[command.id] ?? false;
    final result = _results[command.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: Icon(_getIcon(command.icon)),
          title: Text(command.name),
          subtitle: command.description != null
              ? Text(command.description!, style: TextStyle(fontSize: 12))
              : null,
          trailing: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () => _executeCommand(command),
                  tooltip: 'Execute',
                ),
          onTap: isLoading ? null : () => _executeCommand(command),
        ),
        if (result != null) _buildResultDisplay(command.id, result),
        if (index < _results.length - 1) Divider(height: 1),
      ],
    );
  }

  Widget _buildResultDisplay(String commandId, CommandResult result) {
    final hasError = result.exitCode != 0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasError 
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasError ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
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
              SizedBox(width: 8),
              Text(
                hasError ? 'Error (exit: ${result.exitCode})' : 'Success',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hasError ? Colors.red : Colors.green,
                ),
              ),
              Spacer(),
              Text(
                _formatTime(result.timestamp),
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.copy, size: 16),
                onPressed: () => _copyOutput(result.output),
                tooltip: 'Copy output',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 16),
                onPressed: () => _clearResult(commandId),
                tooltip: 'Clear',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          if (result.output.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
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
      // Qui dovrai usare il client SSH esistente del progetto
      // Assumo che ci sia un metodo simile disponibile
      final client = widget.server.client;
      
      if (client == null) {
        throw Exception('Server not connected');
      }

      final result = await client.run(command.command);
      final output = result.stdout ?? result.stderr ?? '';
      
      setState(() {
        _results[command.id] = CommandResult(
          output: output.toString(),
          exitCode: result.exitCode ?? 1,
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
      SnackBar(content: Text('Output copied to clipboard')),
    );
  }

  void _clearResult(String commandId) {
    setState(() {
      _results.remove(commandId);
    });
  }

  void _navigateToSettings(BuildContext context) {
    // Naviga alla schermata di configurazione
    // Navigator.push(context, MaterialPageRoute(builder: (_) => QuickCommandsSettingsPage()));
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
