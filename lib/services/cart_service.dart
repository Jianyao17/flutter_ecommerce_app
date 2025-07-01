import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService
{
  static const String baseUrl = 'http://localhost:3000';

  // Fetches the cart items from the server
  Future<List<CartItem>> fetchCart() async
  {
    try {
      final response = await http.get(Uri.parse('$baseUrl/cart'));

      if (response.statusCode == 200)
      {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        return items.map((item)
        {
          final product = Product.fromJson(item);
          return CartItem(
            product: product,
            id: item['id'].toString(),
            quantity: item['quantityInCart'],
          );
        }).toList();
      }
      throw Exception('Failed to fetch cart');
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  // Adds an item to the cart
  Future<void> addToCart(int productId) async
  {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/item'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({ 'productId': productId }),
      );

      if (response.statusCode != 200)
      {
        final error = json.decode(response.body);
        throw Exception(error['message']);
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Updates the quantity of an item in the cart
  Future<void> updateCartItem(int productId, int quantity) async
  {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200)
      {
        final error = json.decode(response.body);
        throw Exception(error['message']);
      }
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  // Removes an item from the cart
  Future<void> removeCartItem(String itemId) async
  {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/item/$itemId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove item from cart');
      }
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }
}
