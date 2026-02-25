import 'dart:convert'; // для jsonDecode/jsonEncode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; // твой ApiService
import 'package:firebase_messaging/firebase_messaging.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // Settings state
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _marketingEmails = true;
  String? _fcmToken;
  int? _userId; // теперь совпадает с ApiService
  // если у тебя id хранится
  String _language = 'Русский';
  String _currency = '₸ (Тенге)';
  String _userName = 'USER';
  String _userEmail = 'guest@mork.store';
  String _userPhone = '';
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _initFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 🔹 Запрос разрешений на iOS
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('FCM permission status: ${settings.authorizationStatus}');

      // 🔹 Получаем текущий токен
      _fcmToken = await messaging.getToken();
      print('FCM Token: $_fcmToken');

      // 🔹 Отправляем токен на сервер, если есть пользователь
      if (_fcmToken != null && _userId != null) {
        final api = ApiService();
        await api.updatePushToken(_userId!, _fcmToken!);
        print('FCM Token отправлен на сервер');
      }

      // 🔹 Слушаем обновление токена (например, после переустановки приложения)
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        print('FCM Token обновлён: $newToken');

        if (_userId != null) {
          final api = ApiService();
          await api.updatePushToken(_userId!, newToken);
          print('Обновлённый FCM Token отправлен на сервер');
        }
      });

      // 🔹 Обработка уведомлений в foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (!mounted) return;

        if (message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.notification!.body ?? ''),
              backgroundColor: const Color(0xFF1A1A1A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          print('FCM foreground message: ${message.notification!.title}');
        }
      });
    } catch (e) {
      print('FCM disabled: $e');
    }
  }

  Future<void> _updateUserField({
    String? name,
    String? email,
    String? phone,
    String? password,
  }) async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user');
      if (raw == null || raw.isEmpty) return;

      final localUser = Map<String, dynamic>.from(jsonDecode(raw));
      final int? userId = localUser['id'] != null
          ? int.tryParse(localUser['id'].toString())
          : null;

      if (userId == null) return;

      final api = ApiService();

      // ✅ обновляем на сервере
      if (name != null) {
        final result = await api.updateUsername(userId, name);
        if (result['success'] != true)
          throw Exception(result['message'] ?? 'Ошибка');
      }

      if (email != null) {
        final result = await api.updateEmail(userId, email);
        if (result['success'] != true)
          throw Exception(result['message'] ?? 'Ошибка');
      }

      if (phone != null) {
        final result = await api.updatePhone(userId, phone);
        if (result['success'] != true) {
          throw Exception(result['message'] ?? 'Ошибка');
        }

        // ✅ важно: обновляем локальный user в prefs
        localUser['phone'] = phone;
        await prefs.setString('user', jsonEncode(localUser));
      }

      if (password != null) {
        final result = await api.updatePassword(userId, password);
        if (result['success'] != true)
          throw Exception(result['message'] ?? 'Ошибка');
      }

      // ✅ берём СВЕЖЕГО пользователя из prefs (ApiService уже сохранил merged user)
      final updatedRaw = prefs.getString('user');
      final updatedUser = updatedRaw != null && updatedRaw.isNotEmpty
          ? Map<String, dynamic>.from(jsonDecode(updatedRaw))
          : localUser;

      // ✅ обновляем UI
      setState(() {
        _userName = (updatedUser['username'] ?? '').toString();
        _userEmail = (updatedUser['email'] ?? '').toString();
        _userPhone = (updatedUser['phone'] ?? '').toString();

        _nameController.text = _userName;
        _emailController.text = _userEmail;
        _phoneController.text = _userPhone.isNotEmpty ? _userPhone : '+7';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF00FF87)),
              SizedBox(width: 12),
              Expanded(child: Text('Данные успешно обновлены')),
            ],
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(child: Text('Ошибка при обновлении: $e')),
            ],
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _changePhone() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _ChangePhoneDialog(controller: _phoneController),
    );

    if (result != null && result.trim().isNotEmpty) {
      final newPhone = result.trim();

      // ✅ мгновенно обновили UI
      setState(() {
        _userPhone = newPhone;
        _phoneController.text = newPhone;
      });

      // ✅ потом уже отправили на сервер + сохранили
      await _updateUserField(phone: newPhone);
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('user');
    Map<String, dynamic>? localUser;
    if (storedUser != null && storedUser.isNotEmpty) {
      try {
        localUser = Map<String, dynamic>.from(jsonDecode(storedUser));
      } catch (_) {
        localUser = null;
      }
    }

    final api = ApiService();
    final userData = await api.getUserProfile() ?? await api.getUserData();

    if (!mounted) return;

    setState(() {
      _userName = userData?['username'] ?? localUser?['username'] ?? '';
      _userEmail = userData?['email'] ?? localUser?['email'] ?? '';

      final freshPhone = userData?['phone']?.toString();
      final cachedPhone = localUser?['phone']?.toString();

      if (freshPhone != null && freshPhone.isNotEmpty) {
        _userPhone = freshPhone;
      } else if (_userPhone.isEmpty &&
          cachedPhone != null &&
          cachedPhone.isNotEmpty) {
        _userPhone = cachedPhone;
      }

      _userId = userData?['id'] != null
          ? int.tryParse(userData!['id'].toString())
          : (localUser?['id'] != null
                ? int.tryParse(localUser!['id'].toString())
                : null);

      _nameController.text = _userName;
      _emailController.text = _userEmail;
      _phoneController.text = _userPhone.isNotEmpty ? _userPhone : '+7';
    });

    await _initFCM();
  }

  void _changePassword() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _ChangePasswordDialog(),
    );

    if (result != null && result.trim().isNotEmpty) {
      await _updateUserField(password: result.trim());
    }
  }

  void _changeName() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _ChangeNameDialog(controller: _nameController),
    );

    if (result != null && result.trim().isNotEmpty) {
      await _updateUserField(name: result.trim());
    }
  }

  void _changeEmail() async {
    // Передаём контроллер с актуальным email
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _ChangeEmailDialog(controller: _emailController),
    );

    if (result != null && result.trim().isNotEmpty) {
      await _updateUserField(email: result.trim());
    }
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'УДАЛИТЬ АККАУНТ?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        content: const Text(
          'Это действие необратимо. Все ваши данные будут удалены без возможности восстановления.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ОТМЕНА', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Для удаления аккаунта свяжитесь с поддержкой',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFFFF6B6B),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('УДАЛИТЬ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'НАСТРОЙКИ АККАУНТА',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Профиль
            _buildSection('ПРОФИЛЬ'),
            _buildMenuItem(
              'Изменить имя',
              _userName, // ✅ динамическое
              Icons.person,
              const Color(0xFF00FF87),
              _changeName,
            ),
            _buildMenuItem(
              'Email',
              _userEmail, // ✅ динамическое
              Icons.email,
              const Color(0xFF00D9FF),
              _changeEmail,
            ),

            _buildMenuItem(
              'Телефон',
              _userPhone.isNotEmpty ? _userPhone : 'Добавить телефон',
              Icons.phone,
              const Color(0xFFFFE66D),
              _changePhone,
            ),

            _buildMenuItem(
              'Изменить пароль',
              '••••••••',
              Icons.lock,
              const Color(0xFF4ECDC4),
              _changePassword,
            ),

            const SizedBox(height: 24),

            // Уведомления
            _buildSection('УВЕДОМЛЕНИЯ'),
            _buildSwitchTile(
              'Email уведомления',
              'Получать письма о заказах и акциях',
              Icons.email,
              const Color(0xFF00FF87),
              _emailNotifications,
              (value) => setState(() => _emailNotifications = value),
            ),
            _buildSwitchTile(
              'Push уведомления',
              'Уведомления в приложении',
              Icons.notifications,
              const Color(0xFF00D9FF),
              _pushNotifications,
              (value) async {
                setState(() => _pushNotifications = value);

                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('pushNotifications', value);

                final api = ApiService();
                if (_userId != null) {
                  await api.updatePushSetting(_userId!, value);
                }
              },
            ),

            _buildSwitchTile(
              'SMS уведомления',
              'СМС о статусе заказа',
              Icons.sms,
              const Color(0xFFFFE66D),
              _smsNotifications,
              (value) => setState(() => _smsNotifications = value),
            ),
            _buildSwitchTile(
              'Маркетинговые рассылки',
              'Новинки, скидки и персональные предложения',
              Icons.local_offer,
              const Color(0xFF4ECDC4),
              _marketingEmails,
              (value) => setState(() => _marketingEmails = value),
            ),

            const SizedBox(height: 24),

            // Предпочтения
            _buildSection('ПРЕДПОЧТЕНИЯ'),
            _buildDropdownMenuItem(
              'Язык',
              _language,
              Icons.language,
              const Color(0xFF00FF87),
              ['Русский', 'English', 'Қазақша'],
              (value) => setState(() => _language = value!),
            ),
            _buildDropdownMenuItem(
              'Валюта',
              _currency,
              Icons.attach_money,
              const Color(0xFF00D9FF),
              ['₸ (Тенге)', '\$ (Dollar)', '€ (Euro)'],
              (value) => setState(() => _currency = value!),
            ),

            const SizedBox(height: 24),

            // Опасная зона
            _buildSection('ОПАСНАЯ ЗОНА', color: const Color(0xFFFF6B6B)),
            _buildDangerMenuItem(
              'Удалить аккаунт',
              'Безвозвратное удаление всех данных',
              Icons.delete_forever,
              _deleteAccount,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, {Color color = const Color(0xFF00FF87)}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[900]!, width: 1),
      ),
      child: SwitchListTile(
        secondary: Container(
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
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        value: value,
        activeColor: color,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownMenuItem(
    String title,
    String value,
    IconData icon,
    Color color,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          ),
        ),
        trailing: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF2A2A2A),
          style: const TextStyle(color: Colors.white),
          underline: Container(),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00FF87)),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDangerMenuItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFFF6B6B).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete_forever,
            color: Color(0xFFFF6B6B),
            size: 24,
          ),
        ),
        title: const Text(
          'Удалить аккаунт',
          style: TextStyle(
            color: Color(0xFFFF6B6B),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFFFF6B6B),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}

