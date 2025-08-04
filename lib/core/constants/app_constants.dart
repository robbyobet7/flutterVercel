class AppConstants {
  const AppConstants._();

  // App
  static const String appName = 'Rebill POS';
  static const String appVersion = '1.0.0';

  // Base URL
  static const String baseUrl =
      'https://cradle-suffered-loan-arise.trycloudflare.com/';

  // Service URL
  static const String service = 'pos/';
  static const String apiVersion = 'v1/';
  static const String authOwnerPath = 'auth/owner';

  // Login URL
  static const String loginUrl =
      '$baseUrl$service$apiVersion$authOwnerPath/login';

  // Refresh Token URL
  static const String refreshTokenUrl =
      '$baseUrl$service$apiVersion$authOwnerPath/refresh-token';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';

  // Routes
  static const String homeRoute = '/';
  static const String loginPage = '/login';
}
