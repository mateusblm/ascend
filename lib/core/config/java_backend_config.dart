class JavaBackendConfig {
  const JavaBackendConfig._();

  static const String baseUrl = String.fromEnvironment(
    'ASCEND_JAVA_BACKEND_URL',
    defaultValue: '',
  );

  static bool get isEnabled => baseUrl.trim().isNotEmpty;
}
