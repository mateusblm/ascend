class ReleaseContactConfig {
  const ReleaseContactConfig._();

  static const String supportEmail = String.fromEnvironment(
    'ASCEND_SUPPORT_EMAIL',
    defaultValue: 'support@ascend.app',
  );

  static const String supportChannelLabel = String.fromEnvironment(
    'ASCEND_SUPPORT_LABEL',
    defaultValue: 'Email de suporte',
  );

  static bool get usesPlaceholderSupport =>
      supportEmail.trim().toLowerCase() == 'support@ascend.app';
}
