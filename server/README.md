# Ecommerce App Server

API sederhana untuk backend aplikasi e-commerce berbasis Node.js dan Hapi.

## Fitur
- Endpoint produk (list, detail, new, popular, carousel)
- Tambah produk baru
- Wishlist dengan penyimpanan permanen
- Keranjang belanja dengan penyimpanan permanen
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
- `POST /products` — Tambah produk baru
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

## Spesifikasi Request & Response

### 1. Tambah Produk Baru
**POST /products**

Request body:
```json
{
  "name": "Nama Produk",
  "priceIdr": 1000000,
  "imageUrl": "https://example.com/image.jpg",
  "tags": ["Kategori1", "Kategori2"],
  "stock": 10,
  "description": "Deskripsi produk (opsional)",
  "rating": 0
}
```

Response (berhasil):
```json
{
  "status": "success",
  "message": "Product added successfully",
  "product": {
    "id": 123,
    "name": "Nama Produk",
    "priceIdr": 1000000,
    "imageUrl": "https://example.com/image.jpg",
    "tags": ["Kategori1", "Kategori2"],
    "stock": 10,
    "description": "Deskripsi produk",
    "rating": 0,
    "isWishlisted": false
  }
}
```

### 2. Tambah ke Wishlist
**POST /products/{id}/wishlist**

Request:
```
Tidak membutuhkan body (hanya id di URL)
```
Response (berhasil):
```json
{
  "message": "Product with id 5 has been added to wishlist.",
  "wishlistedIds": [9, 10, 8, 5]
}
```

### 3. Tambah/Update Keranjang (Replace Quantity)
**POST /cart**

Request body:
```json
{
  "productId": 1,
  "quantity": 2
}
```
Response (berhasil):
```json
{
  "message": "2 x Wireless Headphones has been added/updated in your cart.",
  "cart": {
    "1": 2
  }
}
```
Response (gagal, stok kurang):
```json
{
  "message": "Insufficient stock for Wireless Headphones. Only 1 left."
}
```

### 4. Tambah Item ke Keranjang (Tambah 1 per request)
**POST /cart/item**

Request body:
```json
{
  "productId": 1
}
```
Response (berhasil):
```json
{
  "message": "Wireless Headphones has been added to your cart (total: 3).",
  "cart": {
    "1": 3
  }
}
```
Response (gagal, stok kurang):
```json
{
  "message": "Insufficient stock for Wireless Headphones. Only 0 left in cart."
}
```

### 5. Lihat Keranjang
**GET /cart**

Response:
```json
{
  "items": [
    {
      "id": 1,
      "name": "Wireless Headphones",
      "price": 350000,
      "imageUrl": "...",
      "tags": ["Electronics"],
      "rating": 4.7,
      "stock": 50,
      "description": "...",
      "quantityInCart": 2
    }
  ],
  "summary": {
    "totalPrice": 700000,
    "totalItems": 2
  }
}
```

### 6. Contoh Response Produk
**GET /products**

Response:
```json
[
  {
    "id": 1,
    "name": "Wireless Headphones",
    "price": 350000,
    "imageUrl": "...",
    "tags": ["Electronics"],
    "rating": 4.7,
    "stock": 50,
    "description": "...",
    "isWishlisted": false
  },
  // ...
]
```

---

Untuk pengembangan lebih lanjut, silakan modifikasi file `routes.js` dan `database.json` sesuai kebutuhan.
