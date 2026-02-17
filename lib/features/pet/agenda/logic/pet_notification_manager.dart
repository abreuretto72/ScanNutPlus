import 'package:flutter/foundation.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';

class PetNotificationManager {
  static final PetNotificationManager _instance = PetNotificationManager._internal();

  factory PetNotificationManager() {
    return _instance;
  }

  PetNotificationManager._internal();

  /// Schedules a notification for a pet event based on the lead time.
  /// 
  /// [leadTime] example: "1h", "1d", "none"
  Future<void> scheduleNotification(PetEvent event, String leadTime) async {
    if (leadTime == 'none') return;

    DateTime? notificationTime;
    final start = event.startDateTime;

    switch (leadTime) {
      case '1h':
        notificationTime = start.subtract(const Duration(hours: 1));
        break;
      case '2h':
        notificationTime = start.subtract(const Duration(hours: 2));
        break;
      case '1d':
        notificationTime = start.subtract(const Duration(days: 1));
        break;
      case '2d':
        notificationTime = start.subtract(const Duration(days: 2));
        break;
      case '1w':
        notificationTime = start.subtract(const Duration(days: 7));
        break;
      default:
        // Handle unknown or custom times if needed
        return;
    }

    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint('[PetNotificationManager] Notification time $notificationTime is in the past. Skipping.');
      return;
    }

    // TODO: Integrate flutter_local_notifications here
    debugPrint('[PetNotificationManager] MOCK SCHEDULE: Notification for "${event.metrics?['custom_title']}" at $notificationTime (Event: $start)');
  }

  /// Cancels a notification for a specific event ID.
  Future<void> cancelNotification(String eventId) async {
    // TODO: Integrate flutter_local_notifications cancel
    debugPrint('[PetNotificationManager] MOCK CANCEL: Notification for event $eventId');
  }
}
