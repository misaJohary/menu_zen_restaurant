import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:domain/services/connectivity_service.dart';

import '../config/base_url_config.dart';

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl({
    Connectivity? connectivity,
    Dio? probeClient,
    Duration probeTimeout = const Duration(seconds: 3),
  })  : _connectivity = connectivity ?? Connectivity(),
        _probeClient = probeClient ?? _defaultProbeClient(probeTimeout),
        _controller = StreamController<bool>.broadcast() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final online = await _evaluate(results);
      if (_lastEmitted != online) {
        _lastEmitted = online;
        _controller.add(online);
      }
    });
  }

  static Dio _defaultProbeClient(Duration timeout) {
    return Dio(
      BaseOptions(
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
      ),
    );
  }

  final Connectivity _connectivity;
  final Dio _probeClient;
  final StreamController<bool> _controller;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool? _lastEmitted;

  @override
  Stream<bool> get onlineStream => _controller.stream;

  @override
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    final online = await _evaluate(results);
    if (_lastEmitted != online) {
      _lastEmitted = online;
      _controller.add(online);
    }
    return online;
  }

  Future<bool> _evaluate(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return false;
    }
    // Raw connectivity says "yes" — that's the ground truth. The probe
    // only ever flips us to offline if the server is *definitely* reachable
    // and saying no (which we cannot prove from a HEAD failure). Probe
    // results are advisory: a timeout or DNS hiccup on a real network
    // would otherwise produce false-offline UX.
    final probed = await _probe();
    return probed ?? true;
  }

  /// Returns `true` when the probe succeeds, `false` when the host actively
  /// refuses, and `null` when the result is inconclusive (timeout, DNS
  /// error, no base URL). The caller should treat `null` as "trust raw
  /// connectivity".
  Future<bool?> _probe() async {
    final base = BaseUrlConfig.current;
    if (base.isEmpty) return null;
    try {
      final response = await _probeClient.head<void>(
        '$base/health',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return response.statusCode != null && response.statusCode! < 500;
    } on DioException catch (e) {
      // Connection-level failures are inconclusive — could be a slow
      // network, not necessarily a dead one.
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.unknown) {
        return null;
      }
      return false;
    } catch (_) {
      return null;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
