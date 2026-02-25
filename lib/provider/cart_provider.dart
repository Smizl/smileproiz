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
    id: json['id'],
    productId: json['productId'],
    name: json['name'],
    price: json['price'],
    imageUrl: json['imageUrl'],
    selectedSize: json['selectedSize'],
    selectedColor: json['selectedColor'],
    quantity: json['quantity'],
  );

  /// Уникальный ключ для быстрого поиска
  String get uniqueKey => '$productId-$selectedSize-$selectedColor';
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final Map<String, CartItem> _itemMap = {};
  final CartWebSocketService _webSocketService = CartWebSocketService();
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

  void _initialize() async {
    await loadCart();
    _connectWebSocket();
  }

  // ================= WebSocket =================
  void _connectWebSocket() {
    _webSocketService.connect();

    _wsSubscription = _webSocketService.stream.listen(
      (data) {
        _resetReconnectAttempts();
        if (data['type'] == 'cart_update') loadCart();
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
      final serverItems = await CartService.getCartItems(
        timeout: const Duration(seconds: 5),
      );

      _items.clear();
      _itemMap.clear();

      for (final item in serverItems) {
        final product = item['product'];
        final cartItem = CartItem(
          id: item['id'],
          productId: product['id'],
          name: product['name'],
          price: product['price'],
          imageUrl: product['imageUrl'],
          selectedSize: item['selectedSize'] ?? '',
          selectedColor: item['selectedColor'] ?? '',
          quantity: item['quantity'] ?? 1,
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
      final serverItem = await CartService.addToCart(
        productId: productId,
        quantity: quantity,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
      );

      final cartItem = CartItem(
        id: serverItem['id'],
        productId: serverItem['product']['id'],
        name: serverItem['product']['name'],
        price: serverItem['product']['price'],
        imageUrl: serverItem['product']['imageUrl'],
        selectedSize: selectedSize,
        selectedColor: selectedColor,
        quantity: quantity, // всегда сбрасываем на добавленное количество
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
      await CartService.updateCartItem(
        cartItemId: item.id,
        newQuantity: newQuantity,
      );

      item.quantity = newQuantity;
      notifyListeners();
      await _saveCartLocally();
    } catch (_) {}
  }

  // ================= REMOVE =================
  Future<void> removeItem(int index) async {
    if (index < 0 || index >= _items.length) return;

    final item = _items[index];

    try {
      await CartService.deleteCartItem(cartItemId: item.id);
    } catch (_) {}

    _items.removeAt(index);
    _itemMap.remove(item.uniqueKey);
    notifyListeners();
    await _saveCartLocally();
  }

  // ================= CLEAR =================
  Future<void> clearCart() async {
    try {
      await CartService.clearCart();
    } catch (_) {}

    _items.clear();
    _itemMap.clear();
    notifyListeners();
    await _saveCartLocally();
  }

  Future<void> _saveCartLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('local_cart', jsonData);
  }

  Future<void> _loadCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('local_cart');
    if (jsonData == null) return;

    final List<dynamic> data = jsonDecode(jsonData);
    _items.clear();
    _itemMap.clear();

    for (final e in data) {
      final cartItem = CartItem.fromJson(e);
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
