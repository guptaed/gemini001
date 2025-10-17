import 'package:logger/logger.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,          // Number of method calls to show
    errorMethodCount: 8,     // More stack trace for errors
    colors: true,            // Colorful output
    printEmojis: true,       // Add emojis (e.g., 🔥 for errors)
  ),
);
