// lib/utils/sun_time_util.dart

import 'dart:math';

class SunTimeUtil {
  static DateTime calculateSunrise(DateTime date, double latitude, double longitude) {
    return _calculateSunTime(date, latitude, longitude, true);
  }

  static DateTime calculateSunset(DateTime date, double latitude, double longitude) {
    return _calculateSunTime(date, latitude, longitude, false);
  }

  static DateTime _calculateSunTime(DateTime date, double latitude, double longitude, bool isSunrise) {
    // Based on NOAA's sunrise/sunset algorithm

    int year = date.year;
    int month = date.month;
    int day = date.day;

    double zenith = 90.833333; // official zenith for sunrise/sunset

    double D2R = pi / 180;
    double R2D = 180 / pi;

    // 1. First calculate the day of the year
    int N1 = (275 * month / 9).floor();
    int N2 = ((month + 9) / 12).floor();
    int N3 = (1 + ((year - 4 * (year / 4).floor() + 2) / 3)).floor();
    int N = N1 - (N2 * N3) + day - 30;

    // 2. Convert the longitude to hour value and calculate an approximate time
    double lngHour = longitude / 15;

    double t;
    if (isSunrise) {
      t = N + ((6 - lngHour) / 24);
    } else {
      t = N + ((18 - lngHour) / 24);
    }

    // 3. Calculate the Sun's mean anomaly
    double M = (0.9856 * t) - 3.289;

    // 4. Calculate the Sun's true longitude
    double L = M + (1.916 * sin(D2R * M)) + (0.020 * sin(2 * D2R * M)) + 282.634;
    L = _normalizeDegrees(L);

    // 5a. Calculate the Sun's right ascension
    double RA = R2D * atan(0.91764 * tan(D2R * L));
    RA = _normalizeDegrees(RA);

    // 5b. Right ascension value needs to be in the same quadrant as L
    int Lquadrant = (L / 90).floor() * 90;
    int RAquadrant = (RA / 90).floor() * 90;
    RA = RA + (Lquadrant - RAquadrant);

    // 5c. Right ascension value needs to be converted into hours
    RA = RA / 15;

    // 6. Calculate the Sun's declination
    double sinDec = 0.39782 * sin(D2R * L);
    double cosDec = cos(asin(sinDec));

    // 7a. Calculate the Sun's local hour angle
    double cosH = (cos(D2R * zenith) - (sinDec * sin(D2R * latitude))) / (cosDec * cos(D2R * latitude));

    if (cosH > 1) {
      // The sun never rises on this location on the specified date
      return DateTime.utc(date.year, date.month, date.day, 23, 59);
    }
    if (cosH < -1) {
      // The sun never sets on this location on the specified date
      return DateTime.utc(date.year, date.month, date.day, 0, 0);
    }

    // 7b. Calculate the hour angle H
    double H;
    if (isSunrise) {
      H = 360 - R2D * acos(cosH);
    } else {
      H = R2D * acos(cosH);
    }
    H = H / 15;

    // 8. Calculate local mean time of rising/setting
    double T = H + RA - (0.06571 * t) - 6.622;

    // 9. Adjust back to UTC
    double UT = T - lngHour;
    UT = _normalizeHours(UT);

    // 10. Convert UT value to local time zone of the date
    // For simplicity, assuming the device time zone offset in hours
    double localT = UT; // This is still in UTC
    localT = _normalizeHours(localT);

    int hour = localT.floor();
    int minute = ((localT - hour) * 60).floor();

    return DateTime.utc(date.year, date.month, date.day, hour, minute);
  }

  static double _normalizeDegrees(double deg) {
    deg = deg % 360;
    if (deg < 0) deg += 360;
    return deg;
  }

  static double _normalizeHours(double hour) {
    hour = hour % 24;
    if (hour < 0) hour += 24;
    return hour;
  }
}
