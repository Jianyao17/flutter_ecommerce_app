import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> 
{
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  String name = '';
  int priceIdr = 0;
  String imageUrl = '';
  List<String> tags = [];
  int stock = 0;
  String description = '';
  double rating = 0;

  final TextEditingController _tagsController = TextEditingController();
  String formatCurrency(double price) => 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';


  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    _formKey.currentState!.save();
    final barang = {
      "name": name,
      "priceIdr": priceIdr,
      "imageUrl": imageUrl,
      "tags": tags,
      "stock": stock,
      "description": description,
      "rating": rating,
    };
    try {
      final res = await http.post(
        Uri.parse('http://localhost:3000/products'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(barang),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        _formKey.currentState!.reset();
        _tagsController.clear();
        setState(() {
          name = '';
          priceIdr = 0;
          imageUrl = '';
          tags = [];
          stock = 0;
          description = '';
          rating = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        
      } else {
        throw Exception('Gagal menambah produk (${res.statusCode})');
      }
    } catch (e) {
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() 
  {
    _tagsController.dispose();
    super.dispose();
  }

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
        backgroundColor: Colors.black12,
        leading: const Icon(Icons.add_circle_rounded),
        title: const Text('Add Product',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20
          ),
        ),
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _error = null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(borderRadius: buttonRadius),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informasi Produk',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Nama Produk',
                                  hintText: 'Masukkan nama produk',
                                  border: inputEnabledBorder,
                                  enabledBorder: inputEnabledBorder,
                                  focusedBorder: inputFocusedBorder,
                                  prefixIcon: const Icon(Icons.shopping_bag),
                                ),
                                validator: (value) => value!.isEmpty ? 'Nama produk wajib diisi' : null,
                                onSaved: (value) => name = value!,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Harga (IDR)',
                                  hintText: 'Masukkan harga produk',
                                  border: inputEnabledBorder,
                                  enabledBorder: inputEnabledBorder,
                                  focusedBorder: inputFocusedBorder,
                                  prefixIcon: const Icon(Icons.attach_money),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) => value!.isEmpty ? 'Harga wajib diisi' : null,
                                onSaved: (value) => priceIdr = int.parse(value!),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'URL Gambar',
                                  hintText: 'Masukkan URL gambar',
                                  border: inputEnabledBorder,
                                  enabledBorder: inputEnabledBorder,
                                  focusedBorder: inputFocusedBorder,
                                  prefixIcon: const Icon(Icons.image),
                                ),
                                onSaved: (value) => imageUrl = value!,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detail Produk',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _tagsController,
                                decoration: InputDecoration(
                                  labelText: 'Kategori (pisahkan dengan koma)',
                                  hintText: 'Contoh: Elektronik, Fashion',
                                  border: inputEnabledBorder,
                                  enabledBorder: inputEnabledBorder,
                                  focusedBorder: inputFocusedBorder,
                                  prefixIcon: const Icon(Icons.tag),
                                ),
                                onSaved: (value) => tags = value!.split(',').map((e) => e.trim()).toList(),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Stok',
                                  hintText: 'Masukkan jumlah stok',
                                  border: inputEnabledBorder,
                                  enabledBorder: inputEnabledBorder,
                                  focusedBorder: inputFocusedBorder,
                                  prefixIcon: const Icon(Icons.inventory),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) => value!.isEmpty ? 'Stok wajib diisi' : null,
                                onSaved: (value) => stock = int.parse(value!),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Deskripsi',
                                  hintText: 'Deskripsi produk (opsional)',
                                  border: inputEnabledBorder,
                                  enabledBorder: inputEnabledBorder,
                                  focusedBorder: inputFocusedBorder,
                                  alignLabelWithHint: true,
                                  prefixIcon: const Icon(Icons.description),
                                ),
                                maxLines: 3,
                                onSaved: (value) => description = value ?? '',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: buttonRadius,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Tambah Produk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}