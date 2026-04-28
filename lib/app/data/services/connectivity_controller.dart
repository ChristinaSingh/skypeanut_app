import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  // Observable for current connectivity status
  final RxList<ConnectivityResult> connectivityResults = <ConnectivityResult>[ConnectivityResult.none].obs;
  
  // Convenient helper to check if completely offline
  RxBool get isOffline => (connectivityResults.contains(ConnectivityResult.none) && connectivityResults.length == 1).obs;

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      print("Connectivity Init Error: $e");
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    connectivityResults.assignAll(results);
    print("Connectivity Status Changed: $results");
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
