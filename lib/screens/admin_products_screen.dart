import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<Map<String, dynamic>> products = [
    {
      'id': '1',
      'name': 'Футболка MØRK',
      'price': 12500,
      'category': 'Одежда',
      'stock': 25,
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
      'inStock': true,
    },
    {
      'id': '2',
      'name': 'Куртка Black Edition',
      'price': 35000,
      'category': 'Верхняя одежда',
      'stock': 15,
      'image': 'https://images.unsplash.com/photo-1551028719-00167b16eac5',
      'inStock': true,
    },
    {
      'id': '3',
      'name': 'Кроссовки Street',
      'price': 28000,
      'category': 'Обувь',
      'stock': 30,
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
      'inStock': true,
    },
  ];

  String _searchQuery = '';
  String _selectedCategory = 'Все';

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(
        onSave: (product) {
          setState(() {
            products.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              ...product,
            });
          });
          _showSnackBar('Товар добавлен', true);
        },
      ),
    );
  }

  void _editProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(
        product: product,
        onSave: (updatedProduct) {
          setState(() {
            final index = products.indexWhere((p) => p['id'] == product['id']);
            if (index != -1) {
              products[index] = {'id': product['id'], ...updatedProduct};
            }
          });
          _showSnackBar('Товар обновлен', true);
        },
      ),
    );
  }

  void _deleteProduct(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'УДАЛИТЬ ТОВАР?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        content: const Text(
          'Это действие нельзя отменить',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ОТМЕНА',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                products.removeWhere((p) => p['id'] == id);
              });
              Navigator.pop(context);
              _showSnackBar('Товар удален', false);
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
              color: isSuccess ? const Color(0xFF00FF87) : const Color(0xFFFF6B6B),
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

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final matchesSearch = product['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Все' || product['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredProducts;

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
              // Поиск
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Поиск товаров...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF00FF87)),
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
              // Фильтр категорий
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('Все'),
                    _buildCategoryChip('Одежда'),
                    _buildCategoryChip('Верхняя одежда'),
                    _buildCategoryChip('Обувь'),
                    _buildCategoryChip('Аксессуары'),
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
                icon: Icons.inventory_2,
                value: products.length.toString(),
                label: 'Товаров',
                color: const Color(0xFF00FF87),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.check_circle,
                value: products.where((p) => p['inStock'] == true).length.toString(),
                label: 'В наличии',
                color: const Color(0xFF4ECDC4),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.warning,
                value: products.where((p) => p['stock'] < 10).length.toString(),
                label: 'Заканчивается',
                color: const Color(0xFFFFE66D),
              ),
            ],
          ),
        ),

        // Список товаров
        Expanded(
          child: filtered.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 80, color: Colors.grey[800]),
                const SizedBox(height: 16),
                Text(
                  'Товары не найдены',
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
              final product = filtered[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[900]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Изображение
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(product['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['category'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${product['price']}₸',
                        style: const TextStyle(
                          color: Color(0xFF00FF87),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product['stock'] < 10
                              ? const Color(0xFFFFE66D).withOpacity(0.2)
                              : const Color(0xFF00FF87).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Склад: ${product['stock']}',
                          style: TextStyle(
                            color: product['stock'] < 10
                                ? const Color(0xFFFFE66D)
                                : const Color(0xFF00FF87),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Действия
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF00D9FF)),
                  onPressed: () => _editProduct(product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFFF6B6B)),
                  onPressed: () => _deleteProduct(product['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Диалог добавления/редактирования товара
class _ProductDialog extends StatefulWidget {
  final Map<String, dynamic>? product;
  final Function(Map<String, dynamic>) onSave;

  const _ProductDialog({this.product, required this.onSave});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageController;
  String _selectedCategory = 'Одежда';
  bool _inStock = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?['name'] ?? '');
    _priceController =
        TextEditingController(text: widget.product?['price']?.toString() ?? '');
    _stockController =
        TextEditingController(text: widget.product?['stock']?.toString() ?? '');
    _imageController = TextEditingController(text: widget.product?['image'] ?? '');
    _selectedCategory = widget.product?['category'] ?? 'Одежда';
    _inStock = widget.product?['inStock'] ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
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
                  widget.product == null ? 'ДОБАВИТЬ ТОВАР' : 'РЕДАКТИРОВАТЬ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField('Название', _nameController, Icons.label),
                const SizedBox(height: 16),
                _buildTextField('Цена (₸)', _priceController, Icons.money,
                    isNumber: true),
                const SizedBox(height: 16),
                _buildTextField('Количество', _stockController, Icons.inventory,
                    isNumber: true),
                const SizedBox(height: 16),
                _buildTextField('URL изображения', _imageController, Icons.image),
                const SizedBox(height: 16),
                // Категория
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Категория',
                    labelStyle: const TextStyle(color: Color(0xFF00FF87)),
                    prefixIcon: const Icon(Icons.category, color: Color(0xFF00FF87)),
                    filled: true,
                    fillColor: const Color(0xFF0A0A0A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['Одежда', 'Верхняя одежда', 'Обувь', 'Аксессуары']
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // В наличии
                SwitchListTile(
                  title: const Text(
                    'В наличии',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _inStock,
                  activeColor: const Color(0xFF00FF87),
                  onChanged: (value) {
                    setState(() {
                      _inStock = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Кнопки
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
                          widget.onSave({
                            'name': _nameController.text,
                            'price': int.parse(_priceController.text),
                            'stock': int.parse(_stockController.text),
                            'image': _imageController.text,
                            'category': _selectedCategory,
                            'inStock': _inStock,
                          });
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

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool isNumber = false,
      }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters:
      isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF00FF87)),
        prefixIcon: Icon(icon, color: const Color(0xFF00FF87)),
        filled: true,
        fillColor: const Color(0xFF0A0A0A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Заполните поле';
        }
        return null;
      },
    );
  }
}