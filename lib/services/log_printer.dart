import 'package:logger/logger.dart';

Logger getLogger(String className) {
  return Logger(printer: SimpleLogPrinter(className));
}

class SimpleLogPrinter extends PrettyPrinter {
  final String className;
  SimpleLogPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    var color = PrettyPrinter.levelColors[event.level];
    var emoji = PrettyPrinter.levelEmojis[event.level];
    List<String> logMessages = [];
    if (event.message != null) {
      logMessages.add(color('$emoji $className - ${event.message}'));
    }
    if (event.stackTrace != null) {
      var formattedStackTrace = formatStackTrace(event.stackTrace, 4);
      logMessages.add(color('$formattedStackTrace'));
    }
    return logMessages;
  }
}
