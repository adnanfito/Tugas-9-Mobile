class ApiUrl {
  static const String baseUrl = 'http://localhost:3000';

  // Member
  static const String registrasi = '$baseUrl/member/registrasi';
  static const String login = '$baseUrl/member/login';

  // Produk
  static const String listProduk = '$baseUrl/produk';
  static const String createProduk = '$baseUrl/produk';

  static String updateProduk(int id) => '$baseUrl/produk/$id/update';
  static String showProduk(int id) => '$baseUrl/produk/$id';
  static String deleteProduk(int id) => '$baseUrl/produk/$id';
}
