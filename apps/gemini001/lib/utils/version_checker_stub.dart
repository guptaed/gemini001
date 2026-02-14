// Stub implementation for non-web platforms.
// These functions do nothing on non-web platforms.

Future<Map<String, dynamic>?> fetchVersionJson() async {
  return null;
}

void hardRefresh() {
  // No-op on non-web platforms
}
