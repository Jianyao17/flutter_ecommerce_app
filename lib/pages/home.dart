import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/widget/product_card.dart';
import 'package:ecommerce_app/widget/product_carousel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin
{
  @override
  bool get wantKeepAlive => true;

  late List<Product>? carouselProducts;
  late List<Product>? popularProducts;
  late List<Product>? newProducts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState()
  {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async
  {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('http://10.0.2.2:3000/products/carousel')),
        http.get(Uri.parse('http://10.0.2.2:3000/products/popular')),
        http.get(Uri.parse('http://10.0.2.2:3000/products/new')),
      ]);

      if (responses.every((res) => res.statusCode == 200))
      {
        setState(() {
          // Assuming the response body is a JSON array of products
          carouselProducts = Product.listFromJson(responses[0].body);
          popularProducts = Product.listFromJson(responses[1].body);
          newProducts = Product.listFromJson(responses[2].body);
          _isLoading = false;
        });
      }
    } catch (e) {
      throw Exception('Failed to load products. One or more requests failed: $e');
    }
  }

  void _onSearchChanged(String query) {}

  @override
  Widget build(BuildContext context)
  {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        leading: Icon(Icons.home),
        title: Text('Home',
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
            : buildHomeLayout(context),
    );
  }

  Padding buildHomeLayout(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
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
                hintText: 'Search Product',
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
            const SizedBox(height: 10),

            // Products Carousel
            SizedBox(
              height: 350,
              child: ProductCarousel(products: carouselProducts!),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: const Text("Popular Products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Popular Products List
            SizedBox(
              height: 260,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                scrollDirection: Axis.horizontal,
                itemCount: popularProducts!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    ProductCard(product: popularProducts![index]),
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: const Text(
                "New Arrivals",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 260,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                scrollDirection: Axis.horizontal,
                itemCount: newProducts!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    ProductCard(product: newProducts![index]),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}