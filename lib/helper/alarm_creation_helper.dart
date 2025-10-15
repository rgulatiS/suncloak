import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';
import 'location.dart'; // your helper to get GPS location
import '../utils/sun_time_util.dart'; // your sunrise/sunset calculation utility

class AlarmCreationHelper {
  static Future<AlarmModel?> createSunriseSunsetAlarm({
    required AlarmType type,              // AlarmType.sunrise or AlarmType.sunset
    required int beforeAfterMinutes,      // offset in minutes
    required bool isBefore,                // true if "before" sunrise/sunset, false if "after"
  }) async {
    final position = await getCurrentLocation(); // Should return Position with latitude & longitude

    if (position == null) {
      // If location unavailable, you can either return null or handle fallback here
      return null;
    }

    DateTime now = DateTime.now();
    DateTime sunTime;

    print('Raw UTC sunrise: ${now}');
    print('Local sunrise: ${now.toLocal()}');

    if (type == AlarmType.sunrise) {
      // Calculate today's sunrise time
      sunTime = SunTimeUtil.calculateSunrise(now, position.latitude, position.longitude);

      // If sunrise already passed, get tomorrow's sunrise
      if (sunTime.isBefore(now)) {
        sunTime = SunTimeUtil.calculateSunrise(now.add(Duration(days: 1)), position.latitude, position.longitude);
      }
    } else {
      // Calculate today's sunset time
      sunTime = SunTimeUtil.calculateSunset(now, position.latitude, position.longitude);

      // If sunset already passed, get tomorrow's sunset
      if (sunTime.isBefore(now)) {
        sunTime = SunTimeUtil.calculateSunset(now.add(Duration(days: 1)), position.latitude, position.longitude);
      }
    }

    print('Raw UTC sunrise: ${sunTime}');
    print('Local sunrise: ${sunTime.toLocal()}');

    sunTime = sunTime.toLocal(); // Convert to local time

    // Apply before or after offset
    if (isBefore) {
      sunTime = sunTime.subtract(Duration(minutes: beforeAfterMinutes));
    } else {
      sunTime = sunTime.add(Duration(minutes: beforeAfterMinutes));
    }

    // Create the alarm model with calculated time and other properties
    return AlarmModel(
      id: Uuid().v4(),
      time: sunTime,
      type: type,
      label: type == AlarmType.sunrise ? "Sunrise" : "Sunset",
      musicAppLink: null,
      isActive: true,
      repeatDays: const {}, // You can initialize repeat days as empty or based on user input
      beforeAfterMinutes: beforeAfterMinutes,
      isBefore: isBefore,
    );
  }
}
