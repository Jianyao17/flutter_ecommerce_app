import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'product_details.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
{
  final CartService _cartService = CartService();
  List<CartItem> cartItems = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  // Helper untuk format mata uang
  String formatCurrency(double price) => 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  @override
  void initState()
  {
    super.initState();
    _fetchCart();
  }

  void _onSearchChanged(String value) => setState(() => _searchQuery = value);

  // Fetch cart items from the server
  Future<void> _fetchCart() async
  {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final items = await _cartService.fetchCart();
      setState(() {
        cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double get total
    => cartItems.fold(0, (sum, item) => sum + item.product.priceIdr * item.quantity);

  int get itemCount
    => cartItems.fold(0, (sum, item) => sum + item.quantity);

  // Add quantity to an item
  Future<void> addQty(int i) async
  {
    try {
      final item = cartItems[i];
      final newQty = item.quantity + 1;

      // Update local state first
      setState(() {
        cartItems[i].quantity = newQty;
      });

      // Then update server
      await _cartService.updateCartItem(
        int.parse(item.id),
        newQty
      );
    } catch (e) {
      // Revert on failure
      setState(() {
        cartItems[i].quantity--;
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }

  // Remove quantity from an item
  Future<void> removeQty(int i) async
  {
    if (cartItems[i].quantity <= 1) return;

    try {
      final item = cartItems[i];
      final newQty = item.quantity - 1;

      // Update local state first
      setState(() {
        cartItems[i].quantity = newQty;
      });

      // Then update server
      await _cartService.updateCartItem(
        int.parse(item.id),
        newQty
      );
    } catch (e) {
      // Revert on failure
      setState(() {
        cartItems[i].quantity++;
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }

  // Remove an item from the cart
  Future<void> removeItem(int i) async
  {
    final item = cartItems[i];
    final itemIndex = i;

    // Update local state first
    setState(() {
      cartItems.removeAt(itemIndex);
    });

    try {
      // Then update server
      await _cartService.removeCartItem(item.id);
    } catch (e) {
      // Revert on failure
      setState(() {
        cartItems.insert(itemIndex, item);
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        leading: const Icon(Icons.shopping_cart),
        title: const Text('Cart',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20
          ),
        ),
        actions: [
          if (_error != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchCart,
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
                ElevatedButton(
                  onPressed: _fetchCart,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        : cartItems.isEmpty
        ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined,
                color: Colors.grey,
                size: 72,
              ),
              SizedBox(height: 16),
              Text('Your cart is empty',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18
                ),
              ),
            ],
          ),
        )
        : buildCartLayout(),
    );
  }

  Widget buildCartLayout()
  {
    // Filter cart items based on search query
    final filteredItems = cartItems
      .where((item) => item.product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
            child: ListView.separated(
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i)
                => buildCardItem(filteredItems[i], i),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 18, horizontal: 20,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subtotal',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    Text(formatCurrency(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: filteredItems.isEmpty ? null : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 38, vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text('Checkout ($itemCount)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCardItem(CartItem item, int i)
  {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: ()
        => Navigator.push(context,
          MaterialPageRoute(
            builder: (context) =>
              ProductDetailsPage(currentProduct: item.product),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Leading image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(item.product.imageUrl,
                  width: 64, height: 64, fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress)
                  {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace)
                    => const Center(child: Icon(Icons.image_not_supported, size: 50)),
                ),
              ),
              const SizedBox(width: 12),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(item.product.priceIdr),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity controls
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    splashRadius: 20,
                    onPressed: () => removeQty(i),
                    icon: const Icon(Icons.remove,
                        color: Colors.white,
                        size: 22
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.quantity.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    splashRadius: 20,
                    onPressed: () => addQty(i),
                    icon: const Icon(Icons.add,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  splashRadius: 20,
                  onPressed: () => removeItem(i),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
