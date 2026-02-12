import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation for version checking.

Future<Map<String, dynamic>?> fetchVersionJson() async {
  try {
    // Add cache-busting parameter
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final request = await html.HttpRequest.request(
      '/version.json?t=$timestamp',
      method: 'GET',
    );

    if (request.status == 200) {
      return json.decode(request.responseText ?? '{}') as Map<String, dynamic>;
    }
  } catch (e) {
    // Silently fail
  }
  return null;
}

void hardRefresh() {
  // Force reload from server, bypassing cache
  html.window.location.reload();
}
