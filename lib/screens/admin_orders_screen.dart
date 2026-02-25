import 'package:flutter/material.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<Map<String, dynamic>> orders = [
    {
      'id': '#001234',
      'userName': 'Садибекова Замира',
      'userEmail': 'zamira@mail.com',
      'date': '2024-03-15',
      'total': 35000,
      'status': 'Новый',
      'items': 3,
      'paymentMethod': 'Карта',
      'deliveryAddress': 'г. Астана, ул. Абая, 123',
    },
    {
      'id': '#001235',
      'userName': 'Актаева Амина',
      'userEmail': 'amina@mail.com',
      'date': '2024-03-14',
      'total': 28000,
      'status': 'В обработке',
      'items': 2,
      'paymentMethod': 'Kaspi',
      'deliveryAddress': 'г. Астана, пр. Кабанбай Батыра, 45',
    },
    {
      'id': '#001236',
      'userName': 'Бекишев Алибек',
      'userEmail': 'ali.bekish@gmail.com',
      'date': '2024-03-13',
      'total': 12500,
      'status': 'Доставляется',
      'items': 1,
      'paymentMethod': 'Наличные',
      'deliveryAddress': 'г. Шымкент, ул. Тауке хана, 89',
    },
    {
      'id': '#001237',
      'userName': 'Берикова Аружан',
      'userEmail': 'aruzhan@mail.com',
      'date': '2024-03-12',
      'total': 45000,
      'status': 'Выполнен',
      'items': 4,
      'paymentMethod': 'Карта',
      'deliveryAddress': 'г. Алматы, мкр. Самал-2, 78',
    },
    {
      'id': '#001238',
      'userName': 'Ли Амир',
      'userEmail': 'amir.lee@gmail.com',
      'date': '2024-03-11',
      'total': 18000,
      'status': 'Отменен',
      'items': 2,
      'paymentMethod': 'Kaspi',
      'deliveryAddress': 'г. Караганда, ул. Ерубаева, 12',
    },
  ];

  String _searchQuery = '';
  String _filterStatus = 'Все';

  final List<String> statuses = [
    'Новый',
    'В обработке',
    'Доставляется',
    'Выполнен',
    'Отменен',
  ];

  void _changeOrderStatus(Map<String, dynamic> order, String newStatus) {
    setState(() {
      order['status'] = newStatus;
    });
    _showSnackBar('Статус заказа ${order['id']} изменен на "$newStatus"', true);
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FF87), Color(0xFF00D9FF)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order['id'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(order['status']),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Клиент', order['userName']),
                _buildDetailRow('Email', order['userEmail']),
                _buildDetailRow('Дата', order['date']),
                _buildDetailRow('Товаров', '${order['items']} шт.'),
                _buildDetailRow('Оплата', order['paymentMethod']),
                _buildDetailRow('Адрес', order['deliveryAddress']),
                const Divider(color: Colors.grey, height: 32),
                _buildDetailRow('ИТОГО', '${order['total']}₸', isTotal: true),
                const SizedBox(height: 24),
                const Text(
                  'ИЗМЕНИТЬ СТАТУС',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: statuses.map((status) {
                    final isSelected = order['status'] == status;
                    return GestureDetector(
                      onTap: () {
                        _changeOrderStatus(order, status);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getStatusColor(status)
                              : const Color(0xFF0A0A0A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(status),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isTotal ? const Color(0xFF00FF87) : Colors.white,
                fontSize: isTotal ? 20 : 14,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
              ),
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
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess
                  ? const Color(0xFF00FF87)
                  : const Color(0xFFFF6B6B),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<Map<String, dynamic>> get filteredOrders {
    return orders.where((order) {
      final matchesSearch =
          order['id'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          order['userName'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesFilter =
          _filterStatus == 'Все' || order['status'] == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Новый':
        return const Color(0xFF00D9FF);
      case 'В обработке':
        return const Color(0xFFFFE66D);
      case 'Доставляется':
        return const Color(0xFF00FF87);
      case 'Выполнен':
        return const Color(0xFF4ECDC4);
      case 'Отменен':
        return const Color(0xFFFF6B6B);
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredOrders;
    final totalRevenue = orders.fold<int>(
      0,
      (sum, order) => sum + (order['total'] as int),
    );

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
                  hintText: 'Поиск заказов...',
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Все'),
                    _buildFilterChip('Новый'),
                    _buildFilterChip('В обработке'),
                    _buildFilterChip('Доставляется'),
                    _buildFilterChip('Выполнен'),
                    _buildFilterChip('Отменен'),
                  ],
                ),
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
                icon: Icons.receipt_long,
                value: orders.length.toString(),
                label: 'Заказов',
                color: const Color(0xFF00FF87),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.pending_actions,
                value: orders
                    .where((o) => o['status'] == 'Новый')
                    .length
                    .toString(),
                label: 'Новые',
                color: const Color(0xFF00D9FF),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.attach_money,
                value: '${(totalRevenue / 1000).toStringAsFixed(0)}K',
                label: 'Выручка',
                color: const Color(0xFFFFE66D),
              ),
            ],
          ),
        ),

        // Список заказов
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: Colors.grey[800],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Заказы не найдены',
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
                    final order = filtered[index];
                    return _buildOrderCard(order);
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
        selectedColor: _getStatusColor(label),
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return GestureDetector(
      onTap: () => _showOrderDetails(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[900]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    order['id'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusBadge(order['status']),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    order['userName'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    order['date'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.shopping_bag, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${order['items']} товаров',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order['total']}₸',
                    style: const TextStyle(
                      color: Color(0xFF00FF87),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  DropdownButton<String>(
                    value: order['status'],
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    underline: Container(),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF00FF87),
                    ),
                    items: statuses
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _changeOrderStatus(order, value);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
