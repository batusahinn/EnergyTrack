import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/alert.dart';

const _green = Color(0xFF00D4AA);
const _orange = Color(0xFFFF6B35);
const _cardSurface = Color(0xFF162033);

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<Alert> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final alerts = await context.read<ApiService>().getAlerts();
      if (!mounted) return;
      setState(() {
        _alerts = alerts;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _dismiss(int id) async {
    try {
      await context.read<ApiService>().deleteAlert(id);
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
        title: const Text('Alerts'),
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
          : _alerts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: _green,
                  backgroundColor: _cardSurface,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    itemCount: _alerts.length,
                    itemBuilder: (ctx, i) {
                      final a = _alerts[i];
                      return Dismissible(
                        key: Key('alert-${a.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade800,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.only(right: 24),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_rounded,
                                  color: Colors.white, size: 24),
                              SizedBox(height: 4),
                              Text(
                                'Dismiss',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        onDismissed: (_) => _dismiss(a.id),
                        child: _AlertCard(
                          alert: a,
                          onDismiss: () => _dismiss(a.id),
                        ),
                      );
                    },
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
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _green.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                size: 48, color: _green),
          ),
          const SizedBox(height: 20),
          const Text(
            'No active alerts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'All systems are running normally',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onDismiss;

  const _AlertCard({required this.alert, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final timeStr = '${alert.timestamp.toLocal()}'.substring(0, 16);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _orange.withAlpha(45)),
        boxShadow: [
          BoxShadow(
            color: _orange.withAlpha(18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _orange.withAlpha(28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: _orange, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.sensors_rounded,
                          size: 12, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        'Device ${alert.deviceId}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 18, color: Colors.white38),
              onPressed: onDismiss,
              tooltip: 'Dismiss',
            ),
          ],
        ),
      ),
    );
  }
}
