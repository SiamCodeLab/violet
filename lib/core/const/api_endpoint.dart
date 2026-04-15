class ApiEndpoint {
  static const String baseUrl = 'http://10.10.7.76:14040'; 
  // static const String baseUrl = 'https://api.nextgen-careservices.co.uk';


  //Auth
  static const String login = '$baseUrl/api/auth/login/';
  static const String forgetPassword = '$baseUrl/api/auth/forgot-password/';
  static const String verifyOtp = '$baseUrl/api/auth/verify_code/';
  static const String changePassword = '$baseUrl/api/auth/set_new_password/';

  //Chat
  static const String getPromptList =
      '$baseUrl/api/services/prompt-templates/ai/';
  static const String chatbot = '$baseUrl/api/services/chat/';
  static const String chatSession = '$baseUrl/api/services/chat/sessions/';

  //Profile
  static const String profile = '$baseUrl/api/auth/user/details/';
  static const String deleteAccount = '$baseUrl/api/auth/account-delete/';

  //privacy policy
  static const String privacyPolicy = 'https://www.nextgen-careservices.com/privacy';
}
