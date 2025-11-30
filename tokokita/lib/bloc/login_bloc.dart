import 'dart:convert';
import 'package:tokokita/helpers/api.dart';
import 'package:tokokita/helpers/api_url.dart';
import 'package:tokokita/model/login.dart';

class LoginBloc {
  static Future<Login> login({String? email, String? password}) async {
    try {
      String apiUrl = ApiUrl.login;
      var body = {"email": email, "password": password};

      var response = await Api().post(apiUrl, body);

      print('Login Status: ${response.statusCode}');
      print('Login Response: ${response.body}');

      // ✅ Cek status code
      if (response.statusCode != 200) {
        throw Exception('Login failed with status ${response.statusCode}');
      }

      // ✅ Parse JSON dengan error handling
      var jsonObj = json.decode(response.body);

      // ✅ Cek apakah response memiliki struktur yang diharapkan
      if (jsonObj == null) {
        throw Exception('Invalid response format');
      }

      return Login.fromJson(jsonObj);
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
