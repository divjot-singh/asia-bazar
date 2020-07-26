
import 'package:asia/l10n/l10n.dart';
import 'package:intl/intl.dart';

/*
usage
var startDate = DateFormatter.formatWithTime(date);
date in seconds

*/

class DateFormatter {
  static formatWithTime(String epoch) {
    DateTime dateObj = DateTime.fromMillisecondsSinceEpoch(int.parse(epoch)).toLocal();
    var date = DateFormat('dd MMM, yyyy').add_jm().format(dateObj);
    return date;
  }

  static isPast(String epoch) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(epoch) * 1000)
            .compareTo(DateTime.now()) <
        0;
  }

  static Map findDifferenceMilliSeconds(int epoch1, int epoch2) {
    double seconds = 0, miliseconds = 0, minutes = 0, hours = 0, days = 0;
    var diff = (epoch1 - epoch2).abs();
    miliseconds = diff.toDouble();
    if (miliseconds > 1000) {
      seconds = (miliseconds / 1000).floor().toDouble();
      miliseconds = miliseconds % 1000;
    }
    if (seconds > 60) {
      minutes = (seconds / 60).floor().toDouble();
      seconds = seconds % 60;
    }
    if (minutes > 60) {
      hours = (minutes / 60).floor().toDouble();
      minutes = minutes % 60;
    }
    if (hours > 24) {
      days = (hours / 24).floor().toDouble();
      hours = hours % 60;
    }
    return {
      'seconds': seconds,
      'minutes': minutes,
      'miliseconds': miliseconds,
      'days': days,
      'hours': hours,
    };
  }

  static isToday(String epoch) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(epoch) * 1000)
            .difference(DateTime.now())
            .inDays ==
        0;
  }

  static getTime(String epoch) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(int.parse(epoch)).toLocal();
    String hour =
        date.hour > 12 ? (date.hour - 12).toString() : date.hour.toString();
    if (hour.length == 1) {
      hour = '0' + hour;
    }
    String minutes = date.minute.toString();
    if (minutes.length == 1) {
      minutes = '0' + minutes;
    }
    String amPm = date.hour >= 12 ? 'PM' : 'AM';
    return hour + ':' + minutes + ' ' + amPm;
  }

  static readableDelta(String epoch) {
    String formattedDelta = '';

    int delta = DateTime.now()
        .difference(
            DateTime.fromMillisecondsSinceEpoch(int.parse(epoch) * 1000))
        .inSeconds;

    const Map stringIds = {
      'now': 'time.now',
      'minute': 'time.minute',
      'minutes': 'time.minutes',
      'hour': 'time.hour',
      'hours': 'time.hours',
      'day': 'time.day',
      'days': 'time.days',
    };

    String type;
    int n;

    if (delta == 0)
      type = 'now';
    else if (delta > 0 && delta < 60) {
      type = 'now';
      n = delta;
    } else if (delta >= 60 && delta < 3600) {
      type = 'minute';
      n = (delta / 60).round();
    } else if (delta >= 3600 && delta < 3600 * 24) {
      type = 'hour';
      n = (delta / 3600).round();
    } else if (delta >= 3600 * 24) {
      type = 'day';
      n = (delta / (3600 * 24)).round();
    }

    if (n != 1 && type != 'now' && type != null) type += 's'; // handle plural

    String stringId = stringIds[type];
    if (type == 'now') stringId = stringIds['now'];

    formattedDelta = L10n().getStr(stringId, {'n': n.toString()});
    return formattedDelta;
  }
}
