import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';
import 'location.dart';
import 'geocoding_helper.dart';
import '../utils/sun_time_util.dart';
import 'sun_cache.dart';

class AlarmCreationHelper {
  /// Creates a sunrise or sunset alarm
  static Future<AlarmModel?> createSunriseSunsetAlarm({
    required AlarmType type,
    required int beforeAfterMinutes,
    required bool isBefore,
  }) async {
    try {
      // 1️⃣ Get current location
      final position = await getCurrentLocation();
      if (position == null) {
        log('⚠️ Could not fetch GPS position');
        return null;
      }

      final now = DateTime.now();

      // 2️⃣ Try cache first
      final cached = await SunCache.get(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      DateTime sunTime;

      if (cached != null) {
        // Use cached sunrise/sunset
        sunTime = type == AlarmType.sunrise
            ? DateTime.parse(cached['sunrise'])
            : DateTime.parse(cached['sunset']);
        log('⚡ Using cached sun time');
      } else {
        // 3️⃣ Calculate in isolate if not cached
        final params = _SunCalcParams(
          type: type,
          now: now,
          latitude: position.latitude,
          longitude: position.longitude,
          beforeAfterMinutes: beforeAfterMinutes,
          isBefore: isBefore,
        );

        sunTime = await compute<_SunCalcParams, DateTime?>(
          _calculateSunTimeIsolate,
          params,
        ) ??
            now;

        // 4️⃣ Cache both sunrise & sunset for today
        final sunrise =
        SunTimeUtil.calculateSunrise(now, position.latitude, position.longitude);
        final sunset =
        SunTimeUtil.calculateSunset(now, position.latitude, position.longitude);

        await SunCache.save(
          latitude: position.latitude,
          longitude: position.longitude,
          sunrise: sunrise,
          sunset: sunset,
        );
      }

      // 5️⃣ Apply offset if not already applied
      if (!_isOffsetApplied(cached, type, isBefore, beforeAfterMinutes)) {
        sunTime = isBefore
            ? sunTime.subtract(Duration(minutes: beforeAfterMinutes))
            : sunTime.add(Duration(minutes: beforeAfterMinutes));
      }
      String? city = await getCityFromPosition(position.latitude, position.longitude);

      // 6️⃣ Build and return the alarm
      return AlarmModel(
        id: const Uuid().v4(),
        time: sunTime,
        type: type,
        label: "${type == AlarmType.sunrise ? "Sunrise" : "Sunset"}"
            "${isBefore ? " - Before" : " - After"} "
            "$beforeAfterMinutes"
            "min"
            "${city != null ? " @$city" : ""}",
        musicAppLink: null,
        isActive: true,
        repeatDays: const {},
        beforeAfterMinutes: beforeAfterMinutes,
        isBefore: isBefore,
      );
    } catch (e, st) {
      log('❌ Error in AlarmCreationHelper: $e\n$st');
      return null;
    }
  }

  /// Checks if cached time already has the offset applied
  static bool _isOffsetApplied(
      Map<String, dynamic>? cached,
      AlarmType type,
      bool isBefore,
      int offsetMinutes,
      ) {
    // Currently offsets are always applied, could improve later
    return false;
  }
}

/// ------------------------------------------------------------
/// Internal helper for isolate calculation
/// ------------------------------------------------------------
class _SunCalcParams {
  final AlarmType type;
  final DateTime now;
  final double latitude;
  final double longitude;
  final int beforeAfterMinutes;
  final bool isBefore;

  const _SunCalcParams({
    required this.type,
    required this.now,
    required this.latitude,
    required this.longitude,
    required this.beforeAfterMinutes,
    required this.isBefore,
  });
}

/// Calculates sunrise/sunset in a background isolate
Future<DateTime?> _calculateSunTimeIsolate(_SunCalcParams params) async {
  try {
    DateTime sunTime;

    if (params.type == AlarmType.sunrise) {
      sunTime = SunTimeUtil.calculateSunrise(
        params.now,
        params.latitude,
        params.longitude,
      );
      // If sunrise already passed today, get tomorrow's sunrise
      if (sunTime.isBefore(params.now)) {
        sunTime = SunTimeUtil.calculateSunrise(
          params.now.add(const Duration(days: 1)),
          params.latitude,
          params.longitude,
        );
      }
    } else {
      sunTime = SunTimeUtil.calculateSunset(
        params.now,
        params.latitude,
        params.longitude,
      );
      // If sunset already passed today, get tomorrow's sunset
      if (sunTime.isBefore(params.now)) {
        sunTime = SunTimeUtil.calculateSunset(
          params.now.add(const Duration(days: 1)),
          params.latitude,
          params.longitude,
        );
      }
    }

    // Apply offset
    sunTime = params.isBefore
        ? sunTime.subtract(Duration(minutes: params.beforeAfterMinutes))
        : sunTime.add(Duration(minutes: params.beforeAfterMinutes));

    return sunTime.toLocal();
  } catch (e) {
    log('❌ Error in _calculateSunTimeIsolate: $e');
    return null;
  }
}
