class ApiEndpoint {
  static const String baseUrl = 'http://10.10.7.85:14040';

  static const String login = '$baseUrl/api/auth/login/';
  static const String forgetPassword = '$baseUrl/api/auth/forgot-password/';
  static const String verifyOtp = '$baseUrl/api/auth/verify_code/';
  static const String changePassword = '$baseUrl/api/auth/set_new_password/';
}
