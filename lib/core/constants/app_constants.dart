class AppConstants {
  const AppConstants._();

  // App
  static const String appName = 'Rebill POS';
  static const String appVersion = '1.0.0';

  // Base URL
  static const String baseUrl =
      'https://document-permalink-german-enrollment.trycloudflare.com/';

  // Service URL
  static const String service = 'pos/';
  static const String apiVersion = 'v1/';
  static const String authOwnerPath = 'auth/owner';

  // Login URL
  static const String loginUrl =
      '$baseUrl$service$apiVersion$authOwnerPath/login';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // Routes
  static const String homeRoute = '/';
  static const String loginPage = '/login';
}
