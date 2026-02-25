import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smileproiz/services/cart_service.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // mocktail требует fallback для Uri, если ты используешь any()
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  late MockClient mockClient;
  late CartService cartService;

  setUp(() async {
    // Мокаем SharedPreferences (чтобы не падало в тестах)
    SharedPreferences.setMockInitialValues({
      'api_host': 'http://localhost:8080',
      'token': 'test_token_123',
    });

    mockClient = MockClient();
    cartService = CartService(client: mockClient);
  });

  test('addToCart returns decoded response on success', () async {
    final responseBody = jsonEncode({"id": 1, "productId": 10, "quantity": 2});

    when(
      () => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => http.Response(responseBody, 200));

    final result = await cartService.addToCart(productId: 10, quantity: 2);

    expect(result['productId'], 10);
    expect(result['quantity'], 2);

    // бонус: проверим, что Authorization реально был
    final captured = verify(
      () => mockClient.post(
        captureAny(),
        headers: captureAny(named: 'headers'),
        body: captureAny(named: 'body'),
      ),
    ).captured;

    final headers = captured[1] as Map<String, String>;
    expect(headers['Authorization'], 'Bearer test_token_123');
  });

  // ✅ ТЕСТ №2: addToCart кидает Exception если статус не ок
  test('addToCart throws exception on non-200/201', () async {
    when(
      () => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => http.Response('Bad Request', 400));

    expect(
      () => cartService.addToCart(productId: 10, quantity: 2),
      throwsA(isA<Exception>()),
    );
  });

  // ✅ ТЕСТ №3: getCartItems парсит список
  test('getCartItems returns list of items on success', () async {
    final listBody = jsonEncode([
      {"id": 1, "productId": 10, "quantity": 2},
      {"id": 2, "productId": 11, "quantity": 1},
    ]);

    when(
      () => mockClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(listBody, 200));

    final items = await cartService.getCartItems();

    expect(items.length, 2);
    expect(items[0]['productId'], 10);
    expect(items[1]['quantity'], 1);

    // Проверим, что Authorization тоже ушёл
    final captured = verify(
      () => mockClient.get(captureAny(), headers: captureAny(named: 'headers')),
    ).captured;

    final headers = captured[1] as Map<String, String>;
    expect(headers['Authorization'], 'Bearer test_token_123');
  });
}
