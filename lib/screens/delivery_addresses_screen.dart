import 'package:flutter/material.dart';

class DeliveryAddressesScreen extends StatefulWidget {
  const DeliveryAddressesScreen({super.key});

  @override
  State<DeliveryAddressesScreen> createState() =>
      _DeliveryAddressesScreenState();
}

class _DeliveryAddressesScreenState extends State<DeliveryAddressesScreen> {
  List<Map<String, dynamic>> addresses = [
    {
      'id': '1',
      'title': 'Дом',
      'fullName': 'Садибекова Замира',
      'phone': '+7 777 123 45 67',
      'city': 'Астана',
      'street': 'ул. Абая, 12',
      'apartment': 'кв. 45',
      'entrance': '2',
      'floor': '5',
      'intercom': '45',
      'isDefault': true,
    },
    {
      'id': '2',
      'title': 'Работа',
      'fullName': 'Садибекова Замира',
      'phone': '+7 777 123 45 67',
      'city': 'Астана',
      'street': 'пр. Туран, 50',
      'apartment': 'офис 301',
      'entrance': '1',
      'floor': '3',
      'intercom': '301',
      'isDefault': false,
    },
  ];

  void _addAddress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressDialog(
        onSave: (address) {
          setState(() {
            addresses.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              ...address,
            });
          });
          _showSnackBar('Адрес добавлен', true);
        },
      ),
    );
  }

  void _editAddress(Map<String, dynamic> address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressDialog(
        address: address,
        onSave: (updatedAddress) {
          setState(() {
            final index = addresses.indexWhere((a) => a['id'] == address['id']);
            if (index != -1) {
              addresses[index] = {'id': address['id'], ...updatedAddress};
            }
          });
          _showSnackBar('Адрес обновлен', true);
        },
      ),
    );
  }

  void _deleteAddress(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'УДАЛИТЬ АДРЕС?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        content: const Text(
          'Вы уверены, что хотите удалить этот адрес?',
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
                addresses.removeWhere((a) => a['id'] == id);
              });
              Navigator.pop(context);
              _showSnackBar('Адрес удален', false);
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

  void _setDefaultAddress(String id) {
    setState(() {
      for (var address in addresses) {
        address['isDefault'] = address['id'] == id;
      }
    });
    _showSnackBar('Адрес по умолчанию изменен', true);
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
          'АДРЕСА ДОСТАВКИ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 80, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  Text(
                    'Нет сохраненных адресов',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _addAddress,
                    icon: const Icon(Icons.add),
                    label: const Text('ДОБАВИТЬ АДРЕС'),
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
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _buildAddressCard(address);
              },
            ),
      floatingActionButton: addresses.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _addAddress,
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

  Widget _buildAddressCard(Map<String, dynamic> address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: address['isDefault']
              ? const Color(0xFF00FF87)
              : Colors.grey[900]!,
          width: address['isDefault'] ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                    color: address['isDefault']
                        ? const Color(0xFF00FF87).withOpacity(0.2)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: address['isDefault']
                          ? const Color(0xFF00FF87)
                          : Colors.grey[800]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        address['title'] == 'Дом' ? Icons.home : Icons.work,
                        color: address['isDefault']
                            ? const Color(0xFF00FF87)
                            : Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        address['title'],
                        style: TextStyle(
                          color: address['isDefault']
                              ? const Color(0xFF00FF87)
                              : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (address['isDefault'])
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF87),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ПО УМОЛЧАНИЮ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: const Color(0xFF2A2A2A),
                  itemBuilder: (context) => [
                    if (!address['isDefault'])
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
                            () => _setDefaultAddress(address['id']),
                          );
                        },
                      ),
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
                          () => _editAddress(address),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Color(0xFFFF6B6B),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Удалить',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(
                          Duration.zero,
                          () => _deleteAddress(address['id']),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              address['fullName'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, address['phone']),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.location_city, address['city']),
            const SizedBox(height: 4),
            _buildInfoRow(
              Icons.location_on,
              '${address['street']}, ${address['apartment']}',
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              Icons.stairs,
              'Подъезд ${address['entrance']}, Этаж ${address['floor']}, Домофон ${address['intercom']}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// Диалог добавления/редактирования адреса
class _AddressDialog extends StatefulWidget {
  final Map<String, dynamic>? address;
  final Function(Map<String, dynamic>) onSave;

  const _AddressDialog({this.address, required this.onSave});

  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _streetController;
  late TextEditingController _apartmentController;
  late TextEditingController _entranceController;
  late TextEditingController _floorController;
  late TextEditingController _intercomController;
  bool _isDefault = false;

  final List<String> _addressTypes = ['Дом', 'Работа', 'Другое'];
  String _selectedType = 'Дом';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.address?['title'] ?? '',
    );
    _fullNameController = TextEditingController(
      text: widget.address?['fullName'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.address?['phone'] ?? '',
    );
    _cityController = TextEditingController(
      text: widget.address?['city'] ?? '',
    );
    _streetController = TextEditingController(
      text: widget.address?['street'] ?? '',
    );
    _apartmentController = TextEditingController(
      text: widget.address?['apartment'] ?? '',
    );
    _entranceController = TextEditingController(
      text: widget.address?['entrance'] ?? '',
    );
    _floorController = TextEditingController(
      text: widget.address?['floor'] ?? '',
    );
    _intercomController = TextEditingController(
      text: widget.address?['intercom'] ?? '',
    );
    _isDefault = widget.address?['isDefault'] ?? false;
    _selectedType = widget.address?['title'] ?? 'Дом';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _apartmentController.dispose();
    _entranceController.dispose();
    _floorController.dispose();
    _intercomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.address == null ? 'НОВЫЙ АДРЕС' : 'РЕДАКТИРОВАТЬ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Тип адреса
                    const Text(
                      'Тип адреса',
                      style: TextStyle(
                        color: Color(0xFF00FF87),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _addressTypes.map((type) {
                        final isSelected = _selectedType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = type;
                            });
                          },
                          backgroundColor: const Color(0xFF0A0A0A),
                          selectedColor: const Color(0xFF00FF87),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    _buildTextField(
                      'ФИО получателя',
                      _fullNameController,
                      Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('Телефон', _phoneController, Icons.phone),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Город',
                      _cityController,
                      Icons.location_city,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Улица и дом',
                      _streetController,
                      Icons.home,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Квартира/Офис',
                      _apartmentController,
                      Icons.meeting_room,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Подъезд',
                            _entranceController,
                            Icons.stairs,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTextField(
                            'Этаж',
                            _floorController,
                            Icons.layers,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Домофон',
                      _intercomController,
                      Icons.dialpad,
                    ),

                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text(
                        'Адрес по умолчанию',
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
                                'title': _selectedType,
                                'fullName': _fullNameController.text,
                                'phone': _phoneController.text,
                                'city': _cityController.text,
                                'street': _streetController.text,
                                'apartment': _apartmentController.text,
                                'entrance': _entranceController.text,
                                'floor': _floorController.text,
                                'intercom': _intercomController.text,
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
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
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