// Диалог изменения пароля
class _ChangePasswordDialog extends StatefulWidget {
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController =
      TextEditingController(); // пока не используем на сервере
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'ИЗМЕНИТЬ ПАРОЛЬ',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Текущий пароль (сейчас нужен только для UI/валидации, сервер не проверяет)
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Текущий пароль',
                labelStyle: const TextStyle(color: Color(0xFF00FF87)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                  ),
                  color: Colors.grey[600],
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Введите текущий пароль'
                  : null,
            ),
            const SizedBox(height: 16),

            // Новый пароль
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Новый пароль',
                labelStyle: const TextStyle(color: Color(0xFF00FF87)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  color: Colors.grey[600],
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Введите новый пароль';
                if (v.length < 6) return 'Минимум 6 символов';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Подтверждение
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль',
                labelStyle: const TextStyle(color: Color(0xFF00FF87)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  color: Colors.grey[600],
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if ((value ?? '') != _newPasswordController.text) {
                  return 'Пароли не совпадают';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('ОТМЕНА', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;

            final newPassword = _newPasswordController.text.trim();
            if (newPassword.isEmpty) return;

            // ✅ Важно: тут НЕ делаем запросы на сервер
            // Просто возвращаем новый пароль наверх
            Navigator.pop(context, newPassword);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF87),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('СОХРАНИТЬ'),
        ),
      ],
    );
  }
}

