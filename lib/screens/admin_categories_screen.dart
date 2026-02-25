import 'package:flutter/material.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  List<Map<String, dynamic>> categories = [
    {'id': '1', 'name': 'Одежда', 'icon': Icons.checkroom, 'count': 45},
    {'id': '2', 'name': 'Верхняя одежда', 'icon': Icons.ac_unit, 'count': 23},
    {'id': '3', 'name': 'Обувь', 'icon': Icons.chair, 'count': 38},
    {'id': '4', 'name': 'Аксессуары', 'icon': Icons.watch, 'count': 52},
  ];

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        onSave: (name, icon) {
          setState(() {
            categories.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'name': name,
              'icon': icon,
              'count': 0,
            });
          });
          _showSnackBar('Категория добавлена', true);
        },
      ),
    );
  }

  void _editCategory(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        category: category,
        onSave: (name, icon) {
          setState(() {
            final index = categories.indexWhere(
              (c) => c['id'] == category['id'],
            );
            if (index != -1) {
              categories[index]['name'] = name;
              categories[index]['icon'] = icon;
            }
          });
          _showSnackBar('Категория обновлена', true);
        },
      ),
    );
  }

  void _deleteCategory(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'УДАЛИТЬ КАТЕГОРИЮ?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        content: const Text(
          'Все товары этой категории останутся без категории',
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
                categories.removeWhere((c) => c['id'] == id);
              });
              Navigator.pop(context);
              _showSnackBar('Категория удалена', false);
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

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.delete_outline,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Заголовок и кнопка добавления
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            border: Border(
              bottom: BorderSide(color: Colors.grey[900]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'КАТЕГОРИИ ТОВАРОВ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Всего: ${categories.length}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add),
                label: const Text('ДОБАВИТЬ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF87),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Сетка категорий
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF2A2A2A).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[900]!, width: 1),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF87).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    category['icon'],
                    size: 32,
                    color: const Color(0xFF00FF87),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  category['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF87).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${category['count']} товаров',
                    style: const TextStyle(
                      color: Color(0xFF00FF87),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: const Color(0xFF2A2A2A),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.edit, color: Color(0xFF00D9FF), size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Редактировать',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(
                      Duration.zero,
                      () => _editCategory(category),
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
                    Future.delayed(
                      Duration.zero,
                      () => _deleteCategory(category['id']),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Диалог добавления/редактирования категории
class _CategoryDialog extends StatefulWidget {
  final Map<String, dynamic>? category;
  final Function(String name, IconData icon) onSave;

  const _CategoryDialog({this.category, required this.onSave});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  IconData _selectedIcon = Icons.category;

  final List<Map<String, dynamic>> availableIcons = [
    {'icon': Icons.checkroom, 'label': 'Одежда'},
    {'icon': Icons.ac_unit, 'label': 'Зимняя'},
    {'icon': Icons.chair, 'label': 'Обувь'},
    {'icon': Icons.watch, 'label': 'Аксессуары'},
    {'icon': Icons.shopping_bag, 'label': 'Сумки'},
    {'icon': Icons.face, 'label': 'Косметика'},
    {'icon': Icons.sports_basketball, 'label': 'Спорт'},
    {'icon': Icons.headphones, 'label': 'Электроника'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.category?['name'] ?? '',
    );
    _selectedIcon = widget.category?['icon'] ?? Icons.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category == null ? 'НОВАЯ КАТЕГОРИЯ' : 'РЕДАКТИРОВАТЬ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Название категории',
                    labelStyle: const TextStyle(color: Color(0xFF00FF87)),
                    prefixIcon: const Icon(
                      Icons.label,
                      color: Color(0xFF00FF87),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0A0A0A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите название';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Выберите иконку:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableIcons.map((item) {
                    final isSelected = _selectedIcon == item['icon'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = item['icon'];
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00FF87)
                              : const Color(0xFF0A0A0A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00FF87)
                                : Colors.grey[800]!,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          item['icon'],
                          color: isSelected
                              ? Colors.black
                              : const Color(0xFF00FF87),
                          size: 28,
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
                      child: Text(
                        'ОТМЕНА',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave(_nameController.text, _selectedIcon);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF87),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'СОХРАНИТЬ',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
}
