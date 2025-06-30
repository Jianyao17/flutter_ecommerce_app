import 'package:flutter/material.dart';
import '../pages/product_details.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget
{
  final Product product;
  const ProductCard({
    super.key,
    required this.product,
  });

  // Helper untuk format mata uang
  String formatCurrency(double price) => 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context)
  {
    const brandGreen = Colors.green;
    const surfaceColor = Color(0xFF1E1E1E);
    const primaryTextColor = Colors.white;

    return InkWell(
      onTap: ()
      {
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context)
              => ProductDetailsPage(currentProduct: product),
          ),
        );
      },
      splashColor: brandGreen.withAlpha(40),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace)
                  => Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey
                    )
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product.name, maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(formatCurrency(product.priceIdr),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900, // Extra bold
                        color: brandGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
