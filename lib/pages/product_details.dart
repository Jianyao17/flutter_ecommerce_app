import 'package:ecommerce_app/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductDetailsPage extends StatefulWidget
{
  final Product currentProduct;
  const ProductDetailsPage({super.key, required this.currentProduct});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
{
  // Helper untuk format mata uang
  String _formatCurrency(double price) => 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context)
  {
    bool isWishlisted = widget.currentProduct.isWishlisted;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context)
        ),
        title: Text('Product Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20
          )
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            label: const Text(
              'Buy Product',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.currentProduct.name} added to cart!')),
              );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 450,
                  child: Image.network(
                    widget.currentProduct.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress)
                    {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace)
                      => const Center(child: Icon(Icons.image_not_supported, size: 50)),
                  ),
                ),
              ],
            ),


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Produk Name
                            Text(widget.currentProduct.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                // Harga Produk
                                Icon(Icons.sell_outlined, color: Colors.green, size: 20),
                                const SizedBox(width: 4),
                                Text(_formatCurrency(widget.currentProduct.priceIdr ?? 0),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Stok Produk
                                Icon(Icons.inventory_2_outlined, color: Colors.grey[600], size: 20),
                                const SizedBox(width: 6),
                                Text('Stok: ${widget.currentProduct.stock}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      FloatingActionButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isWishlisted ? Colors.transparent : Colors.green,
                            width: 2,
                          ),
                        ),
                        backgroundColor: isWishlisted ? Colors.green : Colors.transparent,
                        elevation: 2.0,
                        onPressed: ()
                        {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isWishlisted
                                  ? '${widget.currentProduct.name} dihapus dari wishlist!'
                                  : '${widget.currentProduct.name} ditambahkan ke wishlist.',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },

                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation)
                            => FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border_outlined,
                            color: isWishlisted ? Colors.white : Colors.green,
                            key: ValueKey<bool>(isWishlisted),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  Wrap(spacing: 8.0, runSpacing: 4.0,
                    children: widget.currentProduct.tags
                      .map((tag) => Chip(
                        padding: const EdgeInsets.all(4),
                        label: Text(tag[0].toUpperCase() + tag.substring(1),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14)),
                        backgroundColor: Colors.white10,
                        side: BorderSide(color: Colors.transparent),
                      )).toList(),
                  ),
                  const SizedBox(height: 24),

                  const Text('Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(widget.currentProduct.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 56),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}