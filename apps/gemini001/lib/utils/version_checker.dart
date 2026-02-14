import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gemini001/utils/logging.dart';

// Conditional import for web
import 'version_checker_stub.dart'
    if (dart.library.html) 'version_checker_web.dart' as platform;

/// Utility class to check for app version updates on web.
/// Periodically fetches version.json and notifies users if a new version is available.
class VersionChecker {
  static final VersionChecker _instance = VersionChecker._internal();
  factory VersionChecker() => _instance;
  VersionChecker._internal();

  Timer? _timer;
  String? _currentBuildNumber;
  bool _updateAvailable = false;
  BuildContext? _context;

  /// Initialize the version checker with the current build number.
  /// Call this once when the app starts.
  void initialize({
    required String currentBuildNumber,
    Duration checkInterval = const Duration(minutes: 5),
  }) {
    // Only run on web
    if (!kIsWeb) return;

    _currentBuildNumber = currentBuildNumber;

    // Start periodic check
    _timer?.cancel();
    _timer = Timer.periodic(checkInterval, (_) => _checkForUpdate());

    // Also check immediately after a short delay
    Future.delayed(const Duration(seconds: 10), _checkForUpdate);

    logger.i('VersionChecker initialized. Current build: $currentBuildNumber');
  }

  /// Set the context for showing dialogs.
  /// Call this from your main app widget.
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Stop the version checker.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if an update is available.
  bool get isUpdateAvailable => _updateAvailable;

  /// Manually trigger an update check.
  Future<bool> checkForUpdate() async {
    return _checkForUpdate();
  }

  Future<bool> _checkForUpdate() async {
    if (!kIsWeb || _currentBuildNumber == null) return false;

    try {
      final data = await platform.fetchVersionJson();
      if (data != null) {
        final serverBuildNumber = data['build_number']?.toString() ?? '';

        if (serverBuildNumber.isNotEmpty &&
            serverBuildNumber != _currentBuildNumber &&
            !_updateAvailable) {
          _updateAvailable = true;
          logger.i('New version available! Current: $_currentBuildNumber, Server: $serverBuildNumber');
          _showUpdateDialog();
          return true;
        }
      }
    } catch (e) {
      // Silently fail - don't want to bother users with version check errors
      logger.d('Version check failed: $e');
    }
    return false;
  }

  void _showUpdateDialog() {
    final context = _context;
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Colors.blue),
            SizedBox(width: 8),
            Text('Update Available'),
          ],
        ),
        content: const Text(
          'A new version of the application is available. '
          'Please refresh the page to get the latest features and improvements.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              platform.hardRefresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Now'),
          ),
        ],
      ),
    );
  }
}
