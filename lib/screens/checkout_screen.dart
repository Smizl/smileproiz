import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smileproiz/provider/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}
 
class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;

  // Контроллеры для формы доставки
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  // Контроллеры для оплаты
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String selectedPaymentMethod = 'card'; // card, cash, kaspi
  String selectedDeliveryMethod = 'courier'; // courier, pickup

  bool isProcessing = false;

  // Добавляем константу для стоимости доставки
  static const int deliveryPrice = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _commentController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // Метод для получения общей суммы
  int _getTotalPrice(CartProvider cartProvider) {
    return cartProvider.totalPrice + deliveryPrice;
  }

  void _processPayment() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    setState(() {
      isProcessing = true;
    });

    // Симуляция обработки платежа
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isProcessing = false;
    });

    if (mounted) {
      // Очищаем корзину после успешной оплаты
      cartProvider.clearCart();

      // Показываем успешное сообщение
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FF87), Color(0xFF00D9FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF87).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 50),
              ),
              const SizedBox(height: 20),
              const Text(
                'ЗАКАЗ ОФОРМЛЕН!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Номер заказа: #${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Мы свяжемся с вами для подтверждения заказа',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF87),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'НА ГЛАВНУЮ',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalPrice = cartProvider.totalPrice;
    final totalWithDelivery = _getTotalPrice(cartProvider);

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
          'ОФОРМЛЕНИЕ ЗАКАЗА',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Stepper индикатор
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Доставка', _currentStep >= 0),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep >= 1 ? const Color(0xFF00FF87) : Colors.grey[800],
                  ),
                ),
                _buildStepIndicator(1, 'Оплата', _currentStep >= 1),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep >= 2 ? const Color(0xFF00FF87) : Colors.grey[800],
                  ),
                ),
                _buildStepIndicator(2, 'Готово', _currentStep >= 2),
              ],
            ),
          ),

          // Контент
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _currentStep == 0
                  ? _buildDeliveryStep()
                  : _currentStep == 1
                  ? _buildPaymentStep()
                  : _buildConfirmationStep(cartProvider),
            ),
          ),

          // Нижняя панель с итогом и кнопкой
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ИТОГО:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        '${totalWithDelivery}₸',
                        style: const TextStyle(
                          color: Color(0xFF00FF87),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : () {
                        if (_currentStep < 2) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          _processPayment();
                        }
                      },
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
                      child: isProcessing
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                          : Text(
                        _currentStep == 2 ? 'ОПЛАТИТЬ' : 'ДАЛЕЕ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF00FF87) : Colors.grey[800],
            border: Border.all(
              color: isActive ? const Color(0xFF00FF87) : Colors.grey[700]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.black : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF00FF87) : Colors.grey[600],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'СПОСОБ ДОСТАВКИ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildDeliveryOption(
          'courier',
          'Курьерская доставка',
          'Бесплатно при заказе от 10000₸',
          Icons.local_shipping,
        ),
        const SizedBox(height: 12),
        _buildDeliveryOption(
          'pickup',
          'Самовывоз',
          'Забрать из магазина',
          Icons.store,
        ),
        const SizedBox(height: 30),
        const Text(
          'КОНТАКТНАЯ ИНФОРМАЦИЯ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField('Имя', _nameController, Icons.person),
        _buildTextField('Телефон', _phoneController, Icons.phone, isPhone: true),
        if (selectedDeliveryMethod == 'courier') ...[
          _buildTextField('Город', _cityController, Icons.location_city),
          _buildTextField('Адрес доставки', _addressController, Icons.location_on),
        ],
        _buildTextField('Комментарий (необязательно)', _commentController, Icons.comment, maxLines: 3),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'СПОСОБ ОПЛАТЫ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildPaymentOption(
          'card',
          'Банковская карта',
          'Visa, Mastercard',
          Icons.credit_card,
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'kaspi',
          'Kaspi Pay',
          'Kaspi QR',
          Icons.qr_code,
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'cash',
          'Наличными',
          'При получении',
          Icons.payments,
        ),

        if (selectedPaymentMethod == 'card') ...[
          const SizedBox(height: 30),
          const Text(
            'ДАННЫЕ КАРТЫ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Номер карты', _cardNumberController, Icons.credit_card, isCard: true),
          _buildTextField('Имя держателя', _cardHolderController, Icons.person),
          Row(
            children: [
              Expanded(
                child: _buildTextField('MM/YY', _expiryController, Icons.calendar_today, isExpiry: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('CVV', _cvvController, Icons.lock, isCVV: true),
              ),
            ],
          ),
        ],

        if (selectedPaymentMethod == 'kaspi') ...[
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[900]!, width: 1),
            ),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.asset(
                    'assets/images/kaspi_qr.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Отсканируйте QR-код в приложении Kaspi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmationStep(CartProvider cartProvider) {
    final totalPrice = cartProvider.totalPrice;
    final totalWithDelivery = _getTotalPrice(cartProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ПОДТВЕРЖДЕНИЕ ЗАКАЗА',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),

        _buildSummarySection(
          'Доставка',
          selectedDeliveryMethod == 'courier' ? 'Курьерская доставка' : 'Самовывоз',
        ),
        if (selectedDeliveryMethod == 'courier')
          _buildSummarySection('Адрес', _addressController.text),
        _buildSummarySection('Телефон', _phoneController.text),

        const SizedBox(height: 20),
        _buildSummarySection(
          'Способ оплаты',
          selectedPaymentMethod == 'card'
              ? 'Банковская карта'
              : selectedPaymentMethod == 'kaspi'
              ? 'Kaspi Pay'
              : 'Наличными',
        ),

        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00FF87).withOpacity(0.2),
                const Color(0xFF00D9FF).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF00FF87), width: 2),
          ),
          child: Column(
            children: [
              _buildPriceRow('Товары:', '$totalPrice₸'),
              const SizedBox(height: 8),
              _buildPriceRow('Доставка:', deliveryPrice == 0 ? 'Бесплатно' : '$deliveryPrice₸'),
              const Divider(color: Colors.grey, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'К ОПЛАТЕ:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '${totalWithDelivery}₸',
                    style: const TextStyle(
                      color: Color(0xFF00FF87),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryOption(String value, String title, String subtitle, IconData icon) {
    final isSelected = selectedDeliveryMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDeliveryMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF00FF87) : Colors.grey[900]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00FF87).withOpacity(0.2)
                    : Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF00FF87) : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF00FF87) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF00FF87)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, String subtitle, IconData icon) {
    final isSelected = selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF00FF87) : Colors.grey[900]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00FF87).withOpacity(0.2)
                    : Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF00FF87) : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF00FF87) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF00FF87)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        int maxLines = 1,
        bool isPhone = false,
        bool isCard = false,
        bool isExpiry = false,
        bool isCVV = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        keyboardType: isPhone || isCard || isCVV
            ? TextInputType.number
            : TextInputType.text,
        inputFormatters: isCard
            ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(16),
          CardNumberInputFormatter(),
        ]
            : isExpiry
            ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
          ExpiryDateInputFormatter(),
        ]
            : isCVV
            ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ]
            : isPhone
            ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ]
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: const Color(0xFF00FF87)),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[900]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[900]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF00FF87), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[900]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Форматтеры для ввода карты
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.length > 2) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }

    return newValue;
  }
}