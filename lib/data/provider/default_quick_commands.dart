// lib/data/provider/default_quick_commands.dart
// Lista di comandi predefiniti utili da importare

import 'package:server_box/data/model/quick_command.dart';

class DefaultQuickCommands {
  static List<QuickCommand> get systemInfo => [
    QuickCommand(
      id: 'sys_uptime',
      name: 'System Uptime',
      command: 'uptime',
      description: 'Show how long the system has been running',
      icon: 'schedule',
      order: 0,
    ),
    QuickCommand(
      id: 'sys_uname',
      name: 'System Info',
      command: 'uname -a',
      description: 'Display system information',
      icon: 'info',
      order: 1,
    ),
    QuickCommand(
      id: 'sys_hostname',
      name: 'Hostname',
      command: 'hostname -f',
      description: 'Show full hostname',
      icon: 'terminal',
      order: 2,
    ),
    QuickCommand(
      id: 'sys_date',
      name: 'Date & Time',
      command: 'date',
      description: 'Display current date and time',
      icon: 'schedule',
      order: 3,
    ),
  ];

  static List<QuickCommand> get diskAndMemory => [
    QuickCommand(
      id: 'disk_usage',
      name: 'Disk Usage',
      command: 'df -h',
      description: 'Show disk space usage',
      icon: 'storage',
      order: 10,
    ),
    QuickCommand(
      id: 'disk_inodes',
      name: 'Inode Usage',
      command: 'df -i',
      description: 'Show inode usage',
      icon: 'storage',
      order: 11,
    ),
    QuickCommand(
      id: 'mem_free',
      name: 'Memory Usage',
      command: 'free -h',
      description: 'Display memory usage',
      icon: 'memory',
      order: 12,
    ),
    QuickCommand(
      id: 'disk_io',
      name: 'Disk I/O',
      command: 'iostat -x 1 2',
      description: 'Show disk I/O statistics',
      icon: 'storage',
      order: 13,
    ),
  ];

  static List<QuickCommand> get processManagement => [
    QuickCommand(
      id: 'proc_top_mem',
      name: 'Top Memory',
      command: 'ps aux --sort=-%mem | head -11',
      description: 'Top 10 processes by memory',
      icon: 'list',
      order: 20,
    ),
    QuickCommand(
      id: 'proc_top_cpu',
      name: 'Top CPU',
      command: 'ps aux --sort=-%cpu | head -11',
      description: 'Top 10 processes by CPU',
      icon: 'list',
      order: 21,
    ),
    QuickCommand(
      id: 'proc_count',
      name: 'Process Count',
      command: 'ps aux | wc -l',
      description: 'Total number of processes',
      icon: 'list',
      order: 22,
    ),
    QuickCommand(
      id: 'proc_zombie',
      name: 'Zombie Processes',
      command: 'ps aux | grep Z',
      description: 'List zombie processes',
      icon: 'list',
      order: 23,
    ),
  ];

  static List<QuickCommand> get networkCommands => [
    QuickCommand(
      id: 'net_interfaces',
      name: 'Network Interfaces',
      command: 'ip -br addr',
      description: 'Show network interfaces',
      icon: 'network',
      order: 30,
    ),
    QuickCommand(
      id: 'net_connections',
      name: 'Active Connections',
      command: 'ss -tuln',
      description: 'Show listening ports',
      icon: 'network',
      order: 31,
    ),
    QuickCommand(
      id: 'net_established',
      name: 'Established Connections',
      command: 'ss -tn state established',
      description: 'Show established TCP connections',
      icon: 'network',
      order: 32,
    ),
    QuickCommand(
      id: 'net_bandwidth',
      name: 'Network Stats',
      command: 'ifstat -t 1 1',
      description: 'Show network bandwidth',
      icon: 'network',
      order: 33,
    ),
  ];

  static List<QuickCommand> get dockerCommands => [
    QuickCommand(
      id: 'docker_ps',
      name: 'Docker Containers',
      command: 'docker ps',
      description: 'List running containers',
      icon: 'terminal',
      order: 40,
    ),
    QuickCommand(
      id: 'docker_ps_all',
      name: 'All Containers',
      command: 'docker ps -a',
      description: 'List all containers',
      icon: 'terminal',
      order: 41,
    ),
    QuickCommand(
      id: 'docker_images',
      name: 'Docker Images',
      command: 'docker images',
      description: 'List Docker images',
      icon: 'storage',
      order: 42,
    ),
    QuickCommand(
      id: 'docker_stats',
      name: 'Container Stats',
      command: 'docker stats --no-stream',
      description: 'Show container resource usage',
      icon: 'info',
      order: 43,
    ),
    QuickCommand(
      id: 'docker_disk',
      name: 'Docker Disk Usage',
      command: 'docker system df',
      description: 'Show Docker disk usage',
      icon: 'storage',
      order: 44,
    ),
  ];

