import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class WishlistService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<List<Product>> fetchWishlist() async
  {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/wishlist'));
      if (response.statusCode == 200) {
        return Product.listFromJson(response.body);
      }
      throw Exception('Failed to fetch wishlist');
    } catch (e) {
      throw Exception('Failed to fetch wishlist: $e');
    }
  }

  Future<void> addToWishlist(int productId) async
  {
    try {
      final response = await http.post(Uri.parse('$baseUrl/products/$productId/wishlist'));
      if (response.statusCode != 200) {
        throw Exception('Failed to add product to wishlist');
      }
    } catch (e) {
      throw Exception('Failed to add product to wishlist: $e');
    }
  }

  Future<void> removeFromWishlist(int productId) async
  {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$productId/wishlist'));

      if (response.statusCode != 200) {
        throw Exception('Failed to remove product from wishlist');
      }
    } catch (e) {
      throw Exception('Failed to remove product from wishlist: $e');
    }
  }
}
