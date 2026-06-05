import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/device.dart';
import '../models/reading.dart';
import '../models/alert.dart';
import 'package:fl_chart/fl_chart.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Device> _devices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final devices = await context.read<ApiService>().getDevices();
      if (!mounted) return;
      setState(() { _devices = devices; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _addDevice() async {
    final api = context.read<ApiService>();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _AddDeviceDialog(),
    );
    if (result == null || !mounted) return;
    try {
      await api.createDevice(
            result['name']!,
            result['location']!,
            result['type']!,
          );
      if (!mounted) return;
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteDevice(int id) async {
    try {
      await context.read<ApiService>().deleteDevice(id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDevice,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
              ? const Center(child: Text('No devices yet. Tap + to add one.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (ctx, i) {
                      final d = _devices[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.electrical_services),
                          title: Text(d.name),
                          subtitle: Text('${d.location} · ${d.type}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.show_chart),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          _DeviceDetailScreen(device: d)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () => _deleteDevice(d.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _DeviceDetailScreen extends StatefulWidget {
  final Device device;
  const _DeviceDetailScreen({required this.device});

  @override
  State<_DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<_DeviceDetailScreen> {
  List<Reading> _readings = [];
  List<Alert> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final api = context.read<ApiService>();
    final results = await Future.wait([
      api.getReadingsForDevice(widget.device.id),
      api.getAlertsForDevice(widget.device.id),
    ]);
    if (!mounted) return;
    setState(() {
      _readings = (results[0] as List<Reading>).reversed.toList();
      _alerts   = results[1] as List<Alert>;
      _loading  = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Readings (last ${_readings.length})',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (_readings.length >= 2)
                    SizedBox(height: 200, child: _ReadingsChart(readings: _readings))
                  else
                    const Text('Not enough readings for a chart.'),
                  const SizedBox(height: 24),
                  Text('Alerts (${_alerts.length})',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_alerts.isEmpty)
                    const Text('No alerts for this device.')
                  else
                    ..._alerts.map((a) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.warning_amber_rounded,
                                color: Colors.orange),
                            title: Text(a.message,
                                maxLines: 3, overflow: TextOverflow.ellipsis),
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

class _ReadingsChart extends StatelessWidget {
  final List<Reading> readings;
  const _ReadingsChart({required this.readings});

  @override
  Widget build(BuildContext context) {
    final spots = readings.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withAlpha(40),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddDeviceDialog extends StatefulWidget {
  const _AddDeviceDialog();

  @override
  State<_AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<_AddDeviceDialog> {
  final _nameCtrl     = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _type = 'Electricity';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Device'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: ['Electricity', 'Gas', 'Water', 'Solar']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, {
            'name':     _nameCtrl.text.trim(),
            'location': _locationCtrl.text.trim(),
            'type':     _type,
          }),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
