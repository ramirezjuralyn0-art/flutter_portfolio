import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkMonitorService {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final StreamController<ConnectivityResult> _networkController =
      StreamController<ConnectivityResult>.broadcast();

  Stream<ConnectivityResult> get networkStream =>
      _networkController.stream;

  ConnectivityResult currentNetwork = ConnectivityResult.none;

  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;

      currentNetwork = result;
      _networkController.add(result);
    });
  }

  Future<ConnectivityResult> checkCurrentNetwork() async {
    final results = await _connectivity.checkConnectivity();

    final result = results.isNotEmpty
        ? results.first
        : ConnectivityResult.none;

    currentNetwork = result;

    return result;
  }

  void dispose() {
    _subscription?.cancel();
    _networkController.close();
  }
}