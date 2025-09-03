class AppConstants {
  const AppConstants._();

  // App
  static const String appName = 'Rebill POS';
  static const String appVersion = '1.0.0';

  // Base URL
  static const String baseUrl =
      'https://turkey-cleaning-professionals-price.trycloudflare.com';

  // Service URL
  static const String service = '/pos/';
  static const String apiVersion = 'v1/';
  static const String auth = 'auth';
  static const String authOwnerPath = 'auth/owner';
  static const String authStaffPath = 'auth/staff';
  static const String products = 'products';
  static const String bill = 'bill';
  static const String masterdata = 'masterdata';

  // Login Owner URL
  static const String loginUrl =
      '$baseUrl$service$apiVersion$authOwnerPath/login';

  // Auth Owner URL
  static const String authOwnerUrl =
      '$baseUrl$service$apiVersion$authOwnerPath/auth-check';

  // Refresh Token Owner URL
  static const String refreshTokenOwnerUrl =
      '$baseUrl$service$apiVersion$authOwnerPath/refresh-token';

  // Staff Login URL
  static const String staffLoginUrl =
      '$baseUrl$service$apiVersion$authStaffPath/login';

  // Auth Staff URL
  static const String authStaffUrl =
      '$baseUrl$service$apiVersion$authStaffPath/auth-check';

  // Refresh Token Staff URL
  static const String refreshTokenStaffUrl =
      '$baseUrl$service$apiVersion$authStaffPath/refresh-token';

  // Auth Check Me URL
  static const String authMeUrl = '$baseUrl$service$apiVersion$auth/me';

  // Staff Accounts URL
  static const String staffAccountUrl =
      '$baseUrl$service$apiVersion$masterdata/staff-accounts';

  // Customers URL
  static const String customerUrl =
      '$baseUrl$service$apiVersion$masterdata/customer-list';

  // Tables URL
  static const String tablesUrl =
      '$baseUrl$service$apiVersion$masterdata/tables';

  // Merchants URL
  static const String merchantsUrl =
      '$baseUrl$service$apiVersion$masterdata/all-merchant-channels';

  // Payments URL
  static const String paymentsUrl =
      '$baseUrl$service$apiVersion$masterdata/all-payment-methods';

  // Discounts URL
  static const String discountsUrl =
      '$baseUrl$service$apiVersion$masterdata/discounts-list';

  // Rewards URL
  static const String rewardsUrl =
      '$baseUrl$service$apiVersion$masterdata/rewards-list';

  // Product URL
  static const String productUrl =
      '$baseUrl$service$apiVersion$products/get-all';

  // Product Categories URL
  static const String productCategoriesUrl =
      '$baseUrl$service$apiVersion$products/get-all-product-categories';

  // Bill URL
  static const String billsUrl =
      '$baseUrl$service$apiVersion$bill/list?limit=3&offset=0';

  // Create Bill URL
  static const String createBillsUrl =
      '$baseUrl$service$apiVersion$bill/create';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String refreshTokenOwnerKey = 'refresh_token';

  // Staff Token Keys
  static const String authTokenStaffKey = 'auth_token_staff';
  static const String refreshTokenStaffKey = 'refresh_token_staff';

  // Cachce Keys
  static const String staffAccountsCacheKey = 'staff_accounts_cache';
  static const String staffAccountsCacheTimestampKey =
      'staff_accounts_cache_timestamp';

  // Routes
  static const String homeRoute = '/';
  static const String loginPage = '/login';
  static const String loginStaffPage = '/loginStaff';
  static const String ownerLoginSplashRoute = '/ownerLoginSplash';
}
