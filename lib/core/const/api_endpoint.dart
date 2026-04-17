class ApiEndpoint {
  static const String baseUrl = 'https://violate.dsrt321.online';
  // static const String baseUrl = 'https://api.nextgen-careservices.co.uk';
  static const String wsBaseUrl = 'wss://violate.dsrt321.online';

  //Auth
  static const String login = '$baseUrl/api/auth/login/';
  static const String forgetPassword = '$baseUrl/api/auth/forgot-password/';
  static const String verifyOtp = '$baseUrl/api/auth/verify_code/';
  static const String changePassword = '$baseUrl/api/auth/set_new_password/';

  //Chat
  static const String getPromptList =
      '$baseUrl/api/services/prompt-templates/ai/';
  static const String chatbot = '$baseUrl/api/services/chat/';
  static const String chatWebSocket =
      '$baseUrl/api/services/chat/messages/files/';
  static const String chatSession = '$baseUrl/api/services/chat/sessions/';

  //Profile
  static const String profile = '$baseUrl/api/auth/user/details/';
  static const String deleteAccount = '$baseUrl/api/auth/account-delete/';

  //privacy policy
  static const String privacyPolicy =
      'https://sites.google.com/view/violet-app/home';

  // REST endpoint — file upload before sending a message
  static const String chatFileUpload =
      '$baseUrl/api/services/chat/messages/files/';

  // WebSocket base URL (token appended at connect time: ?token=<JWT>)
  static const String wsChat = '$wsBaseUrl/ws/chat/';
}
