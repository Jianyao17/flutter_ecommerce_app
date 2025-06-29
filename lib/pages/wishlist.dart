import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/widget/product_card.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage>
    with AutomaticKeepAliveClientMixin
{
  String _searchQuery = '';
  List<Product>? wishlistProducts;

  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadWishlistProducts() async
  {
    try {
      var URL = Uri.parse('http://10.0.2.2:3000/products/wishlist');
      final response = await http.get(URL);

      if (response.statusCode == 200)
      {
        setState(() {
          // Assuming the response body is a JSON array of products
          wishlistProducts = Product.listFromJson(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      throw Exception('Failed to load wishlist products: $e');
    }
  }

  @override
  void initState()
  {
    _loadWishlistProducts();
    super.initState();
  }

  void _onSearchChanged(String value)
  => setState(() => _searchQuery = value);

  @override
  Widget build(BuildContext context)
  {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        leading: Icon(Icons.favorite),
        title: Text('Wishlist',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20
          )
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : buildWishlistLayout(context),
    );
  }

  Padding buildWishlistLayout(BuildContext context)
  {
    final List<Product> filteredWishlist = wishlistProducts!
        .where((product) => product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Search Bar
          TextField(
            onChanged: _onSearchChanged,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14
            ),
            decoration: InputDecoration(
              hintText: 'Find Product',
              prefixIcon: const Icon(Icons.search),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.7)),
                  borderRadius: BorderRadius.circular(16)
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color:
                  Theme.of(context).primaryColor.withValues(alpha: 0.8), width: 2),
                  borderRadius: BorderRadius.circular(16)
              ),
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: filteredWishlist.isEmpty
                ? Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'Your wishlist is empty.'
                    : 'No products found for "$_searchQuery".',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.70,
              ),
              itemCount: filteredWishlist.length,
              itemBuilder: (context, index)
              {
                final product = filteredWishlist[index];
                return ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}