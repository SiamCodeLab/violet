class ApiEndpoint {
  // static const String baseUrl = 'https://violate.dsrt321.online';
  static const String baseUrl = 'https://api.nextgen-careservices.co.uk';


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
}
