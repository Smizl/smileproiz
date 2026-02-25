import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<Map<String, dynamic>> cards = [
    {
      'id': '1',
      'cardNumber': '4400 4301 2345 6789',
      'cardHolder': 'SADIBEKOVA ZAMIRA',
      'expiryDate': '12/25',
      'cardType': 'visa',
      'isDefault': true,
    },
    {
      'id': '2',
      'cardNumber': '5536 9137 8765 4321',
      'cardHolder': 'SADIBEKOVA ZAMIRA',
      'expiryDate': '08/26',
      'cardType': 'mastercard',
      'isDefault': false,
    },
  ];

  void _addCard() {
    showDialog(
      context: context,
      builder: (context) => _CardDialog(
        onSave: (card) {
          setState(() {
            cards.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              ...card,
            });
          });
          _showSnackBar('Карта добавлена', true);
        },
      ),
    );
  }

  void _deleteCard(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'УДАЛИТЬ КАРТУ?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        content: const Text(
          'Вы уверены, что хотите удалить эту карту?',
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
                cards.removeWhere((c) => c['id'] == id);
              });
              Navigator.pop(context);
              _showSnackBar('Карта удалена', false);
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

  void _setDefaultCard(String id) {
    setState(() {
      for (var card in cards) {
        card['isDefault'] = card['id'] == id;
      }
    });
    _showSnackBar('Карта по умолчанию изменена', true);
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

  Color _getCardColor(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF006FCF);
      default:
        return const Color(0xFF2A2A2A);
    }
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
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
          'СПОСОБЫ ОПЛАТЫ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Информация
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF00FF87).withOpacity(0.3),
              ),
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
                  child: const Icon(
                    Icons.security,
                    color: Color(0xFF00FF87),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Безопасные платежи',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Данные карт надежно защищены',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Список карт
          Expanded(
            child: cards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card_off,
                          size: 80,
                          color: Colors.grey[800],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет сохраненных карт',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _addCard,
                          icon: const Icon(Icons.add),
                          label: const Text('ДОБАВИТЬ КАРТУ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF87),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return _buildCardWidget(card);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: cards.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _addCard,
              backgroundColor: const Color(0xFF00FF87),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text(
                'ДОБАВИТЬ',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            )
          : null,
    );
  }

  Widget _buildCardWidget(Map<String, dynamic> card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // Карта
          Container(
            height: 230,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCardColor(card['cardType']),
                  _getCardColor(card['cardType']).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: card['isDefault']
                    ? const Color(0xFF00FF87)
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getCardColor(card['cardType']).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card['cardType'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Icon(
                        _getCardIcon(card['cardType']),
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Chip icon
                  Container(
                    width: 50,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Card number
                  Text(
                    card['cardNumber'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Блок владельца карты — занимает всё доступное место
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ВЛАДЕЛЕЦ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card['cardHolder'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Блок срока действия — фиксированная ширина + больший отступ справа
                      Container(
                        width: 60, // ширина блока
                        margin: const EdgeInsets.only(
                          right: 32,
                        ), // <-- больше отступа, чтобы точно не касалось кнопки
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'СРОК',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card['expiryDate'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Бейдж "По умолчанию"
          if (card['isDefault'])
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF87),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ПО УМОЛЧАНИЮ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

          // Меню
          Positioned(
            bottom: 16,
            right: 16,
            child: PopupMenuButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.more_vert, color: Colors.white),
              ),
              color: const Color(0xFF2A2A2A),
              itemBuilder: (context) => [
                if (!card['isDefault'])
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF00FF87),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'По умолчанию',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(
                        Duration.zero,
                        () => _setDefaultCard(card['id']),
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
                      () => _deleteCard(card['id']),
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

// Диалог добавления карты
class _CardDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const _CardDialog({required this.onSave});

  @override
  State<_CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<_CardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isDefault = false;
  String _cardType = 'visa';

  String _detectCardType(String number) {
    if (number.startsWith('4')) return 'visa';
    if (number.startsWith('5')) return 'mastercard';
    if (number.startsWith('3')) return 'amex';
    return 'visa';
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
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
                const Text(
                  'НОВАЯ КАРТА',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Номер карты
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Номер карты',
                    labelStyle: TextStyle(color: Color(0xFF00FF87)),
                    prefixIcon: Icon(
                      Icons.credit_card,
                      color: Color(0xFF00FF87),
                    ),
                    filled: true,
                    fillColor: Color(0xFF0A0A0A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _cardType = _detectCardType(value);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите номер карты';
                    }
                    final digits = value.replaceAll(' ', '');
                    if (digits.length != 16) {
                      return 'Номер карты должен содержать 16 цифр';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Владелец
                TextFormField(
                  controller: _cardHolderController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Владелец карты',
                    labelStyle: TextStyle(color: Color(0xFF00FF87)),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF00FF87)),
                    filled: true,
                    fillColor: Color(0xFF0A0A0A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите имя владельца';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    // Срок действия
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ExpiryDateFormatter(),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'ММ/ГГ',
                          labelStyle: TextStyle(color: Color(0xFF00FF87)),
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Color(0xFF00FF87),
                          ),
                          filled: true,
                          fillColor: Color(0xFF0A0A0A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите срок';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // CVV
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          labelStyle: TextStyle(color: Color(0xFF00FF87)),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color(0xFF00FF87),
                          ),
                          filled: true,
                          fillColor: Color(0xFF0A0A0A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'CVV';
                          }
                          if (value.length != 3) {
                            return '3 цифры';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text(
                    'Использовать по умолчанию',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _isDefault,
                  activeColor: const Color(0xFF00FF87),
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value;
                    });
                  },
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
                          widget.onSave({
                            'cardNumber': _cardNumberController.text,
                            'cardHolder': _cardHolderController.text
                                .toUpperCase(),
                            'expiryDate': _expiryDateController.text,
                            'cardType': _cardType,
                            'isDefault': _isDefault,
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
                        'ДОБАВИТЬ',
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

// Форматтер для номера карты
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Форматтер для срока действия
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length >= 2) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }
    return newValue;
  }
}
