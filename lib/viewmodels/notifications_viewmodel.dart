import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/notification_item.dart';

class NotificationsViewModel extends ChangeNotifier {
  final _ref = FirebaseDatabase.instance.ref('notifications');

  StreamSubscription<DatabaseEvent>? _sub;
  List<NotificationItem> _notifications = const <NotificationItem>[];
  List<NotificationItem> get notifications => _notifications;

  NotificationsViewModel() {
    _listenNotifications();
  }

  void _listenNotifications() {
    _sub = _ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      _notifications = data == null
          ? const <NotificationItem>[]
          : data.values
              .map((v) =>
                  NotificationItem.fromJson(v as Map<dynamic, dynamic>))
              .toList()
            ..sort(
              (a, b) => b.timeAgo.compareTo(a.timeAgo),
            );

      notifyListeners();
    }, onError: (e) => debugPrint('Notifications error: $e'));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
