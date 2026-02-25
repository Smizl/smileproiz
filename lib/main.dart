import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Screens
import 'package:smileproiz/screens/home_screen.dart';
import 'package:smileproiz/screens/catalog_screen.dart';
import 'package:smileproiz/screens/product_screen.dart';
import 'package:smileproiz/screens/cart_screen.dart';
import 'package:smileproiz/screens/profile_screen.dart';
import 'package:smileproiz/screens/checkout_screen.dart';
import 'package:smileproiz/screens/login_screen.dart';
import 'package:smileproiz/screens/register_screen.dart';
import 'package:smileproiz/screens/admin_screen.dart';
import 'package:smileproiz/screens/delivery_addresses_screen.dart';
import 'package:smileproiz/screens/payment_methods_screen.dart';
import 'package:smileproiz/screens/account_settings_screen.dart';

// Providers
import 'package:smileproiz/provider/cart_provider.dart';
import 'package:smileproiz/provider/profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Инициализация FCM только для Android
  if (defaultTargetPlatform == TargetPlatform.android) {
    await _initFCM();
  } else {
    // На iOS с бесплатным Apple ID пуши отключены
    print('FCM отключён на iOS с бесплатным Apple ID');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Инициализация Firebase Cloud Messaging для Android
Future<void> _initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Запрос разрешений для уведомлений
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // Получение FCM токена
  try {
    String? token = await messaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      // TODO: отправить токен на сервер
    } else {
      print('FCM token is null, повторная попытка позже');
    }
  } catch (e) {
    print('Ошибка получения FCM токена: $e');
  }

  // Обработка сообщений в фоне
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Обработка сообщений в foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Получено сообщение в foreground: ${message.messageId}');
  });
}

/// Фоновый обработчик сообщений
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Получено сообщение в background: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MØRK STORE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00FF87),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        fontFamily: 'SF Pro Display',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF87),
          secondary: Color(0xFF00D9FF),
          surface: Color(0xFF1A1A1A),
          background: Color(0xFF0A0A0A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0A),
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/catalog': (context) => const CatalogScreen(),
        '/cart': (context) => const CartScreen(),
        '/admin': (context) => const AdminScreen(),
        '/delivery-addresses': (context) => const DeliveryAddressesScreen(),
        '/payment-methods': (context) => const PaymentMethodsScreen(),
        '/account-settings': (context) => const AccountSettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product') {
          return MaterialPageRoute(
            builder: (context) => const ProductScreen(),
            settings: settings,
          );
        }
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      },
    );
  }
}
