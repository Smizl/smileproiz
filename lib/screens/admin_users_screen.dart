import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> users = [
    {
      'id': '1',
      'name': 'Садибекова Замира',
      'email': 'alexey@mail.com',
      'phone': '+7 777 123 45 67',
      'orders': 15,
      'totalSpent': 125000,
      'registeredAt': '2024-01-15',
      'isBlocked': false,
    },
    {
      'id': '2',
      'name': 'Актаева Амина',
      'email': 'maria@mail.com',
      'phone': '+7 777 987 65 43',
      'orders': 8,
      'totalSpent': 68000,
      'registeredAt': '2024-02-20',
      'isBlocked': false,
    },
    {
      'id': '3',
      'name': 'Бекишев Алибек',
      'email': 'dmitry@mail.com',
      'phone': '+7 777 555 12 34',
      'orders': 23,
      'totalSpent': 198000,
      'registeredAt': '2023-12-10',
      'isBlocked': false,
    },
  ];

  String _searchQuery = '';
  String _filterStatus = 'Все';

  void _toggleBlockUser(String id) {
    setState(() {
      final index = users.indexWhere((u) => u['id'] == id);
      if (index != -1) {
        users[index]['isBlocked'] = !users[index]['isBlocked'];
        _showSnackBar(
          users[index]['isBlocked']
              ? 'Пользователь заблокирован'
              : 'Пользователь разблокирован',
          !users[index]['isBlocked'],
        );
      }
    });
  }

  void _deleteUser(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'УДАЛИТЬ ПОЛЬЗОВАТЕЛЯ?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        content: const Text(
          'Это действие нельзя отменить. Все данные пользователя будут удалены.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ОТМЕНА', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                users.removeWhere((u) => u['id'] == id);
              });
              Navigator.pop(context);
              _showSnackBar('Пользователь удален', false);
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

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00FF87), Color(0xFF00D9FF)],
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          user['email'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow(Icons.phone, 'Телефон', user['phone']),
              _buildInfoRow(Icons.shopping_bag, 'Заказов', '${user['orders']}'),
              _buildInfoRow(
                Icons.attach_money,
                'Потрачено',
                '${user['totalSpent']}₸',
              ),
              _buildInfoRow(
                Icons.calendar_today,
                'Регистрация',
                user['registeredAt'],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'ЗАКРЫТЬ',
                      style: TextStyle(color: Color(0xFF00FF87)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00FF87), size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.block,
              color: isSuccess
                  ? const Color(0xFF00FF87)
                  : const Color(0xFFFF6B6B),
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<Map<String, dynamic>> get filteredUsers {
    return users.where((user) {
      final matchesSearch =
          user['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          user['email'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesFilter =
          _filterStatus == 'Все' ||
          (_filterStatus == 'Активные' && !user['isBlocked']) ||
          (_filterStatus == 'Заблокированные' && user['isBlocked']);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredUsers;

    return Column(
      children: [
        // Поиск и фильтры
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            border: Border(
              bottom: BorderSide(color: Colors.grey[900]!, width: 1),
            ),
          ),
          child: Column(
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Поиск пользователей...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF00FF87),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFilterChip('Все'),
                  _buildFilterChip('Активные'),
                  _buildFilterChip('Заблокированные'),
                ],
              ),
            ],
          ),
        ),

        // Статистика
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatCard(
                icon: Icons.people,
                value: users.length.toString(),
                label: 'Всего',
                color: const Color(0xFF00FF87),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.check_circle,
                value: users.where((u) => !u['isBlocked']).length.toString(),
                label: 'Активные',
                color: const Color(0xFF4ECDC4),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.block,
                value: users.where((u) => u['isBlocked']).length.toString(),
                label: 'Блок',
                color: const Color(0xFFFF6B6B),
              ),
            ],
          ),
        ),

        // Список пользователей
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[800],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Пользователи не найдены',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    return _buildUserCard(user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterStatus = label;
          });
        },
        backgroundColor: const Color(0xFF2A2A2A),
        selectedColor: const Color(0xFF00FF87),
        checkmarkColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[900]!, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: user['isBlocked']
              ? const Color(0xFFFF6B6B)
              : Colors.grey[900]!,
          width: user['isBlocked'] ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: user['isBlocked']
                  ? [const Color(0xFFFF6B6B), const Color(0xFFFF8C94)]
                  : [const Color(0xFF00FF87), const Color(0xFF00D9FF)],
            ),
          ),
          child: Icon(
            user['isBlocked'] ? Icons.block : Icons.person,
            color: Colors.black,
            size: 24,
          ),
        ),
        title: Text(
          user['name'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user['email'],
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.shopping_bag, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${user['orders']} заказов',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
                const SizedBox(width: 12),
                Text(
                  '${user['totalSpent']}₸',
                  style: const TextStyle(
                    color: Color(0xFF00FF87),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF2A2A2A),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.info, color: Color(0xFF00D9FF), size: 20),
                  SizedBox(width: 12),
                  Text('Подробнее', style: TextStyle(color: Colors.white)),
                ],
              ),
              onTap: () {
                Future.delayed(Duration.zero, () => _showUserDetails(user));
              },
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(
                    user['isBlocked'] ? Icons.check_circle : Icons.block,
                    color: user['isBlocked']
                        ? const Color(0xFF00FF87)
                        : const Color(0xFFFFE66D),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    user['isBlocked'] ? 'Разблокировать' : 'Заблокировать',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              onTap: () {
                Future.delayed(
                  Duration.zero,
                  () => _toggleBlockUser(user['id']),
                );
              },
            ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, color: Color(0xFFFF6B6B), size: 20),
                  SizedBox(width: 12),
                  Text('Удалить', style: TextStyle(color: Colors.white)),
                ],
              ),
              onTap: () {
                Future.delayed(Duration.zero, () => _deleteUser(user['id']));
              },
            ),
          ],
        ),
      ),
    );
  }
}
