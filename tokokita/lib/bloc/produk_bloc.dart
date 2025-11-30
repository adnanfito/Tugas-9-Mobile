import 'dart:convert';
import 'package:tokokita/helpers/api.dart';
import 'package:tokokita/helpers/api_url.dart';
import 'package:tokokita/model/produk.dart';

class ProdukBloc {
  static Future<List<Produk>> getProduks() async {
    try {
      String apiUrl = ApiUrl.listProduk;
      var response = await Api().get(apiUrl);

      print('🔵 Get Produks Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed to load products');
      }

      var jsonObj = json.decode(response.body);

      if (jsonObj == null || jsonObj is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      List<dynamic> listProduk = jsonObj['data'] ?? [];
      List<Produk> produks = [];

      for (var item in listProduk) {
        produks.add(Produk.fromJson(item as Map<String, dynamic>));
      }

      return produks;
    } catch (e) {
      print('🔴 Error getProduks: $e');
      rethrow;
    }
  }

  static Future<bool> addProduk({required Produk produk}) async {
    try {
      String apiUrl = ApiUrl.createProduk;

      var body = {
        "kode_produk": produk.kodeProduk ?? "",
        "nama_produk": produk.namaProduk ?? "",
        "harga": (produk.hargaProduk ?? 0).toString(),
      };

      print('🔵 [addProduk] URL: $apiUrl');
      print('🔵 [addProduk] Body: $body');

      var response = await Api().post(apiUrl, body);

      print('🟢 [addProduk] Status: ${response.statusCode}');
      print('🟢 [addProduk] Response: ${response.body}');

      // ✅ Accept 200 dan 201 sebagai success
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonObj = json.decode(response.body);
        print('🟡 [addProduk] Response parsed: $jsonObj');
        return true;
      } else {
        print('🔴 [addProduk] Error Status: ${response.statusCode}');
        print('🔴 [addProduk] Error Body: ${response.body}');

        try {
          var errorJson = json.decode(response.body);
          throw Exception('Error: ${errorJson['message'] ?? response.body}');
        } catch (e) {
          throw Exception(
            'Add produk failed with status ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('🔴 [addProduk] Error: $e');
      rethrow;
    }
  }

  static Future<bool> updateProduk({required Produk produk}) async {
    try {
      String apiUrl = ApiUrl.updateProduk(produk.id!);
      print('🔵 [updateProduk] URL: $apiUrl');

      var body = {
        "kode_produk": produk.kodeProduk,
        "nama_produk": produk.namaProduk,
        "harga": produk.hargaProduk.toString(),
      };

      print("🔵 [updateProduk] Body: $body");

      var response = await Api().put(apiUrl, jsonEncode(body));

      print('🟢 [updateProduk] Status: ${response.statusCode}');
      print('🟢 [updateProduk] Response: ${response.body}');

      // ✅ Accept 200 dan 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonObj = json.decode(response.body);
        return true;
      } else {
        throw Exception('Update produk failed');
      }
    } catch (e) {
      print('🔴 [updateProduk] Error: $e');
      rethrow;
    }
  }

  static Future<bool> deleteProduk({required int id}) async {
    try {
      String apiUrl = ApiUrl.deleteProduk(id);
      print('🔵 [deleteProduk] URL: $apiUrl');

      var response = await Api().delete(apiUrl);

      print('🟢 [deleteProduk] Status: ${response.statusCode}');
      print('🟢 [deleteProduk] Response: ${response.body}');

      // ✅ Accept 200, 201, dan 204
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Delete produk failed');
      }
    } catch (e) {
      print('🔴 [deleteProduk] Error: $e');
      rethrow;
    }
  }
}
