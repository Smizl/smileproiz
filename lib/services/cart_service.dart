import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  final http.Client client;

  CartService({http.Client? client}) : client = client ?? http.Client();

  // -----------------------------
  // Host config
  // -----------------------------
  static const String _defaultHost = 'http://172.20.10.3:8080';
  static const String _hostKey = 'api_host';

  Future<String> _getHost() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hostKey) ?? _defaultHost;
  }

  Future<String> _baseUrl() async => '${await _getHost()}/api/cart';

  // -----------------------------
  // Auth headers
  // -----------------------------
  Future<Map<String, String>> _authHeaders({bool json = true}) async {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // -----------------------------
  // ➕ Add to cart
  // -----------------------------
  Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
    Duration? timeout,
  }) async {
    final url = Uri.parse('${await _baseUrl()}/add');

    final size = selectedSize?.isNotEmpty == true
        ? selectedSize!
        : 'Один размер';
    final color = selectedColor?.isNotEmpty == true
        ? selectedColor!
        : 'Нет цвета';

    final body = jsonEncode({
      'productId': productId,
      'quantity': quantity,
      'selectedSize': size,
      'selectedColor': color,
    });

    try {
      final response = await client
          .post(url, headers: await _authHeaders(json: true), body: body)
          .timeout(timeout ?? const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Ошибка при добавлении в корзину: ${response.statusCode} ${response.body}',
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // -----------------------------
  // 📦 Get cart items
  // -----------------------------
  Future<List<Map<String, dynamic>>> getCartItems({Duration? timeout}) async {
    final url = Uri.parse('${await _baseUrl()}/all');

    final response = await client
        .get(url, headers: await _authHeaders(json: false))
        .timeout(timeout ?? const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else {
      throw Exception(
        'Ошибка при получении корзины: ${response.statusCode} ${response.body}',
      );
    }
  }

  // -----------------------------
  // ✏️ Update item
  // -----------------------------
  Future<void> updateCartItem({
    required int cartItemId,
    required int newQuantity,
    Duration? timeout,
  }) async {
    final url = Uri.parse(
      '${await _baseUrl()}/update/$cartItemId?quantity=$newQuantity',
    );

    final response = await client
        .put(url, headers: await _authHeaders(json: false))
        .timeout(timeout ?? const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Ошибка при обновлении товара: ${response.statusCode} ${response.body}',
      );
    }
  }

  // -----------------------------
  // ❌ Delete item
  // -----------------------------
  Future<void> deleteCartItem({
    required int cartItemId,
    Duration? timeout,
  }) async {
    final url = Uri.parse('${await _baseUrl()}/delete/$cartItemId');

    final response = await client
        .delete(url, headers: await _authHeaders(json: false))
        .timeout(timeout ?? const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Ошибка при удалении товара: ${response.statusCode} ${response.body}',
      );
    }
  }

  // -----------------------------
  // 🧹 Clear cart
  // -----------------------------
  Future<void> clearCart({Duration? timeout}) async {
    final url = Uri.parse('${await _baseUrl()}/clear');

    final response = await client
        .delete(url, headers: await _authHeaders(json: false))
        .timeout(timeout ?? const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Ошибка при очистке корзины: ${response.statusCode} ${response.body}',
      );
    }
  }

  // -----------------------------
  // 🔄 Increment all
  // -----------------------------
  Future<void> incrementAllItems() async {
    final cart = await getCartItems();
    for (var item in cart) {
      final int id = item['id'];
      final int quantity = item['quantity'];
      await updateCartItem(cartItemId: id, newQuantity: quantity + 1);
    }
  }
}
