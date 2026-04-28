import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/apis/api_constants/api_key_constants.dart';

class NotificationForNavBarController extends GetxController {
  final count = 0.obs;

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
    SharedPreferences sp = await SharedPreferences.getInstance();
    userId = sp.getString(ApiKeyConstants.userId) ?? '';
    await getCurrentLocation();
  }



  // ── Location ───────────────────────────────────────────────────────────────

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Fall back to a default or just call API without coords
      await fetchNotifications(lat: '', lon: '');
    } else {
      Position pos = await Geolocator.getCurrentPosition();
      lat.value = pos.latitude.toString();
      lon.value = pos.longitude.toString();
      await fetchNotifications(lat: lat.value, lon: lon.value);
    }
  }

  // ── API ────────────────────────────────────────────────────────────────────

  Future<void> fetchNotifications({
    required String lat,
    required String lon,
  }) async {
    inAsyncCall.value = true;
    errorMsg.value = '';

    try {
      final uri = Uri.parse(
        'https://python.aitechnotech.in/skypeanut-api/api/v1/user-notifications'
            '?lat=$lat&lon=$lon&user_id=$userId',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final model = NotificationModel.fromJson(json);

        if (model.status == '1' || model.notifications != null) {
          notifications.assignAll(model.notifications ?? []);
          unreadCount.value = model.unreadCount ?? 0;
        } else {
          errorMsg.value = model.message ?? 'No notifications found.';
          notifications.clear();
        }
      } else {
        errorMsg.value = 'Server error (${response.statusCode})';
        notifications.clear();
      }
    } catch (e) {
      errorMsg.value = 'Failed to load notifications.';
      print('Notification fetch error: $e');
      notifications.clear();
    }

    inAsyncCall.value = false;
  }

  /// Mark a single notification as read locally
  void markRead(String? id) {
    if (id == null) return;
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && notifications[idx].read == false) {
      notifications[idx].read = true;
      notifications.refresh();
      if (unreadCount.value > 0) unreadCount.value--;
    }
  }

  /// Mark all as read locally
  void markAllRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
  }

  /// Refresh
  @override
  Future<void> refresh() async {
    await fetchNotifications(lat: lat.value, lon: lon.value);
  }

  void increment() => count.value++;
}


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
    status = json['status'];
    message = json['message'];
    count = json['count'];
    unreadCount = json['unread_count'];
    if (json['notifications'] != null) {
      notifications = <NotificationItem>[];
      json['notifications'].forEach((v) {
        notifications!.add(NotificationItem.fromJson(v));
      });
    }
    generatedAt = json['generated_at'];
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
    id = json['id'];
    type = json['type'];
    category = json['category'];
    title = json['title'];
    message = json['message'];
    severity = json['severity'];
    data = json['data'] != null
        ? Map<String, dynamic>.from(json['data'])
        : null;
    timestamp = json['timestamp'];
    read = json['read'];
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