// Диалог изменения имени
class _ChangeNameDialog extends StatelessWidget {
  final TextEditingController controller;
  const _ChangeNameDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'ИЗМЕНИТЬ ИМЯ',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      content: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF0A0A0A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('ОТМЕНА', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () {
            final newName = controller.text.trim();
            if (newName.isEmpty) return;
            Navigator.pop(context, newName); // ✅ возвращаем имя наверх
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF87),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('СОХРАНИТЬ'),
        ),
      ],
    );
  }
}

class _ChangeEmailDialog extends StatelessWidget {
  final TextEditingController controller; // ✅ берем из родителя
  const _ChangeEmailDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'ИЗМЕНИТЬ EMAIL',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      content: TextFormField(
        controller: controller, // ✅ вот тут
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF0A0A0A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('ОТМЕНА', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () {
            final newEmail = controller.text.trim();
            if (newEmail.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Email не может быть пустым')),
              );
              return;
            }
            Navigator.pop(context, newEmail); // возвращаем новое значение
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF87),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('СОХРАНИТЬ'),
        ),
      ],
    );
  }
}

class _ChangePhoneDialog extends StatelessWidget {
  final TextEditingController controller;
  const _ChangePhoneDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'ИЗМЕНИТЬ ТЕЛЕФОН',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      content: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '+7 (___) ___-__-__',
          filled: true,
          fillColor: const Color(0xFF0A0A0A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('ОТМЕНА', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () {
            final newPhone = controller.text.trim();
            if (newPhone.isEmpty) return;
            Navigator.pop(context, newPhone); // ✅ вернуть телефон
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF87),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('СОХРАНИТЬ'),
        ),
      ],
    );
  }
}
