import 'package:flutter/material.dart';
import '../services/wishlist_service.dart';
import '../widget/product_card.dart';
import '../models/product.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage>
{
  final WishlistService _wishlistService = WishlistService();
  List<Product>? wishlistProducts = [];
  String _searchQuery = '';

  bool _isLoading = true;
  String? _error;

  Future<void> _loadWishlistProducts() async
  {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _wishlistService.fetchWishlist();
      if (!mounted) return;

      setState(() {
        wishlistProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState()
  {
    super.initState();
    _loadWishlistProducts();
  }

  void _onSearchChanged(String value) => setState(() => _searchQuery = value);

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        leading: const Icon(Icons.favorite),
        title: const Text('Wishlist',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20
          )
        ),
        actions: [
          if (_error != null || !_isLoading)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadWishlistProducts,
            )
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $_error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadWishlistProducts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
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
            style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14
            ),
            decoration: InputDecoration(
              hintText: 'Find Product',
              prefixIcon: const Icon(Icons.search),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withAlpha(179)),
                  borderRadius: BorderRadius.circular(16)
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color:
                  Theme.of(context).primaryColor.withAlpha(204), width: 2),
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



