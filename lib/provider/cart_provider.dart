import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smileproiz/services/cart_service.dart';
import 'package:smileproiz/services/cart_websocket_service.dart';

class CartItem {
  final int id;
  final int productId;
  final String name;
  final int price;
  final String imageUrl;
  final String selectedSize;
  final String selectedColor;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'selectedSize': selectedSize,
    'selectedColor': selectedColor,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: (json['id'] as num).toInt(),
    productId: (json['productId'] as num).toInt(),
    name: (json['name'] ?? '').toString(),
    price: (json['price'] as num).toInt(),
    imageUrl: (json['imageUrl'] ?? '').toString(),
    selectedSize: (json['selectedSize'] ?? '').toString(),
    selectedColor: (json['selectedColor'] ?? '').toString(),
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  );

  /// Уникальный ключ для быстрого поиска
  String get uniqueKey => '$productId-$selectedSize-$selectedColor';
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final Map<String, CartItem> _itemMap = {};

  final CartWebSocketService _webSocketService = CartWebSocketService();
  final CartService _cartService = CartService();
  StreamSubscription? _wsSubscription;

  bool _isLoading = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  bool get isLoading => _isLoading;

  int get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  CartProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadCart();
    _connectWebSocket();
  }

  // ================= WebSocket =================
  void _connectWebSocket() {
    _webSocketService.connect();

    _wsSubscription = _webSocketService.stream.listen(
      (data) {
        _resetReconnectAttempts();
        if (data is Map && data['type'] == 'cart_update') {
          loadCart();
        }
      },
      onDone: _handleWebSocketDisconnect,
      onError: (_) => _handleWebSocketDisconnect(),
    );
  }

  void _handleWebSocketDisconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) return;

    _reconnectAttempts++;
    final delay = Duration(seconds: 2 * _reconnectAttempts);
    Future.delayed(delay, _connectWebSocket);
  }

  void _resetReconnectAttempts() {
    _reconnectAttempts = 0;
  }

  // ================= LOAD =================
  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      // ✅ ВАЖНО: вызываем через инстанс _cartService
      final serverItems = await _cartService.getCartItems(
        timeout: const Duration(seconds: 5),
      );

      _items.clear();
      _itemMap.clear();

      for (final item in serverItems) {
        final product = item['product'] as Map<String, dynamic>?;

        if (product == null) continue;

        final cartItem = CartItem(
          id: (item['id'] as num).toInt(),
          productId: (product['id'] as num).toInt(),
          name: (product['name'] ?? '').toString(),
          price: (product['price'] as num).toInt(),
          imageUrl: (product['imageUrl'] ?? '').toString(),
          selectedSize: (item['selectedSize'] ?? '').toString(),
          selectedColor: (item['selectedColor'] ?? '').toString(),
          quantity: (item['quantity'] as num?)?.toInt() ?? 1,
        );

        _items.add(cartItem);
        _itemMap[cartItem.uniqueKey] = cartItem;
      }

      await _saveCartLocally();
    } catch (_) {
      await _loadCartFromLocal();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= ADD =================
  Future<void> addItem({
    required int productId,
    required String name,
    required int price,
    required String imageUrl,
    required String selectedSize,
    required String selectedColor,
    int quantity = 1,
  }) async {
    try {
      // ✅ ВАЖНО: вызываем через инстанс _cartService
      final serverItem = await _cartService.addToCart(
        productId: productId,
        quantity: quantity,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
      );

      final product = serverItem['product'] as Map<String, dynamic>?;

      final cartItem = CartItem(
        id: (serverItem['id'] as num).toInt(),
        productId: (product?['id'] as num?)?.toInt() ?? productId,
        name: (product?['name'] ?? name).toString(),
        price: (product?['price'] as num?)?.toInt() ?? price,
        imageUrl: (product?['imageUrl'] ?? imageUrl).toString(),
        selectedSize: selectedSize,
        selectedColor: selectedColor,
        quantity: quantity,
      );

      // Удаляем старый и добавляем новый
      _items.removeWhere((e) => e.uniqueKey == cartItem.uniqueKey);
      _items.add(cartItem);
      _itemMap[cartItem.uniqueKey] = cartItem;

      notifyListeners();
      await _saveCartLocally();
    } catch (_) {
      // offline fallback
      final tempId = DateTime.now().millisecondsSinceEpoch;

      final cartItem = CartItem(
        id: tempId,
        productId: productId,
        name: name,
        price: price,
        imageUrl: imageUrl,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
        quantity: quantity,
      );

      _items.removeWhere((e) => e.uniqueKey == cartItem.uniqueKey);
      _items.add(cartItem);
      _itemMap[cartItem.uniqueKey] = cartItem;

      notifyListeners();
      await _saveCartLocally();
    }
  }

  // ================= UPDATE =================
  Future<void> updateQuantity(int index, int newQuantity) async {
    if (index < 0 || index >= _items.length) return;

    final item = _items[index];

    if (newQuantity <= 0) {
      await removeItem(index);
      return;
    }

    try {
      // ✅ ВАЖНО
      await _cartService.updateCartItem(
        cartItemId: item.id,
        newQuantity: newQuantity,
      );

      item.quantity = newQuantity;
      notifyListeners();
      await _saveCartLocally();
    } catch (_) {
      // можно добавить fallback если нужно
    }
  }

  // ================= REMOVE =================
  Future<void> removeItem(int index) async {
    if (index < 0 || index >= _items.length) return;

    final item = _items[index];

    try {
      // ✅ ВАЖНО
      await _cartService.deleteCartItem(cartItemId: item.id);
    } catch (_) {
      // offline fallback: всё равно удалим локально
    }

    _items.removeAt(index);
    _itemMap.remove(item.uniqueKey);
    notifyListeners();
    await _saveCartLocally();
  }

  // ================= CLEAR =================
  Future<void> clearCart() async {
    try {
      // ✅ ВАЖНО
      await _cartService.clearCart();
    } catch (_) {
      // offline fallback
    }

    _items.clear();
    _itemMap.clear();
    notifyListeners();
    await _saveCartLocally();
  }

  // ================= LOCAL CACHE =================
  Future<void> _saveCartLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('local_cart', jsonData);
  }

  Future<void> _loadCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('local_cart');
    if (jsonData == null) return;

    final List<dynamic> data = jsonDecode(jsonData) as List<dynamic>;

    _items.clear();
    _itemMap.clear();

    for (final e in data) {
      final cartItem = CartItem.fromJson(Map<String, dynamic>.from(e as Map));
      _items.add(cartItem);
      _itemMap[cartItem.uniqueKey] = cartItem;
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _webSocketService.disconnect();
    super.dispose();
  }
}
