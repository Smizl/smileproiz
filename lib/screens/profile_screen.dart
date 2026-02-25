import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert'; // для jsonEncode / jsonDecode
import 'package:shared_preferences/shared_preferences.dart'; // для SharedPreferences

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final api = ApiService();
  bool isLoggedIn = false;
  String userName = 'GUEST USER';
  String userEmail = 'guest@mork.store';
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true; // Сохраняем состояние при переключении вкладок

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    loadProfile().whenComplete(() {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('user_profile');

    if (cached != null) {
      final cachedMap = jsonDecode(cached);
      final cachedData = cachedMap['data'] != null
          ? Map<String, dynamic>.from(cachedMap['data'])
          : cachedMap;

      print('Cached user data: $cachedData');
      if (!mounted) return;
      setState(() {
        userName =
            (cachedData['username'] ??
                    cachedData['name'] ??
                    cachedData['userName'] ??
                    'USER')
                .toString();
        userEmail =
            (cachedData['email'] ??
                    cachedData['user_email'] ??
                    cachedData['mail'] ??
                    'guest@mork.store')
                .toString();
        isLoggedIn = true;
      });
    }

    try {
      final freshProfileRaw =
          await api.getUserProfile() ?? await api.getUserData();

      if (freshProfileRaw != null) {
        final Map<String, dynamic> profileMap = Map<String, dynamic>.from(
          freshProfileRaw,
        );
        final Map<String, dynamic> actualData = profileMap['data'] != null
            ? Map<String, dynamic>.from(profileMap['data'])
            : profileMap;

        print('Fresh user data: $actualData');
        if (!mounted) return;

        setState(() {
          userName =
              (actualData['username'] ??
                      actualData['name'] ??
                      actualData['userName'] ??
                      'USER')
                  .toString();
          userEmail =
              (actualData['email'] ??
                      actualData['user_email'] ??
                      actualData['mail'] ??
                      'guest@mork.store')
                  .toString();
          isLoggedIn = true;
        });

        prefs.setString('user_profile', jsonEncode(profileMap));
      }
    } catch (e) {
      debugPrint('Ошибка загрузки профиля: $e');
    }
  }

  Future<void> _checkLoginStatus() async {
    setState(() => _isLoading = true);
    final loggedIn = await api.isLoggedIn();

    if (!mounted) return;

    Map<String, dynamic>? userData;
    try {
      if (loggedIn) {
        final raw = await api.getUserProfile() ?? await api.getUserData();
        if (raw != null) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
          userData = map['data'] != null
              ? Map<String, dynamic>.from(map['data'])
              : map;
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      userData = null;
    }

    if (!mounted) return;

    setState(() {
      isLoggedIn = loggedIn;
      _isLoading = false;

      if (loggedIn && userData != null) {
        userName =
            (userData['username'] ??
                    userData['name'] ??
                    userData['userName'] ??
                    'USER')
                .toString();
        userEmail =
            (userData['email'] ??
                    userData['user_email'] ??
                    userData['mail'] ??
                    'guest@mork.store')
                .toString();
      } else {
        userName = 'GUEST USER';
        userEmail = 'guest@mork.store';
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final raw = await api.getUserProfile() ?? await api.getUserData();
      if (raw == null || !mounted) return;

      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      final Map<String, dynamic> actualData = map['data'] != null
          ? Map<String, dynamic>.from(map['data'])
          : map;

      setState(() {
        userName = (actualData['username'] ?? actualData['name'] ?? 'USER')
            .toString();
        userEmail = (actualData['email'] ?? 'guest@mork.store').toString();
        isLoggedIn = true;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'ВЫХОД',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        content: const Text(
          'Вы уверены, что хотите выйти?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ОТМЕНА',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await api.logout();
              if (mounted) {
                Navigator.pop(context);
                setState(() {
                  isLoggedIn = false;
                  userName = 'GUEST USER';
                  userEmail = 'guest@mork.store';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF00FF87)),
                        SizedBox(width: 12),
                        Text('Вы успешно вышли'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF1A1A1A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'ВЫЙТИ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateAndRefresh(String route) async {
    await Navigator.pushNamed(context, route);

    if (!mounted) return;

    await _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Для AutomaticKeepAliveClientMixin

    // Показываем загрузку при проверке статуса
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
              ),
              const SizedBox(height: 20),
              Text(
                'Загрузка профиля...',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (!isLoggedIn) {
      return _buildGuestView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF00FF87).withOpacity(0.3),
                      const Color(0xFF0A0A0A),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FF87), Color(0xFF00D9FF)],
                          ),
                          border: Border.all(color: Colors.black, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF87).withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('👤', style: TextStyle(fontSize: 50)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Статистика
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildStatCard(
                    '15',
                    'ЗАКАЗОВ',
                    Icons.shopping_bag,
                    const Color(0xFFFF6B6B),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    '8',
                    'ОТЗЫВОВ',
                    Icons.star,
                    const Color(0xFFFFE66D),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    '23',
                    'ИЗБРАННОЕ',
                    Icons.favorite,
                    const Color(0xFF4ECDC4),
                  ),
                ],
              ),
            ),
          ),

          // Меню
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'НАСТРОЙКИ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    'Адреса доставки',
                    Icons.location_on,
                    const Color(0xFF00D9FF),
                    () => _navigateAndRefresh('/delivery-addresses'),
                  ),
                  _buildMenuItem(
                    'Способы оплаты',
                    Icons.payment,
                    const Color(0xFFFFE66D),
                    () => _navigateAndRefresh('/payment-methods'),
                  ),
                  _buildMenuItem(
                    'Настройки аккаунта',
                    Icons.settings,
                    Colors.grey,
                    () async {
                      // Переходим на страницу редактирования профиля
                      final updated = await Navigator.pushNamed(
                        context,
                        '/account-settings',
                      );
                      if (updated is bool && updated) {
                        await _loadUserData();
                      }
                    },
                  ),

                  const SizedBox(height: 24),
                  _buildMenuItem(
                    'Выйти',
                    Icons.logout,
                    const Color(0xFFFF6B6B),
                    _logout,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Иконка профиля
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A1A1A),
                      border: Border.all(color: Colors.grey[900]!, width: 3),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 60,
                      color: Colors.grey[700],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Заголовок
                const Center(
                  child: Text(
                    'ВОЙДИТЕ В АККАУНТ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: Text(
                    'Получите доступ ко всем функциям',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),

                const SizedBox(height: 40),

                // Преимущества
                _buildFeatureItem(
                  icon: Icons.shopping_bag,
                  title: 'История заказов',
                  description: 'Отслеживайте все ваши покупки',
                ),

                const SizedBox(height: 16),

                _buildFeatureItem(
                  icon: Icons.favorite,
                  title: 'Избранное',
                  description: 'Сохраняйте понравившиеся товары',
                ),

                const SizedBox(height: 16),

                _buildFeatureItem(
                  icon: Icons.local_shipping,
                  title: 'Быстрая доставка',
                  description: 'Сохраненные адреса для быстрого оформления',
                ),

                const SizedBox(height: 16),

                _buildFeatureItem(
                  icon: Icons.notifications_active,
                  title: 'Уведомления',
                  description: 'Узнавайте первыми о новинках и скидках',
                ),

                const SizedBox(height: 40),

                // Кнопка входа
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/login',
                      );

                      if (result == true) {
                        await loadProfile(); // 🔥 обновляем профиль из prefs
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF87),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF00FF87).withOpacity(0.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'ВОЙТИ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Кнопка регистрации
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/register');
                      // 🆕 Обновляем статус после возврата
                      _checkLoginStatus();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00FF87),
                      side: const BorderSide(
                        color: Color(0xFF00FF87),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'РЕГИСТРАЦИЯ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Продолжить как гость
                Center(
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Вы используете приложение как гость',
                          ),
                          backgroundColor: const Color(0xFF1A1A1A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Продолжить как гость',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[900]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF00FF87).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00FF87), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[900]!, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[900]!, width: 1),
      ),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[700],
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
