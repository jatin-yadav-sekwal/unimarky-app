/// Custom API exception — matches the web app's error handling in lib/api.ts.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  /// Check if this is an onboarding-required error from the backend.
  bool get isOnboardingRequired =>
      statusCode == 403 && message == 'ONBOARDING_REQUIRED';

  /// Check if this is an authentication error.
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
