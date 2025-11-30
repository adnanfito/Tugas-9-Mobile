export class CreateProdukDto {
  kode_produk: string;
  nama_produk: string;
  harga: string | number; // ✅ Accept both string dan number
}
