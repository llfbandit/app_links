/// Avoid io imports when on web platform
void registerProtocolHandler(
  String scheme, {
  String? executable,
  List<String>? arguments,
}) {}

/// Avoid io imports when on web platform
void unregisterProtocolHandler(String scheme) {}
