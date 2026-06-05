import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/alert.dart';
import '../models/device.dart';
import 'devices_screen.dart';
import 'alerts_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Device> _devices = [];
  List<Alert> _alerts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = context.read<ApiService>();
      final results = await Future.wait([api.getDevices(), api.getAlerts()]);
      if (!mounted) return;
      setState(() {
        _devices = results[0] as List<Device>;
        _alerts  = results[1] as List<Alert>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _logout() async {
    await context.read<ApiService>().logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _alerts.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _SummaryCard(
                        icon: Icons.devices,
                        label: 'Devices',
                        value: '${_devices.length}',
                        color: Colors.blue,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const DevicesScreen())),
                      ),
                      const SizedBox(height: 12),
                      _SummaryCard(
                        icon: Icons.warning_amber_rounded,
                        label: 'Active Alerts',
                        value: '$unread',
                        color: unread > 0 ? Colors.red : Colors.green,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AlertsScreen())),
                      ),
                      const SizedBox(height: 24),
                      Text('Recent Alerts',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (_alerts.isEmpty)
                        const Text('No alerts — all systems normal.')
                      else
                        ..._alerts.take(5).map((a) => Card(
                              child: ListTile(
                                leading: const Icon(Icons.warning_amber_rounded,
                                    color: Colors.orange),
                                title: Text(a.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                    '${a.timestamp.toLocal()}'.substring(0, 16)),
                              ),
                            )),
                    ],
                  ),
                ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Text(value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
