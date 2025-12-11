import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<CartItem> cart;
  final Function(PaymentDetails) setPaymentDetails;
  final Function(PurchaseHistory) addPurchaseToHistory;
  final Address initialAddress;

  const CheckoutScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.cart,
    required this.setPaymentDetails,
    required this.addPurchaseToHistory,
    required this.initialAddress,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isShippingEdit = false;
  String _selectedPayment = 'Visa';
  String _selectedShipping = availableLocations.first.key;

  late Address _shippingAddress;

  @override
  void initState() {
    super.initState();
    _shippingAddress = widget.initialAddress.copyWith(); 
  }

  final List<Map<String, String>> paymentMethods = const [
    {'key': 'Visa', 'label': 'Kartu Kredit/Debit (Visa **** 1234)', 'icon': 'VISA'},
    {'key': 'QRIS', 'label': 'QRIS (Gopay/Dana/LinkAja)', 'icon': 'QRIS'},
    {'key': 'COD', 'label': 'COD (Bayar di Tempat)', 'icon': 'COD'},
  ];

  final List<Location> locationOptions = availableLocations; 

  int _calculateSubtotal() {
    return widget.cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  }

  int _calculateShippingCost(int subtotal) {
    const fixedCost = 20000;
    return subtotal > 500000 ? 0 : fixedCost;
  }

  void _handlePlaceOrder() {
    final subtotal = _calculateSubtotal();
    final shipping = _calculateShippingCost(subtotal);
    final total = subtotal + shipping;
    
    // 1. Buat objek order baru
    final newOrder = PurchaseHistory(
      id: 'ORD${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}',
      date: DateTime.now().toIso8601String().split('T')[0],
      total: total,
      status: _selectedPayment == 'COD' ? 'Processing' : 'Awaiting Payment',
      items: widget.cart.fold(0, (sum, item) => sum + item.quantity),
    );

    // 2. Finalisasi Order (tergantung metode pembayaran)
    if (_selectedPayment == 'COD') {
      widget.addPurchaseToHistory(newOrder);
      widget.navigate('OrderSuccess');
    } else {
      final paymentInfo = PaymentDetails(
        methodKey: _selectedPayment,
        totalAmount: total,
        shippingMethod: _selectedShipping,
        shippingAddress: _shippingAddress,
        newOrder: newOrder,
      );
      widget.setPaymentDetails(paymentInfo);
      widget.navigate('PaymentProcessing');
    }
  }

  void _handleAddressChange(Address newAddress) {
    _shippingAddress = newAddress;
  }

  void _handleAddressSave() {
    setState(() => _isShippingEdit = false);
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();
    final shipping = _calculateShippingCost(subtotal);
    final total = subtotal + shipping;

    return Scaffold(
      appBar: AppBar(
        leading: BackButtonIcon(onBack: widget.goBack),
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
                  icon: LucideIcons.mapPin,
                  trailing: _isShippingEdit ? 'Cancel' : 'Change',
                  onTrailingTap: () => setState(() => _isShippingEdit = !_isShippingEdit),
                ),
                const SizedBox(height: 12),
                _isShippingEdit ? _AddressEditor(
                  address: _shippingAddress,
                  onAddressChange: _handleAddressChange,
                  onSave: _handleAddressSave,
                ) : _AddressDisplay(address: _shippingAddress),
                const SizedBox(height: 24),

                // 5.2 Payment Method
                _SectionHeader(
                  title: 'Payment Method',
                  icon: LucideIcons.creditCard,
                  trailing: 'Add new',
                  onTrailingTap: () => print('Tambah Kartu'),
                ),
                const SizedBox(height: 12),
                ...paymentMethods.map((method) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: PaymentOption(
                        key: ValueKey(method['key']),
                        icon: method['icon']!,
                        label: method['label']!,
                        isSelected: _selectedPayment == method['key'],
                        onSelect: () => setState(() => _selectedPayment = method['key']!),
                      ),
                    )),
                const SizedBox(height: 24),

                // 5.3 Shipping Method (Menggunakan lokasi sebagai simulasi pilihan)
                const Text('Shipping Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...locationOptions.map((option) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ShippingOption(
                        key: ValueKey(option.key),
                        method: 'Reguler (${option.name.split('(').first.trim()})',
                        cost: shipping, 
                        duration: 'Est. 3-5 hari',
                        selected: _selectedShipping == option.key,
                        onSelect: () => setState(() => _selectedShipping = option.key),
                        formatRupiah: formatRupiah,
                      ),
                    )),
                const SizedBox(height: 24),
                // Total Review
                _TotalReview(subtotal: subtotal, shipping: shipping, total: total),
              ],
            ),
          ),
          // Total dan Tombol Place Order (Fixed Bottom)
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
                    onPressed: _handlePlaceOrder,
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
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address.name);
    _phoneController = TextEditingController(text: widget.address.phone);
    _addressController = TextEditingController(text: widget.address.address);

    // Listener untuk memperbarui address saat diketik
    _nameController.addListener(_updateAddress);
    _phoneController.addListener(_updateAddress);
    _addressController.addListener(_updateAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _updateAddress() {
    final newAddress = Address(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      email: widget.address.email,
    );
    widget.onAddressChange(newAddress);
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      _updateAddress();
      widget.onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
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
              decoration: const InputDecoration(hintText: 'Nama Penerima', contentPadding: EdgeInsets.all(8), border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: 'No. Telepon', contentPadding: EdgeInsets.all(8), border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? 'Telepon tidak boleh kosong' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Alamat Lengkap', contentPadding: EdgeInsets.all(8), border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? 'Alamat tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: customPink,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Simpan Alamat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalReview extends StatelessWidget {
  final int subtotal;
  final int shipping;
  final int total;

  const _TotalReview({
    required this.subtotal,
    required this.shipping,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: formatRupiah(subtotal)),
          _SummaryRow(label: 'Shipping', value: shipping == 0 ? 'Gratis' : formatRupiah(shipping)),
          const Divider(height: 16, color: Colors.grey),
          _SummaryRow(label: 'Total', value: formatRupiah(total), isTotal: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              color: isTotal ? customPink : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}