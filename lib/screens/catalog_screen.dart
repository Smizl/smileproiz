import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smileproiz/provider/cart_provider.dart';
import 'package:smileproiz/services/cart_service.dart';

class CatalogItemWidget extends StatelessWidget {
  final int productId;
  final String name;
  final int price;
  final String imageUrl;
  final String selectedSize;
  final String selectedColor;

  const CatalogItemWidget({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.selectedSize = '',
    this.selectedColor = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          Image.network(imageUrl, height: 100, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('$price₸', style: const TextStyle(color: Color(0xFF00FF87))),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              // Добавляем товар в корзину через CartProvider
              await Provider.of<CartProvider>(context, listen: false).addItem(
                productId: productId,
                name: name,
                price: price,
                imageUrl: imageUrl,
                selectedSize: selectedSize,
                selectedColor: selectedColor,
                quantity: 1,
              );

              // Можно показать SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Товар добавлен в корзину'),
                  backgroundColor: const Color(0xFF1A1A1A),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF87),
            ),
            child: const Text('Добавить в корзину'),
          ),
        ],
      ),
    );
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<String> categories = [
    'ВСЕ',
    'ОДЕЖДА',
    'ОБУВЬ',
    'АКСЕССУАРЫ',
    'SALE',
  ];

  String selectedCategory = 'ВСЕ';
  String searchQuery = '';
  String sortBy = 'popular'; // popular, price_low, price_high, new
  String? selectedSize;
  String? selectedColor;

  // Фильтры
  List<String> selectedSizes = [];
  List<String> selectedColors = [];
  String selectedHeight = 'Любой'; // Любой, 160-170, 170-180, 180-190, 190+
  RangeValues priceRange = const RangeValues(0, 30000);

  final List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'name': 'ОВЕРСАЙЗ ХУДИ ЧЕРНЫЙ',
      'price': 15000,
      'category': 'ОДЕЖДА',
      'imageUrl':
          'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500',
      'tag': 'НОВИНКА',
      'color': Color(0xFFFF6B6B),
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'colors': ['Черный', 'Серый', 'Белый'],
      'heights': ['160-170', '170-180', '180-190', '190+'],
      'rating': 4.8,
      'description':
          'Стильный оверсайз худи из плотного хлопка премиум качества. Идеально подходит для создания уличного образа.',
      'material': '80% хлопок, 20% полиэстер',
      'inStock': true,
    },
    {
      'id': 2,
      'name': 'КАРГО БРЮКИ СЕРЫЕ',
      'price': 18000,
      'category': 'ОДЕЖДА',
      'imageUrl':
          'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=500',
      'tag': 'ХИТ',
      'color': Color(0xFF4ECDC4),
      'sizes': ['M', 'L', 'XL'],
      'colors': ['Серый', 'Черный', 'Хаки'],
      'heights': ['170-180', '180-190', '190+'],
      'rating': 4.9,
      'description':
          'Практичные карго брюки с множеством карманов. Отлично сидят и очень удобные.',
      'material': '100% коттон',
      'inStock': true,
    },
    {
      'id': 3,
      'name': 'КЕПКА STREETWEAR',
      'price': 5000,
      'category': 'АКСЕССУАРЫ',
      'imageUrl':
          'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=500',
      'tag': 'ЛИМИТЕД',
      'color': Color(0xFFFFE66D),
      'sizes': ['ONE SIZE'],
      'colors': ['Черный', 'Белый', 'Красный'],
      'heights': ['Любой'],
      'rating': 4.7,
      'description': 'Классическая кепка в уличном стиле. Регулируемый размер.',
      'material': '100% хлопок',
      'inStock': true,
    },
    {
      'id': 4,
      'name': 'TECH КУРТКА ЗИМНЯЯ',
      'price': 25000,
      'category': 'ОДЕЖДА',
      'imageUrl':
          'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=500',
      'tag': 'НОВИНКА',
      'color': Color(0xFF95E1D3),
      'sizes': ['M', 'L', 'XL', 'XXL'],
      'colors': ['Черный', 'Синий', 'Хаки'],
      'heights': ['170-180', '180-190', '190+'],
      'rating': 5.0,
      'description':
          'Теплая зимняя куртка с водоотталкивающей поверхностью. Множество карманов и удобный крой.',
      'material': 'Полиэстер, утеплитель',
      'inStock': true,
    },
    {
      'id': 5,
      'name': 'КРОССОВКИ URBAN',
      'price': 20000,
      'category': 'ОБУВЬ',
      'imageUrl':
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500',
      'tag': 'ТОП',
      'color': Color(0xFFFF8C94),
      'sizes': ['40', '41', '42', '43', '44', '45'],
      'colors': ['Белый', 'Черный', 'Серый'],
      'heights': ['Любой'],
      'rating': 4.6,
      'description':
          'Стильные городские кроссовки с мягкой подошвой. Комфорт на весь день.',
      'material': 'Кожа, текстиль',
      'inStock': true,
    },
    {
      'id': 6,
      'name': 'РЮКЗАК КОЖАНЫЙ',
      'price': 12000,
      'category': 'АКСЕССУАРЫ',
      'imageUrl':
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500',
      'tag': '',
      'color': Color(0xFFA8E6CF),
      'sizes': ['ONE SIZE'],
      'colors': ['Черный', 'Коричневый'],
      'heights': ['Любой'],
      'rating': 4.5,
      'description':
          'Вместительный рюкзак из натуральной кожи. Множество отделений.',
      'material': 'Натуральная кожа',
      'inStock': true,
    },
    {
      'id': 7,
      'name': 'ДЖИНСОВКА ВИНТАЖ',
      'price': 16000,
      'category': 'ОДЕЖДА',
      'imageUrl':
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500',
      'tag': 'SALE',
      'color': Color(0xFFFFD3B6),
      'sizes': ['S', 'M', 'L'],
      'colors': ['Синий', 'Черный'],
      'heights': ['160-170', '170-180', '180-190'],
      'rating': 4.8,
      'description':
          'Винтажная джинсовая куртка в стиле 90-х. Классика, которая никогда не выходит из моды.',
      'material': '100% деним',
      'inStock': false,
    },
    {
      'id': 8,
      'name': 'ЦЕПЬ СЕРЕБРО',
      'price': 8000,
      'category': 'АКСЕССУАРЫ',
      'imageUrl':
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500',
      'tag': 'НОВИНКА',
      'color': Color(0xFFDCEDC8),
      'sizes': ['ONE SIZE'],
      'colors': ['Серебро'],
      'heights': ['Любой'],
      'rating': 4.9,
      'description':
          'Массивная серебряная цепь. Стильный аксессуар для завершения образа.',
      'material': 'Нержавеющая сталь',
      'inStock': true,
    },
    {
      'id': 9,
      'name': 'БОМБЕР ОЛИВКОВЫЙ',
      'price': 22000,
      'category': 'ОДЕЖДА',
      'imageUrl':
          'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=500',
      'tag': 'ХИТ',
      'color': Color(0xFF95E1D3),
      'sizes': ['M', 'L', 'XL'],
      'colors': ['Оливковый', 'Черный'],
      'heights': ['170-180', '180-190'],
      'rating': 4.7,
      'description': 'Классический бомбер в стиле милитари. Легкий и удобный.',
      'material': 'Нейлон',
      'inStock': true,
    },
    {
      'id': 10,
      'name': 'ДЖОГГЕРЫ СПОРТ',
      'price': 14000,
      'category': 'ОДЕЖДА',
      'imageUrl':
          'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=500',
      'tag': '',
      'color': Color(0xFF4ECDC4),
      'sizes': ['S', 'M', 'L', 'XL'],
      'colors': ['Черный', 'Серый', 'Синий'],
      'heights': ['170-180', '180-190', '190+'],
      'rating': 4.6,
      'description':
          'Спортивные джоггеры для активного образа жизни. Мягкая ткань.',
      'material': '95% хлопок, 5% эластан',
      'inStock': true,
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    var filtered = products.where((product) {
      // Фильтр по категории
      final matchesCategory =
          selectedCategory == 'ВСЕ' ||
          product['category'] == selectedCategory ||
          (selectedCategory == 'SALE' && product['tag'] == 'SALE');

      // Фильтр по поиску
      final matchesSearch = product['name'].toString().toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      // Фильтр по размеру
      final matchesSize =
          selectedSizes.isEmpty ||
          (product['sizes'] as List<String>).any(
            (size) => selectedSizes.contains(size),
          );

      // Фильтр по цвету
      final matchesColor =
          selectedColors.isEmpty ||
          (product['colors'] as List<String>).any(
            (color) => selectedColors.contains(color),
          );

      // Фильтр по росту
      // Фильтр по росту
      final heights =
          product['heights'] as List<String>?; // безопасно приводим к списку
      final matchesHeight =
          selectedHeight == 'Любой' ||
          (heights?.contains(selectedHeight) ?? false) ||
          (heights?.contains('Любой') ?? false);

      // Фильтр по цене
      final matchesPrice =
          product['price'] >= priceRange.start &&
          product['price'] <= priceRange.end;

      return matchesCategory &&
          matchesSearch &&
          matchesSize &&
          matchesColor &&
          matchesHeight &&
          matchesPrice;
    }).toList();

    // Сортировка
    switch (sortBy) {
      case 'price_low':
        filtered.sort(
          (a, b) => (a['price'] as int).compareTo(b['price'] as int),
        );
        break;
      case 'price_high':
        filtered.sort(
          (a, b) => (b['price'] as int).compareTo(a['price'] as int),
        );
        break;
      case 'new':
        filtered =
            filtered.where((p) => p['tag'] == 'НОВИНКА').toList() +
            filtered.where((p) => p['tag'] != 'НОВИНКА').toList();
        break;
      default: // popular
        filtered.sort(
          (a, b) => (b['rating'] as double).compareTo(a['rating'] as double),
        );
    }

    return filtered;
  }

  // Корзина через Provider + безопасный SnackBar
  Future<void> addToCartSafe(
    BuildContext context,
    Map<String, dynamic> product,
    String size,
    String color,
  ) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Преобразуем id в int, если он строка
      final productId = product['id'] is String
          ? int.parse(product['id'])
          : product['id'] as int;

      // Добавляем через серверный сервис (если есть)
      final serverItem = await CartService.addToCart(
        productId: productId,
        quantity: 1,
        selectedSize: size,
        selectedColor: color,
      );

      // После успешного ответа сервера обновляем локальный Provider
      await cartProvider.addItem(
        productId: productId,
        name: product['name'],
        price: (product['price'] as num).toInt(),
        imageUrl: product['imageUrl'],
        selectedSize: size,
        selectedColor: color,
        quantity: 1,
      );

      // Показываем SnackBar только если виджет ещё монтирован
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Товар добавлен в корзину'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при добавлении товара: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ФИЛЬТРЫ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Размеры
                const Text(
                  'РАЗМЕР',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      [
                        'XS',
                        'S',
                        'M',
                        'L',
                        'XL',
                        'XXL',
                        '40',
                        '41',
                        '42',
                        '43',
                        '44',
                        '45',
                      ].map((size) {
                        final isSelected = selectedSizes.contains(size);
                        return FilterChip(
                          label: Text(size),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                selectedSizes.add(size);
                              } else {
                                selectedSizes.remove(size);
                              }
                            });
                            setState(() {});
                          },
                          backgroundColor: const Color(0xFF2A2A2A),
                          selectedColor: const Color(0xFF00FF87),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 25),

                // Рост
                const Text(
                  'РОСТ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ['Любой', '160-170', '170-180', '180-190', '190+']
                      .map((height) {
                        final isSelected = selectedHeight == height;
                        return ChoiceChip(
                          label: Text(height),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              selectedHeight = height;
                            });
                            setState(() {});
                          },
                          backgroundColor: const Color(0xFF2A2A2A),
                          selectedColor: const Color(0xFF00FF87),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      })
                      .toList(),
                ),
                const SizedBox(height: 25),

                // Цвета
                const Text(
                  'ЦВЕТ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      [
                        'Черный',
                        'Белый',
                        'Серый',
                        'Синий',
                        'Красный',
                        'Зеленый',
                        'Оливковый',
                        'Хаки',
                        'Коричневый',
                      ].map((color) {
                        final isSelected = selectedColors.contains(color);
                        return FilterChip(
                          label: Text(color),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                selectedColors.add(color);
                              } else {
                                selectedColors.remove(color);
                              }
                            });
                            setState(() {});
                          },
                          backgroundColor: const Color(0xFF2A2A2A),
                          selectedColor: const Color(0xFF00FF87),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 25),

                // Цена
                const Text(
                  'ЦЕНА',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                RangeSlider(
                  values: priceRange,
                  min: 0,
                  max: 30000,
                  divisions: 30,
                  activeColor: const Color(0xFF00FF87),
                  inactiveColor: const Color(0xFF2A2A2A),
                  labels: RangeLabels(
                    '${priceRange.start.round()}₸',
                    '${priceRange.end.round()}₸',
                  ),
                  onChanged: (values) {
                    setModalState(() {
                      priceRange = values;
                    });
                    setState(() {});
                  },
                ),
                Text(
                  '${priceRange.start.round()}₸ - ${priceRange.end.round()}₸',
                  style: const TextStyle(
                    color: Color(0xFF00FF87),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Кнопки
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            selectedSizes.clear();
                            selectedColors.clear();
                            selectedHeight = 'Любой';
                            priceRange = const RangeValues(0, 30000);
                          });
                          setState(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[700]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'СБРОСИТЬ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF87),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ПРИМЕНИТЬ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'СОРТИРОВКА',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildSortOption('Популярное', 'popular'),
            _buildSortOption('Цена: по возрастанию', 'price_low'),
            _buildSortOption('Цена: по убыванию', 'price_high'),
            _buildSortOption('Новинки', 'new'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value) {
    final isSelected = sortBy == value;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF00FF87) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF00FF87))
          : null,
      onTap: () {
        setState(() {
          sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showProductDetails(Map<String, dynamic> product) {
    String? selectedSize;
    String? selectedColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Изображение
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          product['imageUrl'],
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Название и цена
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Color(0xFFFFE66D),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      product['rating'].toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${product['price']}₸',
                            style: const TextStyle(
                              color: Color(0xFF00FF87),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Наличие
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: product['inStock']
                              ? const Color(0xFF00FF87).withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product['inStock']
                              ? '✓ В наличии'
                              : '✗ Нет в наличии',
                          style: TextStyle(
                            color: product['inStock']
                                ? const Color(0xFF00FF87)
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Описание
                      const Text(
                        'ОПИСАНИЕ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product['description'],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Материал
                      Row(
                        children: [
                          const Icon(
                            Icons.checkroom,
                            color: Color(0xFF00FF87),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Материал: ${product['material']}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Размер
                      const Text(
                        'РАЗМЕР',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: (product['sizes'] as List<String>).map((
                          size,
                        ) {
                          final isSelected = selectedSize == size;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedSize = size;
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00FF87)
                                    : const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00FF87)
                                      : Colors.grey[800]!,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  size,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Цвет
                      const Text(
                        'ЦВЕТ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: (product['colors'] as List<String>).map((
                          color,
                        ) {
                          final isSelected = selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00FF87)
                                    : const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00FF87)
                                      : Colors.grey[800]!,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                color,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Основная кнопка добавления в корзину
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed:
                        product['inStock'] &&
                            selectedSize != null &&
                            selectedColor != null
                        ? () async {
                            await addToCartSafe(
                              context,
                              product,
                              selectedSize!,
                              selectedColor!,
                            );
                            Navigator.pop(context);
                          }
                        : null,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF87),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          selectedSize == null || selectedColor == null
                              ? 'ВЫБЕРИТЕ РАЗМЕР И ЦВЕТ'
                              : 'ДОБАВИТЬ В КОРЗИНУ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFiltersCount =
        selectedSizes.length +
        selectedColors.length +
        (selectedHeight != 'Любой' ? 1 : 0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0A),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'КАТАЛОГ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0A0A0A),
                      const Color(0xFF1A1A1A).withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Поиск и фильтры
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Поиск
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[800]!, width: 1),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Поиск товаров...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF00FF87),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Категории и фильтры
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = category == selectedCategory;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategory = category;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF00FF87)
                                        : const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF00FF87)
                                          : Colors.grey[800]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Кнопка фильтров
                      GestureDetector(
                        onTap: _showFilterDialog,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: activeFiltersCount > 0
                                ? const Color(0xFF00FF87)
                                : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: activeFiltersCount > 0
                                  ? const Color(0xFF00FF87)
                                  : Colors.grey[800]!,
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.tune,
                                  color: activeFiltersCount > 0
                                      ? Colors.black
                                      : const Color(0xFF00FF87),
                                ),
                              ),
                              if (activeFiltersCount > 0)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$activeFiltersCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Кнопка сортировки
                      GestureDetector(
                        onTap: _showSortOptions,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[800]!,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.sort,
                            color: Color(0xFF00FF87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Счетчик товаров
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredProducts.length} ТОВАРОВ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  if (activeFiltersCount > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedSizes.clear();
                          selectedColors.clear();
                          selectedHeight = 'Любой';
                          priceRange = const RangeValues(0, 30000);
                        });
                      },
                      child: const Text(
                        'СБРОСИТЬ ФИЛЬТРЫ',
                        style: TextStyle(
                          color: Color(0xFF00FF87),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Сетка товаров
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = filteredProducts[index];
                return _buildProductCard(product);
              }, childCount: filteredProducts.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[900]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(product['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (product['tag'].toString().isNotEmpty)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: product['tag'] == 'SALE'
                                  ? Colors.red
                                  : product['color'],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product['tag'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFFE66D),
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                product['rating'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!product['inStock'])
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'НЕТ В НАЛИЧИИ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Информация
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product['price']}₸',
                          style: const TextStyle(
                            color: Color(0xFF00FF87),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Размеры: ${(product['sizes'] as List).take(3).join(", ")}${(product['sizes'] as List).length > 3 ? "..." : ""}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
