import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/alert.dart';
import '../models/device.dart';
import 'devices_screen.dart';
import 'alerts_screen.dart';
import 'login_screen.dart';

const _navy = Color(0xFF0A1628);
const _navyLight = Color(0xFF0F2040);
const _green = Color(0xFF00D4AA);
const _greenDark = Color(0xFF00A87E);
const _orange = Color(0xFFFF6B35);
const _cardSurface = Color(0xFF162033);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List<Device> _devices = [];
  List<Alert> _alerts = [];
  bool _loading = true;
  String? _error;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final results =
          await Future.wait([api.getDevices(), api.getAlerts()]);
      if (!mounted) return;
      setState(() {
        _devices = results[0] as List<Device>;
        _alerts = results[1] as List<Alert>;
        _loading = false;
      });
      _animCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await context.read<ApiService>().logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => screen,
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _navyLight],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0x18FFFFFF)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 8, 18),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_green, _greenDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _green.withAlpha(70),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt_rounded, size: 22, color: _navy),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EnergyTrack',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(110),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white60, size: 22),
                onPressed: _load,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.white60, size: 22),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _green, strokeWidth: 2.5),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: _orange, size: 52),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, color: _green),
                label: const Text('Try again',
                    style: TextStyle(color: _green, fontSize: 15)),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: RefreshIndicator(
        onRefresh: _load,
        color: _green,
        backgroundColor: _cardSurface,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            _sectionLabel('OVERVIEW'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _GradientStatCard(
                    icon: Icons.devices_rounded,
                    label: 'Devices',
                    value: '${_devices.length}',
                    gradientColors: const [
                      Color(0xFF0F2B5B),
                      Color(0xFF1A3F80),
                    ],
                    accentColor: const Color(0xFF5B8FFF),
                    onTap: () => _navigateTo(const DevicesScreen()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _GradientStatCard(
                    icon: Icons.warning_amber_rounded,
                    label: 'Alerts',
                    value: '${_alerts.length}',
                    gradientColors: _alerts.isNotEmpty
                        ? const [Color(0xFF4A1A08), Color(0xFF8B3410)]
                        : const [Color(0xFF0A2E1E), Color(0xFF0E4530)],
                    accentColor: _alerts.isNotEmpty ? _orange : _green,
                    onTap: () => _navigateTo(const AlertsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _sectionLabel('RECENT ALERTS'),
            const SizedBox(height: 14),
            if (_alerts.isEmpty)
              _buildEmptyAlerts()
            else
              ..._alerts.take(5).map((a) => _DashboardAlertCard(alert: a)),
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

  Widget _buildEmptyAlerts() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _green.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: _green, size: 22),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All systems normal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'No active alerts',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradientColors;
  final Color accentColor;
  final VoidCallback onTap;

  const _GradientStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradientColors,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withAlpha(50)),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withAlpha(100),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: accentColor.withAlpha(150), size: 14),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: accentColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardAlertCard extends StatelessWidget {
  final Alert alert;
  const _DashboardAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _orange.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _orange.withAlpha(28),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: _orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
