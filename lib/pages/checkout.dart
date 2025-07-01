
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;

  const CheckoutPage({Key? key, required this.cartItems, required this.subtotal}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> 
{
  final TextEditingController _originSearchController = TextEditingController();
  final TextEditingController _destinationSearchController = TextEditingController();
  List<Map<String, dynamic>> _originOptions = [];
  List<Map<String, dynamic>> _destinationOptions = [];
  Map<String, dynamic>? _selectedOrigin;
  Map<String, dynamic>? _selectedDestination;
  final String apiKey = "a2gjxwWse4ac334e9fa3b62aOXFdwOZ5"; // <-- ISI API KEY ANDA DI SINI

  String? originId, destinationId;
  int ongkir = 0;
  List<Map<String, dynamic>> courierResults = [];
  bool _isLoading = false;
  String? _error;
  bool _showNota = false;

  Future<List<Map<String, dynamic>>> fetchDestinations(String keyword) async {
    if (apiKey.isEmpty) throw Exception("API Key RajaOngkir belum diisi!");
    final url = Uri.parse("https://rajaongkir.komerce.id/api/v1/destination/domestic-destination?search=$keyword&limit=10&offset=0");
    final response = await http.get(url, headers: {"key": apiKey});
    final data = jsonDecode(response.body);
    if (data['data'] == null) throw Exception("Gagal mengambil data tujuan");
    return (data['data'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> searchOrigin() async {
    if (_originSearchController.text.trim().isEmpty) return;
    setState(() { _isLoading = true; });
    try {
      final results = await fetchDestinations(_originSearchController.text.trim());
      setState(() { _originOptions = results; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> searchDestination() async {
    if (_destinationSearchController.text.trim().isEmpty) return;
    setState(() { _isLoading = true; });
    try {
      final results = await fetchDestinations(_destinationSearchController.text.trim());
      setState(() { _destinationOptions = results; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> cekOngkir() async {
    if (apiKey.isEmpty) {
      setState(() => _error = "API Key RajaOngkir belum diisi!");
      return;
    }
    if (originId == null || destinationId == null) {
      setState(() => _error = "Asal & tujuan harus dipilih!");
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await http.post(
        Uri.parse("https://rajaongkir.komerce.id/api/v1/calculate/domestic-cost"),
        headers: {
          "key": apiKey,
          "content-type": "application/x-www-form-urlencoded"
        },
        body: {
          "origin": originId!,
          "destination": destinationId!,
          "weight": "1000",
          "courier": "jne:sicepat:tiki",
          "price": "lowest"
        },
      );
      final data = jsonDecode(response.body);
      if (data['data'] == null) throw Exception("Gagal mendapatkan ongkir");
      final List<dynamic> results = data['data'];
      setState(() {
        courierResults = results.where((e) => ["jne", "sicepat", "tiki"].contains(e['code'])).toList().cast<Map<String, dynamic>>();
        ongkir = courierResults.isNotEmpty ? courierResults[0]['cost'] ?? 0 : 0;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  int getTotalPembayaran() {
    return widget.subtotal.round() + ongkir;
  }

  String formatCurrency(num price) => 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) 
  {
    // --- Styling Constants ---
    final inputBorderRadius = BorderRadius.circular(16);
    final inputEnabledBorder = OutlineInputBorder(
      borderRadius: inputBorderRadius,
      borderSide: BorderSide(color: Colors.grey.withAlpha(179)),
    );
    final inputFocusedBorder = OutlineInputBorder(
      borderRadius: inputBorderRadius,
      borderSide: BorderSide(color: Theme.of(context).primaryColor.withAlpha(204), width: 2),
    );
    final buttonRadius = BorderRadius.circular(14);
    final buttonColor = Colors.green[400];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.black12,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _error = null),
                      )
                    ],
                  ),
                ),
              ],

              // --- Alamat & Ongkir ---
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Alamat Pengiriman",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // --- Origin Search ---
              Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF23242A),
                child: TextField(
                  controller: _originSearchController,
                  onSubmitted: (_) => searchOrigin(),
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Cari Asal Pengiriman",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.greenAccent)),
                    prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.white70),
                  ),
                  cursorColor: Colors.greenAccent,
                ),
              ),
              if (_originOptions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF23242A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        dropdownColor: const Color(0xFF23242A),
                        style: const TextStyle(color: Colors.white),
                        isExpanded: true,
                        value: _selectedOrigin,
                        hint: const Text("Pilih Asal", style: TextStyle(color: Colors.white54)),
                        items: _originOptions.map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item['label'], style: const TextStyle(color: Colors.white)),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedOrigin = val;
                            originId = val?['id']?.toString();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // --- Destination Search ---
              Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF23242A),
                child: TextField(
                  controller: _destinationSearchController,
                  onSubmitted: (_) => searchDestination(),
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Cari Tujuan Pengiriman",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.greenAccent)),
                    prefixIcon: const Icon(Icons.location_searching_outlined, color: Colors.white70),
                  ),
                  cursorColor: Colors.greenAccent,
                ),
              ),
              if (_destinationOptions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF23242A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        dropdownColor: const Color(0xFF23242A),
                        style: const TextStyle(color: Colors.white),
                        isExpanded: true,
                        value: _selectedDestination,
                        hint: const Text("Pilih Tujuan", style: TextStyle(color: Colors.white54)),
                        items: _destinationOptions.map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item['label'], style: const TextStyle(color: Colors.white)),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDestination = val;
                            destinationId = val?['id']?.toString();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () async {
                    await cekOngkir();
                    if (_error == null) {
                      setState(() {
                        _showNota = true;
                      });
                    }
                  },
                  icon: const Icon(Icons.receipt_long, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: buttonRadius,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Tampilkan Nota',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              if (_showNota) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Nota Belanja",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23242A),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barang belanjaan
                      ...widget.cartItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.product.name,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('x${item.quantity}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(width: 8),
                            Text(formatCurrency(item.product.priceIdr * item.quantity), style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      )),
                      const Divider(color: Colors.white24, thickness: 1, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: Colors.white70)),
                          Text(formatCurrency(widget.subtotal), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 3 vendor ongkir terbaik
                      ...courierResults.take(3).map((courier) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${courier['name']} (${courier['service']})',
                                style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(formatCurrency(courier['cost']), style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      )),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total (termasuk ongkir termurah)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(formatCurrency(getTotalPembayaran()), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
