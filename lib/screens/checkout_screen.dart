import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<CartItem> cart;
  final Function(PaymentDetails) setPaymentDetails;

  const CheckoutScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.cart,
    required this.setPaymentDetails,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isShippingEdit = false;
  String _selectedPayment = 'Visa';
  String _selectedShipping = 'JNE';

  // Data Alamat (Menggunakan Address Model)
  Address _shippingAddress = Address(
    name: 'Sarah',
    phone: '0812-3456-7890',
    address: 'Jl. Bojongsoang No. 10, Kecamatan Bojongsoang, Kab. Bandung, 40288',
  );

  // Data Metode Pembayaran
  final List<Map<String, String>> paymentMethods = const [
    {'key': 'Visa', 'label': 'Kartu Kredit/Debit (Visa **** 1234)', 'icon': 'VISA'},
    {'key': 'QRIS', 'label': 'QRIS (Gopay/Dana/LinkAja)', 'icon': 'QRIS'},
    {'key': 'COD', 'label': 'COD (Bayar di Tempat)', 'icon': 'COD'},
  ];

  // Data Metode Pengiriman
  final List<Map<String, dynamic>> shippingOptions = const [
    {'key': 'JNE', 'method': 'JNE Reguler', 'cost': 20000, 'duration': 'Est. 3-5 hari'},
    {'key': 'SiCepat', 'method': 'SiCepat BEST', 'cost': 25000, 'duration': 'Est. 2-3 hari'},
    {'key': 'Grab', 'method': 'GrabExpress Sameday', 'cost': 35000, 'duration': 'Est. Hari ini'},
  ];

  int _calculateSubtotal() {
    return widget.cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  }

  int _calculateShippingCost(int subtotal) {
    final selectedOption = shippingOptions.firstWhere((o) => o['key'] == _selectedShipping);
    final selectedShippingCost = selectedOption['cost'] as int;
    return subtotal > 500000 ? 0 : selectedShippingCost;
  }

  void _handlePlaceOrder(int total) {
    final paymentInfo = PaymentDetails(
      methodKey: _selectedPayment,
      totalAmount: total,
      shippingMethod: _selectedShipping,
      shippingAddress: _shippingAddress,
    );

    widget.setPaymentDetails(paymentInfo);

    if (_selectedPayment == 'COD') {
      widget.navigate('OrderSuccess');
    } else {
      widget.navigate('PaymentProcessing');
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();
    final shipping = _calculateShippingCost(subtotal);
    final total = subtotal + shipping;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.goBack,
        ),
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 5.1 Shipping Information
                _SectionHeader(
                  title: 'Shipping Information',
                  icon: Icons.location_on,
                  trailing: _isShippingEdit ? 'Cancel' : 'Change',
                  onTrailingTap: () => setState(() => _isShippingEdit = !_isShippingEdit),
                ),
                const SizedBox(height: 12),
                _isShippingEdit ? _AddressEditor(
                  address: _shippingAddress,
                  onAddressChange: (newAddress) => setState(() => _shippingAddress = newAddress),
                  onSave: () => setState(() => _isShippingEdit = false),
                ) : _AddressDisplay(address: _shippingAddress),
                const SizedBox(height: 24),

                // 5.2 Payment Method
                _SectionHeader(
                  title: 'Payment Method',
                  icon: Icons.credit_card,
                  trailing: 'Add new',
                  onTrailingTap: () => print('Tambah Kartu'),
                ),
                const SizedBox(height: 12),
                ...paymentMethods.map((method) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: PaymentOption(
                        icon: method['icon']!,
                        label: method['label']!,
                        isSelected: _selectedPayment == method['key'],
                        onSelect: () => setState(() => _selectedPayment = method['key']!),
                      ),
                    )),
                const SizedBox(height: 24),

                // 5.3 Shipping Method
                const Text('Shipping Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...shippingOptions.map((option) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ShippingOption(
                        method: option['method'] as String,
                        cost: option['cost'] as int,
                        duration: option['duration'] as String,
                        selected: _selectedShipping == option['key'],
                        onSelect: () => setState(() => _selectedShipping = option['key'] as String),
                      ),
                    )),
              ],
            ),
          ),
          // Total dan Tombol Place Order
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Order:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(formatRupiah(total), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: customPink)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _handlePlaceOrder(total),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customPink,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Place an Order', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String trailing;
  final VoidCallback onTrailingTap;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.trailing,
    required this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        InkWell(
          onTap: onTrailingTap,
          child: Text(trailing, style: TextStyle(color: customPink, fontSize: 14)),
        ),
      ],
    );
  }
}

class _AddressDisplay extends StatelessWidget {
  final Address address;

  const _AddressDisplay({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(address.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(address.phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(address.address, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
    );
  }
}

class _AddressEditor extends StatefulWidget {
  final Address address;
  final Function(Address) onAddressChange;
  final VoidCallback onSave;

  const _AddressEditor({
    required this.address,
    required this.onAddressChange,
    required this.onSave,
  });

  @override
  State<_AddressEditor> createState() => _AddressEditorState();
}

class _AddressEditorState extends State<_AddressEditor> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address.name);
    _phoneController = TextEditingController(text: widget.address.phone);
    _addressController = TextEditingController(text: widget.address.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _updateAddress() {
    widget.onAddressChange(widget.address.copyWith(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            onChanged: (value) => _updateAddress(),
            decoration: const InputDecoration(hintText: 'Nama Penerima', contentPadding: EdgeInsets.all(8), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            onChanged: (value) => _updateAddress(),
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'No. Telepon', contentPadding: EdgeInsets.all(8), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _addressController,
            onChanged: (value) => _updateAddress(),
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Alamat Lengkap', contentPadding: EdgeInsets.all(8), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: customPink,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan Alamat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}