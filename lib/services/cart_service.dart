import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  static const String baseUrl = 'http://172.20.10.3:8080/api/cart';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  /// ➕ Добавление товара в корзину
  static Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
    Duration? timeout,
  }) async {
    final url = Uri.parse('$baseUrl/add');

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

    print('🟢 Отправка запроса на сервер: $body');

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(timeout ?? const Duration(seconds: 10));

      print('🔵 Ответ сервера: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Ошибка при добавлении в корзину: ${response.statusCode} ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      print('✅ Товар успешно добавлен на сервере: $decoded');
      return decoded;
    } catch (e) {
      print('⚠️ Ошибка в addToCart: $e');
      rethrow;
    }
  }

  /// 📦 Получение всех товаров корзины
  static Future<List<Map<String, dynamic>>> getCartItems({
    Duration? timeout,
  }) async {
    final url = Uri.parse('$baseUrl/all');

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(timeout ?? const Duration(seconds: 10));

      print('🔵 Ответ getCartItems: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Ошибка при получении корзины: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('⚠️ Ошибка getCartItems: $e');
      rethrow;
    }
  }

  /// ✏️ Обновление количества товара по актуальному id
  static Future<void> updateCartItem({
    required int cartItemId,
    required int newQuantity,
    Duration? timeout,
  }) async {
    final url = Uri.parse('$baseUrl/update/$cartItemId?quantity=$newQuantity');

    print('🟢 updateCartItem: id=$cartItemId quantity=$newQuantity');

    try {
      final response = await http
          .put(url, headers: headers)
          .timeout(timeout ?? const Duration(seconds: 10));

      print('🔵 Ответ updateCartItem: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Ошибка при обновлении товара: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('⚠️ Ошибка updateCartItem: $e');
      rethrow;
    }
  }

  /// ❌ Удаление одного товара по id из сервера
  static Future<void> deleteCartItem({
    required int cartItemId,
    Duration? timeout,
  }) async {
    final url = Uri.parse('$baseUrl/delete/$cartItemId');
    print('🟢 deleteCartItem: id=$cartItemId');

    try {
      final response = await http
          .delete(url, headers: headers)
          .timeout(timeout ?? const Duration(seconds: 10));

      print('🔵 Ответ deleteCartItem: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Ошибка при удалении товара: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('⚠️ Ошибка deleteCartItem: $e');
      rethrow;
    }
  }

  /// 🧹 Очистка корзины
  static Future<void> clearCart({Duration? timeout}) async {
    final url = Uri.parse('$baseUrl/clear');
    print('🟢 clearCart');

    try {
      final response = await http
          .delete(url, headers: headers)
          .timeout(timeout ?? const Duration(seconds: 10));

      print('🔵 Ответ clearCart: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Ошибка при очистке корзины: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('⚠️ Ошибка clearCart: $e');
      rethrow;
    }
  }

  /// 🔄 Пример безопасного обновления всех товаров: берем id с сервера
  static Future<void> incrementAllItems() async {
    final cart = await getCartItems();
    for (var item in cart) {
      final int id = item['id'];
      final int quantity = item['quantity'];
      await updateCartItem(cartItemId: id, newQuantity: quantity + 1);
      print('✅ Обновлен item id=$id, новое количество=${quantity + 1}');
    }
  }
}
