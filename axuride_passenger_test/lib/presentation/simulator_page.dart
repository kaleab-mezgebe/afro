import 'package:flutter/material.dart';
import 'simulator_controller.dart';

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  final SimulatorController _ctrl = SimulatorController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onUpdate);
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'AxuRide Passenger Simulator',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            tooltip: 'Reset',
            onPressed: _ctrl.busy ? null : _ctrl.reset,
          ),
        ],
      ),
      body: Column(
        children: [
          _StatusBar(ctrl: _ctrl),
          _ActionRow(ctrl: _ctrl),
          Expanded(
            child: _LogConsole(ctrl: _ctrl, scroll: _scroll),
          ),
        ],
      ),
    );
  }
}

// ─── Status bar ───────────────────────────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  final SimulatorController ctrl;
  const _StatusBar({required this.ctrl});

  Color get _statusColor {
    switch (ctrl.tripStatus) {
      case 'Requested':
        return const Color(0xFFFFB300);
      case 'Accepted':
        return const Color(0xFF00C853);
      case 'Started':
        return const Color(0xFF2196F3);
      case 'Completed':
        return const Color(0xFF9C27B0);
      case 'Cancelled':
      case 'Failed':
        return const Color(0xFFFF5252);
      default:
        return const Color(0xFF666666);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _dot(
                ctrl.hubConnected
                    ? const Color(0xFF00C853)
                    : const Color(0xFF666666),
              ),
              const SizedBox(width: 8),
              Text(
                ctrl.hubConnected ? 'Hub Connected' : 'Hub Disconnected',
                style: TextStyle(
                  color: ctrl.hubConnected
                      ? const Color(0xFF00C853)
                      : const Color(0xFF666666),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  ctrl.tripStatus,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (ctrl.tripId != null) ...[
            const SizedBox(height: 6),
            _row('Trip ID', ctrl.tripId!),
          ],
          if (ctrl.assignedDriverId != null) ...[
            const SizedBox(height: 4),
            _row('Driver', ctrl.assignedDriverId!),
          ],
          if (ctrl.driverLat != null && ctrl.driverLng != null) ...[
            const SizedBox(height: 4),
            _row(
              'Driver Loc',
              '${ctrl.driverLat!.toStringAsFixed(5)}, ${ctrl.driverLng!.toStringAsFixed(5)}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );

  Widget _row(String label, String value) => Row(
    children: [
      Text(
        '$label: ',
        style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            color: Color(0xFFCCCCCC),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

// ─── Action row ───────────────────────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
  final SimulatorController ctrl;
  const _ActionRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _Btn(
            label: 'Connect Hub',
            icon: Icons.wifi,
            color: const Color(0xFF00C853),
            enabled: !ctrl.hubConnected && !ctrl.busy,
            onTap: ctrl.connectHub,
          ),
          const SizedBox(width: 8),
          _Btn(
            label: 'Create Trip',
            icon: Icons.local_taxi,
            color: const Color(0xFFFFD700),
            enabled: ctrl.hubConnected && ctrl.tripId == null && !ctrl.busy,
            onTap: ctrl.createTrip,
          ),
          const SizedBox(width: 8),
          _Btn(
            label: 'Leave Trip',
            icon: Icons.exit_to_app,
            color: const Color(0xFFFF5252),
            enabled: ctrl.tripId != null && !ctrl.busy,
            onTap: ctrl.leaveTrip,
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;
  const _Btn({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: enabled ? color.withOpacity(0.15) : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled ? color.withOpacity(0.5) : const Color(0xFF2A2A2A),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: enabled ? color : const Color(0xFF444444),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: enabled ? color : const Color(0xFF444444),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Log console ──────────────────────────────────────────────────────────────
class _LogConsole extends StatelessWidget {
  final SimulatorController ctrl;
  final ScrollController scroll;
  const _LogConsole({required this.ctrl, required this.scroll});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Icon(Icons.terminal, size: 14, color: Color(0xFF666666)),
                const SizedBox(width: 6),
                const Text(
                  'EVENT LOG',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${ctrl.logs.length} entries',
                  style: const TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1A1A1A)),
          Expanded(
            child: ctrl.logs.isEmpty
                ? const Center(
                    child: Text(
                      'No events yet',
                      style: TextStyle(color: Color(0xFF444444), fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    controller: scroll,
                    padding: const EdgeInsets.all(8),
                    itemCount: ctrl.logs.length,
                    itemBuilder: (_, i) => _LogLine(entry: ctrl.logs[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LogLine extends StatelessWidget {
  final LogEntry entry;
  const _LogLine({required this.entry});

  Color get _color {
    switch (entry.type) {
      case LogType.success:
        return const Color(0xFF00C853);
      case LogType.error:
        return const Color(0xFFFF5252);
      case LogType.event:
        return const Color(0xFFFFD700);
      case LogType.system:
        return const Color(0xFF888888);
      case LogType.raw:
        return const Color(0xFF4FC3F7);
      case LogType.detail:
        return const Color(0xFF80CBC4);
      default:
        return const Color(0xFFCCCCCC);
    }
  }

  String get _prefix {
    switch (entry.type) {
      case LogType.success:
        return '✓';
      case LogType.error:
        return '✗';
      case LogType.event:
        return '◈';
      case LogType.system:
        return '·';
      default:
        return ' ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = entry.time;
    final ts =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ts,
            style: const TextStyle(
              color: Color(0xFF444444),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 6),
          Text(_prefix, style: TextStyle(color: _color, fontSize: 11)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              entry.message,
              style: TextStyle(
                color: _color,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
