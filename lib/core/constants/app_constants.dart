class AppConstants {
  const AppConstants._();

  // App
  static const String appName = 'Rebill POS';
  static const String appVersion = '1.0.0';

  // Base URL
  static const String baseUrl =
      'https://objective-cole-benz-flame.trycloudflare.com/';

  // Service URL
  static const String service = 'pos/';
  static const String apiVersion = 'v1/';
  static const String authOwnerPath = 'auth/owner';
  static const String authStaffPath = 'auth/staff';
  static const String products = 'products';

  // Login URL
  static const String loginUrl =
      '$baseUrl$service$apiVersion$authOwnerPath/login';

  // Product URL
  static const String productUrl =
      '$baseUrl$service$apiVersion$products/get-all';

  // Refresh Token URL
  static const String refreshTokenUrl =
      '$baseUrl$service$apiVersion$authOwnerPath/refresh-token';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';

  // Staff Token Keys
  static const String authTokenStaffKey = 'auth_token_staff';
  static const String refreshTokenStaffKey = 'refresh_token_staff';

  // Staff Login URL
  static const String staffLoginUrl =
      '$baseUrl$service$apiVersion$authStaffPath/login';

  // Routes
  static const String homeRoute = '/';
  static const String loginPage = '/login';
  static const String loginStaffPage = '/loginStaff';
}
