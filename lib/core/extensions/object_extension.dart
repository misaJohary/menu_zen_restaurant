import 'package:logger/logger.dart';

extension ObjectExtension on Object {
  void log([Level? level, Object? error, StackTrace? stackTrace]) {
    final logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        noBoxingByDefault: true,
      ),
    );

    logger.e(
      toString(),
      error: error,
      stackTrace: stackTrace,
    );
  }
}
