class Produk {
  int? id;
  String? kodeProduk;
  String? namaProduk;
  int? hargaProduk; // ✅ Ubah dari var menjadi int

  Produk({this.id, this.kodeProduk, this.namaProduk, this.hargaProduk});

  factory Produk.fromJson(Map<String, dynamic> obj) {
    return Produk(
      id: obj['id'] as int?,
      kodeProduk: obj['kode_produk'] as String?,
      namaProduk: obj['nama_produk'] as String?,
      hargaProduk: obj['harga'] is String
          ? int.tryParse(obj['harga'])
          : obj['harga'] as int?,
    );
  }

  // ✅ Tambah method untuk convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_produk': kodeProduk,
      'nama_produk': namaProduk,
      'harga': hargaProduk,
    };
  }
}
