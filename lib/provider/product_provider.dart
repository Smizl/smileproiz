import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];

  List<Map<String, dynamic>> get products => _products;

  final String baseUrl =
      "http://localhost:8080/api/products"; // замени на свой IP/домен

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      _products = data.map((e) => Map<String, dynamic>.from(e)).toList();
      notifyListeners();
    }
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      await fetchProducts(); // обновляем список после добавления
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product),
    );
    if (response.statusCode == 200) {
      await fetchProducts();
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      await fetchProducts();
    }
  }
}
