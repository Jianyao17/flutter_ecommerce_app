# ecommerce_app

A new Flutter project.

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
- [Dart SDK](https://dart.dev/get-dart) (usually included with Flutter)
- Android Studio, VS Code, atau IDE lain dengan dukungan Flutter
- Emulator Android/iOS atau perangkat fisik
- [Node.js & npm](https://nodejs.org/) (untuk backend server)

### Struktur Folder
- `server/` : Berisi source code backend (Node.js) untuk project Flutter ini. Jalankan backend sebelum aplikasi Flutter jika aplikasi membutuhkan akses API backend.

### Setup & Menjalankan Project

1. **Clone repository:**
   ```bash
   git clone <repository-url>
   cd ecommerce_app
   ```

2. **Install dependencies Flutter:**
   ```bash
   flutter pub get
   ```

3. **Jalankan backend server:**
   Masuk ke folder `server` lalu install dan jalankan server:
   ```bash
   cd server
   npm install
   npm start
   ```
   Server berjalan di port 3000 (default).
   Untuk menghentikan server tekan `Ctrl + C`.

4. **Kembali ke root project untuk menjalankan Flutter:**
   ```bash
   cd ..
   flutter run
   ```
   Untuk memilih device tertentu:
   ```bash
   flutter devices
   flutter run -d <device_id>
   ```

### Troubleshooting
- Jika ada error dependency, jalankan:
  ```bash
  flutter clean
  flutter pub get
  ```
- Pastikan Flutter SDK up-to-date:
  ```bash
  flutter upgrade
  ```

### Catatan
- Pastikan backend (`server/`) sudah berjalan sebelum menjalankan aplikasi Flutter jika aplikasi membutuhkan akses ke API.
- Untuk pengembangan Android/iOS, pastikan sudah melakukan konfigurasi signing dan SDK sesuai kebutuhan platform.

