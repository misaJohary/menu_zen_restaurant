import 'dart:async';

import 'package:domain/services/connectivity_service.dart';
import 'package:flutter/material.dart';

import '../../core/di/dependencies_injection.dart';

/// Persistent material banner that surfaces "you're offline" when the
/// connectivity service reports no internet. Mount once near the top of the
/// widget tree (under `MaterialApp.router`'s `builder`).
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  late final ConnectivityService _service;
  StreamSubscription<bool>? _sub;
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _service = getIt<ConnectivityService>();
    _sub = _service.onlineStream.listen(_handleStatus);
    // Seed the initial state.
    _service.isOnline().then((value) {
      if (mounted) _handleStatus(value);
    });
  }

  void _handleStatus(bool value) {
    if (!mounted || _online == value) return;
    setState(() => _online = value);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _retry() async {
    final online = await _service.isOnline();
    if (!mounted) return;
    if (online) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text("You're back online.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_online)
          Material(
            color: Theme.of(context).colorScheme.errorContainer,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "You're offline. Showing cached data.",
                      ),
                    ),
                    TextButton(
                      onPressed: _retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