  static List<QuickCommand> get serviceManagement => [
    QuickCommand(
      id: 'systemd_failed',
      name: 'Failed Services',
      command: 'systemctl --failed',
      description: 'List failed systemd services',
      icon: 'settings',
      order: 50,
    ),
    QuickCommand(
      id: 'systemd_active',
      name: 'Active Services',
      command: 'systemctl list-units --type=service --state=running',
      description: 'List running services',
      icon: 'settings',
      order: 51,
    ),
    QuickCommand(
      id: 'nginx_status',
      name: 'Nginx Status',
      command: 'systemctl status nginx',
      description: 'Check Nginx service status',
      icon: 'settings',
      order: 52,
    ),
    QuickCommand(
      id: 'apache_status',
      name: 'Apache Status',
      command: 'systemctl status apache2',
      description: 'Check Apache service status',
      icon: 'settings',
      order: 53,
    ),
  ];

  static List<QuickCommand> get securityCommands => [
    QuickCommand(
      id: 'security_last_logins',
      name: 'Last Logins',
      command: 'last -10',
      description: 'Show last 10 logins',
      icon: 'security',
      order: 60,
    ),
    QuickCommand(
      id: 'security_failed_logins',
      name: 'Failed Logins',
      command: 'lastb -10',
      description: 'Show last failed login attempts',
      icon: 'security',
      order: 61,
    ),
    QuickCommand(
      id: 'security_users',
      name: 'Logged Users',
      command: 'w',
      description: 'Show who is logged in',
      icon: 'security',
      order: 62,
    ),
    QuickCommand(
      id: 'security_listening',
      name: 'Open Ports',
      command: 'ss -tuln | grep LISTEN',
      description: 'Show listening ports',
      icon: 'security',
      order: 63,
    ),
  ];

  static List<QuickCommand> get logsCommands => [
    QuickCommand(
      id: 'logs_syslog',
      name: 'System Logs',
      command: 'journalctl -n 50 --no-pager',
      description: 'Last 50 system log entries',
      icon: 'info',
      order: 70,
    ),
    QuickCommand(
      id: 'logs_errors',
      name: 'Error Logs',
      command: 'journalctl -p err -n 20 --no-pager',
      description: 'Last 20 error log entries',
      icon: 'info',
      order: 71,
    ),
    QuickCommand(
      id: 'logs_kernel',
      name: 'Kernel Logs',
      command: 'dmesg | tail -20',
      description: 'Last 20 kernel messages',
      icon: 'info',
      order: 72,
    ),
    QuickCommand(
      id: 'logs_auth',
      name: 'Auth Logs',
      command: 'tail -20 /var/log/auth.log',
      description: 'Last 20 authentication logs',
      icon: 'security',
      order: 73,
    ),
  ];

  // Metodo helper per ottenere tutti i comandi
  static List<QuickCommand> get all => [
    ...systemInfo,
    ...diskAndMemory,
    ...processManagement,
    ...networkCommands,
    ...dockerCommands,
    ...serviceManagement,
    ...securityCommands,
    ...logsCommands,
  ];

  // Metodo helper per ottenere comandi essenziali
  static List<QuickCommand> get essential => [
    systemInfo[0], // uptime
    diskAndMemory[0], // disk usage
    diskAndMemory[2], // memory
    processManagement[0], // top memory
    networkCommands[0], // network interfaces
  ];

  // Metodo per ottenere comandi per categoria
  static List<QuickCommand> getByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'system':
        return systemInfo;
      case 'disk':
      case 'memory':
        return diskAndMemory;
      case 'process':
        return processManagement;
      case 'network':
        return networkCommands;
      case 'docker':
        return dockerCommands;
      case 'service':
        return serviceManagement;
      case 'security':
        return securityCommands;
      case 'logs':
        return logsCommands;
      default:
        return [];
    }
  }
}
