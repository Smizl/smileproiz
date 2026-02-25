import 'package:flutter/material.dart';
import 'admin_products_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_users_screen.dart';
import 'admin_orders_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
 
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminProductsScreen(),
    AdminCategoriesScreen(),
    AdminUsersScreen(),
    AdminOrdersScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Админка MØRK STORE')),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Товары'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Категории'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Пользователи'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Заказы'),
        ],
      ),
    );
  }
}
