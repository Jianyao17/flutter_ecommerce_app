import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import '../pages/product_details.dart';
import '../models/product.dart';

class ProductCarousel extends StatefulWidget
{
  final List<Product> products;
  const ProductCarousel({super.key, required this.products});

  @override
  _ProductCarouselState createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel>
{
  Timer? _timer;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState()
  {
    super.initState();
    if (widget.products.isNotEmpty)
    { _startAutoSlide(); }
  }

  void _startAutoSlide()
  {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer)
    {
      if (_currentPage < widget.products.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients)
      {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose()
  {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String formatCurrency(double price) => 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context)
  {
    if (widget.products.isEmpty)
    { return const Center(child: Text("No products to display")); }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              padEnds: false,
              controller: _pageController,
              onPageChanged: (int page)
                => setState(()
                {
                  _currentPage = page;
                  _timer?.cancel();
                  _startAutoSlide();
                }),
              itemCount: widget.products.length,
              itemBuilder: (context, index)
                => carouselItem(widget.products[index]),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.products.map((product) {
              int index = widget.products.indexOf(product);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.green
                      : Colors.grey.withOpacity(0.5),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget carouselItem(Product product)
  {
    return InkWell(
      onTap: ()
      {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) => ProductDetailsPage(currentProduct: product),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0), end: Offset.zero).animate(animation),
              child: child)),
        );
      },
      splashColor: Colors.white.withOpacity(0.2),
      highlightColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace)
                  => const Center(child: Icon(Icons.image_not_supported, size: 50)),
                loadingBuilder: (context, child, loadingProgress)
                {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.3, 0.4, 0.56],
                        colors: [
                          Colors.black.withOpacity(.76),
                          Colors.black.withOpacity(.56),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          color: Colors.black.withOpacity(0.25),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Stock: ${product.stock}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(product.priceIdr),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                product.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    height: 1.2),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                product.tags.join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}