import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/device.dart';
import '../models/reading.dart';
import '../models/alert.dart';
import 'package:fl_chart/fl_chart.dart';

const _navy = Color(0xFF0A1628);
const _green = Color(0xFF00D4AA);
const _greenDark = Color(0xFF00A87E);
const _orange = Color(0xFFFF6B35);
const _cardSurface = Color(0xFF162033);
const _gridLine = Color(0x18FFFFFF);

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
      setState(() {
        _devices = devices;
        _loading = false;
      });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteDevice(int id) async {
    try {
      await context.read<ApiService>().deleteDevice(id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDevice,
        child: const Icon(Icons.add_rounded),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _green, strokeWidth: 2.5),
            )
          : _devices.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: _green,
                  backgroundColor: _cardSurface,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _devices.length,
                    itemBuilder: (ctx, i) => _DeviceCard(
                      device: _devices[i],
                      onDelete: () => _deleteDevice(_devices[i].id),
                      onViewChart: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) =>
                              _DeviceDetailScreen(device: _devices[i]),
                          transitionsBuilder: (_, anim, _, child) =>
                              SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                                parent: anim, curve: Curves.easeOutCubic)),
                            child: child,
                          ),
                          transitionDuration:
                              const Duration(milliseconds: 320),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _green.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.devices_rounded,
                size: 40, color: _green),
          ),
          const SizedBox(height: 20),
          const Text(
            'No devices yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first device',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onDelete;
  final VoidCallback onViewChart;

  const _DeviceCard({
    required this.device,
    required this.onDelete,
    required this.onViewChart,
  });

  IconData _typeIcon() {
    switch (device.type.toLowerCase()) {
      case 'gas':
        return Icons.local_fire_department_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'solar':
        return Icons.wb_sunny_rounded;
      default:
        return Icons.electrical_services_rounded;
    }
  }

  Color _typeColor() {
    switch (device.type.toLowerCase()) {
      case 'gas':
        return const Color(0xFFFF9500);
      case 'water':
        return const Color(0xFF34AADC);
      case 'solar':
        return const Color(0xFFFFD60A);
      default:
        return _green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withAlpha(28),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_typeIcon(), color: color, size: 24),
        ),
        title: Text(
          device.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${device.location} · ${device.type}',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.show_chart_rounded,
                  color: _green, size: 22),
              onPressed: onViewChart,
              tooltip: 'View chart',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade400, size: 22),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
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
      _alerts = results[1] as List<Alert>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _green, strokeWidth: 2.5),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: _green,
              backgroundColor: _cardSurface,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                children: [
                  _sectionLabel('READINGS (${_readings.length})'),
                  const SizedBox(height: 14),
                  if (_readings.length >= 2)
                    _buildChart()
                  else
                    _buildChartPlaceholder(),
                  const SizedBox(height: 28),
                  _sectionLabel('ALERTS (${_alerts.length})'),
                  const SizedBox(height: 14),
                  if (_alerts.isEmpty)
                    _buildNoAlerts()
                  else
                    ..._alerts.map((a) => _DetailAlertCard(alert: a)),
                ],
              ),
            ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white38,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: _ReadingsChart(readings: _readings),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: const Center(
        child: Text(
          'Not enough readings for a chart',
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildNoAlerts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withAlpha(40)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: _green, size: 22),
          SizedBox(width: 12),
          Text(
            'No alerts for this device',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _DetailAlertCard extends StatelessWidget {
  final Alert alert;
  const _DetailAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _orange.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _orange.withAlpha(28),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: _orange, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alert.timestamp.toLocal()}'.substring(0, 16),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
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
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: _gridLine,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(0),
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: _gridLine),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: _green,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  _green.withAlpha(60),
                  _green.withAlpha(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
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
  final _nameCtrl = TextEditingController();
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
      title: const Row(
        children: [
          Icon(Icons.add_circle_outline_rounded, color: _green, size: 22),
          SizedBox(width: 10),
          Text(
            'Add Device',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Device Name',
              prefixIcon: Icon(Icons.label_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _locationCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _type,
            dropdownColor: const Color(0xFF1A2B45),
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: const InputDecoration(
              labelText: 'Type',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: ['Electricity', 'Gas', 'Water', 'Solar']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_green, _greenDark],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(context, {
              'name': _nameCtrl.text.trim(),
              'location': _locationCtrl.text.trim(),
              'type': _type,
            }),
            child: const Text(
              'Add Device',
              style: TextStyle(
                color: _navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
