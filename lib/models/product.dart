import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String description;
  final double priceIdr;
  final String imageUrl;
  final List<String> tags;

  final int stock;
  final bool isWishlisted;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceIdr,
    required this.imageUrl,
    required this.stock,

    required this.tags,
    this.isWishlisted = false,
  });

  /// Mengubah string JSON (array of objects) menjadi List<Product>.
  static List<Product> listFromJson(String str) =>
      List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

  /// Mengubah List<Product> menjadi string JSON.
  static String listToJson(List<Product> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));


  /// Factory constructor: membuat instance Product dari sebuah Map (hasil decode JSON).
  factory Product.fromJson(Map<String, dynamic> json)
  => Product(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    priceIdr: (json['priceIdr'] as num).toDouble(),
    imageUrl: json['imageUrl'],
    tags: List<String>.from(json['tags']),

    stock: json['stock'],
    isWishlisted: json['isWishlisted'] ?? false,
  );

  /// Method: mengubah instance Product menjadi sebuah Map untuk konversi ke JSON.
  Map<String, dynamic> toJson()
  => {
    'id': id,
    'name': name,
    'description': description,
    'priceIdr': priceIdr,
    'imageUrl': imageUrl,
    'tags': tags,

    'stock': stock,
    'isWishlisted': isWishlisted,
  };


  static List<Product> getAllProduct() => [
    Product(
      id: 1,
      name: 'Laptop Ultrabook Pro X1',
      description: 'Laptop tipis dan ringan dengan performa tinggi untuk para profesional. Dilengkapi dengan prosesor terbaru dan layar 4K.',
      priceIdr: 18500000,
      imageUrl: 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      stock: 35,
      tags: ['elektronik', 'laptop', 'kerja', 'portabel'],
      isWishlisted: true
    ),
    Product(
      id: 2,
      name: 'Headphone Kedap Suara Vibe',
      description: 'Nikmati musik tanpa gangguan dengan teknologi peredam bising aktif. Kualitas suara jernih dan bass yang mendalam.',
      priceIdr: 2150000,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      stock: 80,
      tags: ['audio', 'headphone', 'musik', 'gadget'],
    ),
    Product(
      id: 3,
      name: 'Sepatu Lari Cepat Adrenaline',
      description: 'Sepatu lari yang dirancang untuk kecepatan dan kenyamanan. Memberikan bantalan responsif di setiap langkah.',
      priceIdr: 1250000,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      stock: 120,
      tags: ['fashion', 'olahraga', 'sepatu', 'lari'],
      isWishlisted: true
    ),
    Product(
      id: 4,
      name: 'Kamera Mirrorless Alpha Z',
      description: 'Abadikan momen berharga dengan kualitas profesional. Sensor full-frame dan autofokus super cepat.',
      priceIdr: 29999000,
      imageUrl: 'https://images.unsplash.com/photo-1512790182412-b19e6d62bc39?q=80&w=2532&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      stock: 20,
      tags: ['kamera', 'fotografi', 'elektronik', 'hobi'],
      isWishlisted: true
    ),
    Product(
      id: 5,
      name: 'Smartwatch Active Fit 2',
      description: 'Pantau kesehatan dan kebugaran Anda dengan gaya. Dilengkapi GPS, monitor detak jantung, dan puluhan mode olahraga.',
      priceIdr: 3450000,
      imageUrl: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?q=80&w=2564&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      stock: 95,
      tags: ['smartwatch', 'kesehatan', 'olahraga', 'wearable'],
      isWishlisted: true
    ),
    Product(
      id: 6,
      name: 'Tas Ransel Petualang Urban',
      description: 'Tas ransel serbaguna dengan banyak kompartemen, tahan air, dan nyaman digunakan untuk kegiatan sehari-hari maupun traveling.',
      priceIdr: 899000,
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb68c6a62?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      stock: 150,
      tags: ['fashion', 'tas', 'travel', 'aksesoris'],
    ),
  ];
}