class Login {
  int? code;
  bool? status;
  String? message;
  String? token;
  String? userID;

  Login({this.code, this.status, this.message, this.token, this.userID});

  factory Login.fromJson(Map<String, dynamic> json) {
    print('🟠 [Login Model] Parsing: $json');

    // ✅ Ambil token dari data.token
    String? token = json['data']?['token'] as String?;
    String? userID = json['data']?['user']?['id']?.toString();

    print('🟠 [Login Model] Token: $token');
    print('🟠 [Login Model] UserID: $userID');

    return Login(
      code: json['code'] as int? ?? 200,
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      token: token ?? '',
      userID: userID ?? '',
    );
  }
}
