# Ecommerce App Server

API sederhana untuk backend aplikasi e-commerce berbasis Node.js dan Hapi.

## Fitur
- Endpoint produk (list, detail, new, popular, carousel)
- Wishlist
- Keranjang belanja
- CORS sudah diaktifkan

## Prasyarat
- Node.js (disarankan versi 18 ke atas)

## Instalasi
1. Clone repository ini atau salin source code ke komputer Anda.
2. Install dependencies:
   ```bash
   npm install
   ```

## Menjalankan Server
Jalankan perintah berikut di folder server:
```bash
npm start
```

Server akan berjalan di `http://0.0.0.0:3000` (atau sesuai port yang diatur).

## Endpoint Utama
- `GET /products` — Semua produk
- `GET /products/new` — Produk baru
- `GET /products/popular` — Produk populer
- `GET /products/carousel` — 5 produk acak untuk carousel
- `GET /products/{id}` — Detail produk
- `GET /products/wishlist` — Daftar wishlist
- `POST /products/{id}/wishlist` — Tambah ke wishlist
- `DELETE /products/{id}/wishlist` — Hapus dari wishlist
- `GET /cart` — Lihat keranjang
- `POST /cart` — Tambah/update keranjang
- `DELETE /cart/item/{id}` — Hapus item dari keranjang

---

Untuk pengembangan lebih lanjut, silakan modifikasi file `routes.js` dan `database.json` sesuai kebutuhan.
