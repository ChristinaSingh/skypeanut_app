import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreenController extends GetxController {
  // Location
  final RxString lat = ''.obs;
  final RxString lon = ''.obs;
  String userId = '';

  // Data
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool inAsyncCall = true.obs;
  final RxString errorMsg = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      userId = sp.getString('userId') ?? '28'; // fallback to 28

      print('🔹 UserID: $userId');

      await getCurrentLocation();
    } catch (e) {
      print('❌ Init error: $e');
      errorMsg.value = 'Initialization failed';
      inAsyncCall.value = false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('⚠️ Location permission denied, using default location');
        // Use default coordinates (Hayward)
        lat.value = '37.659198761';
        lon.value = '-122.12200164';
      } else {
        Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat.value = pos.latitude.toString();
        lon.value = pos.longitude.toString();
        print('📍 Location: ${lat.value}, ${lon.value}');
      }

      await fetchNotifications();
    } catch (e) {
      print('❌ Location error: $e');
      // Use default coordinates on error
      lat.value = '37.659198761';
      lon.value = '-122.12200164';
      await fetchNotifications();
    }
  }

  Future<void> fetchNotifications() async {
    inAsyncCall.value = true;
    errorMsg.value = '';

    try {
      final uri = Uri.parse(
        'https://python.aitechnotech.in/skypeanut-api/api/v1/user-notifications'
            '?lat=${lat.value}&lon=${lon.value}&user_id=$userId',
      );

      print('🌐 API URL: $uri');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final model = NotificationModel.fromJson(json);

        if (model.status == '1') {
          notifications.assignAll(model.notifications ?? []);
          unreadCount.value = model.unreadCount ?? 0;

          print('✅ Loaded ${notifications.length} notifications');
          print('📬 Unread count: ${unreadCount.value}');

          if (notifications.isEmpty) {
            errorMsg.value = 'No notifications available';
          }
        } else {
          errorMsg.value = model.message ?? 'No notifications found';
          notifications.clear();
          print('⚠️ API returned status: ${model.status}');
        }
      } else {
        errorMsg.value = 'Server error (${response.statusCode})';
        notifications.clear();
        print('❌ Server error: ${response.statusCode}');
      }
    } catch (e) {
      errorMsg.value = 'Failed to load notifications: $e';
      notifications.clear();
      print('❌ Fetch error: $e');
    } finally {
      inAsyncCall.value = false;
    }
  }

  void markRead(String? id) {
    if (id == null) return;
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && notifications[idx].read == false) {
      notifications[idx].read = true;
      notifications.refresh();
      if (unreadCount.value > 0) unreadCount.value--;
      print('✅ Marked notification $id as read');
    }
  }

  void markAllRead() {
    int count = 0;
    for (final n in notifications) {
      if (n.read == false) {
        n.read = true;
        count++;
      }
    }
    notifications.refresh();
    unreadCount.value = 0;
    print('✅ Marked $count notifications as read');
  }

  @override
  Future<void> refresh() async {
    print('🔄 Refreshing notifications...');
    await fetchNotifications();
  }
}

// ══════════════════════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════════════════════

class NotificationModel {
  String? status;
  String? message;
  int? count;
  int? unreadCount;
  List<NotificationItem>? notifications;
  String? generatedAt;

  NotificationModel({
    this.status,
    this.message,
    this.count,
    this.unreadCount,
    this.notifications,
    this.generatedAt,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();
    count = json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '0');
    unreadCount = json['unread_count'] is int ? json['unread_count'] : int.tryParse(json['unread_count']?.toString() ?? '0');

    if (json['notifications'] != null && json['notifications'] is List) {
      notifications = <NotificationItem>[];
      for (var v in json['notifications']) {
        try {
          notifications!.add(NotificationItem.fromJson(v));
        } catch (e) {
          print('Error parsing notification: $e');
        }
      }
    }

    generatedAt = json['generated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['count'] = count;
    data['unread_count'] = unreadCount;
    if (notifications != null) {
      data['notifications'] = notifications!.map((v) => v.toJson()).toList();
    }
    data['generated_at'] = generatedAt;
    return data;
  }
}

class NotificationItem {
  String? id;
  String? type;
  String? category;
  String? title;
  String? message;
  String? severity;
  Map<String, dynamic>? data;
  String? timestamp;
  bool? read;

  NotificationItem({
    this.id,
    this.type,
    this.category,
    this.title,
    this.message,
    this.severity,
    this.data,
    this.timestamp,
    this.read,
  });

  NotificationItem.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    type = json['type']?.toString();
    category = json['category']?.toString();
    title = json['title']?.toString();
    message = json['message']?.toString();
    severity = json['severity']?.toString();

    if (json['data'] != null && json['data'] is Map) {
      data = Map<String, dynamic>.from(json['data']);
    }

    timestamp = json['timestamp']?.toString();
    read = json['read'] == true || json['read'] == 'true';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['category'] = category;
    data['title'] = title;
    data['message'] = message;
    data['severity'] = severity;
    data['data'] = this.data;
    data['timestamp'] = timestamp;
    data['read'] = read;
    return data;
  }
}