import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gal/gal.dart';
import '../config.dart';

class CheckoutScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final List<CartItem> cart;
  
  // 🔥 Callback wajib agar terhubung ke main.dart
  final VoidCallback onPlaceOrder; 

  const CheckoutScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.cart,
    required this.onPlaceOrder,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isShippingEdit = false;
  String _selectedPayment = 'Visa';
  String _selectedShipping = availableLocations.first.key;

  // Data Alamat Default (Dummy)
  Address _shippingAddress = Address(
    name: 'Zahara Cantik',
    phone: '0812-3456-7890',
    address: 'Jl. Telekomunikasi No. 1, Terusan Buahbatu, Bandung',
    email: 'zahara@email.com'
  );

  final List<Map<String, dynamic>> paymentMethods = const [
    {'key': 'Visa', 'label': 'Kartu Kredit/Debit', 'icon': LucideIcons.creditCard},
    {'key': 'QRIS', 'label': 'QRIS (Gopay/Dana)', 'icon': LucideIcons.qrCode},
    {'key': 'COD', 'label': 'COD (Bayar di Tempat)', 'icon': LucideIcons.banknote},
  ];

  final List<Location> locationOptions = availableLocations;

  int _calculateSubtotal() {
    return widget.cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  }

  int _calculateShippingCost(int subtotal) {
    const fixedCost = 20000;
    return subtotal > 500000 ? 0 : fixedCost;
  }

  Future<void> _downloadQris() async {
    try {
      final byteData = await rootBundle.load('assets/images/qris-code.jpg');
      await Gal.putImageBytes(byteData.buffer.asUint8List());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QRIS berhasil disimpan ke galeri.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan QRIS.')),
      );
    }
  }

  void _handlePlaceOrder() {
    // 1. Tampilkan Dialog Sukses
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
              child: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 20),
            const Text("Pesanan Diterima!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text("Terima kasih telah berbelanja.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(ctx); // Tutup dialog
                  widget.onPlaceOrder(); // 🔥 Panggil fungsi clear cart di main.dart
                },
                child: const Text("Kembali ke Home", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleAddressChange(Address newAddress) {
    setState(() {
      _shippingAddress = newAddress;
    });
  }

  void _handleAddressSave() {
    setState(() => _isShippingEdit = false);
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();
    final shipping = _calculateShippingCost(subtotal);
    final total = subtotal + shipping;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: widget.goBack,
        ),
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 16, 
              bottom: 120 + bottomPadding
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ALAMAT PENGIRIMAN
                _SectionHeader(
                  title: 'Alamat Pengiriman',
                  icon: LucideIcons.mapPin,
                  trailing: _isShippingEdit ? 'Batal' : 'Ubah',
                  onTrailingTap: () => setState(() => _isShippingEdit = !_isShippingEdit),
                ),
                const SizedBox(height: 12),
                _isShippingEdit
                    ? _AddressEditor(
                        address: _shippingAddress,
                        onAddressChange: _handleAddressChange,
                        onSave: _handleAddressSave,
                      )
                    : _AddressDisplay(address: _shippingAddress),
                
                const SizedBox(height: 24),

                // 2. METODE PEMBAYARAN
                _SectionHeader(
                  title: 'Metode Pembayaran',
                  icon: LucideIcons.creditCard,
                  trailing: '',
                  onTrailingTap: () {},
                ),
                const SizedBox(height: 12),
                ...paymentMethods.map((method) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _PaymentOption(
                    icon: method['icon'] as IconData,
                    label: method['label'] as String,
                    isSelected: _selectedPayment == method['key'],
                    onSelect: () => setState(() => _selectedPayment = method['key'] as String),
                  ),
                )),

                // QRIS Preview (muncul hanya jika QRIS dipilih)
                if (_selectedPayment == 'QRIS') ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Scan QRIS untuk membayar',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/qris-code.jpg',
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nominal: ${formatRupiah(total)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: customPink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pastikan membayar sesuai nominal di atas.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: customPink,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _downloadQris,
                            icon: const Icon(LucideIcons.download, color: Colors.white, size: 18),
                            label: const Text(
                              'Download QRIS',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // 3. OPSI PENGIRIMAN
                const Text('Opsi Pengiriman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...locationOptions.map((option) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _ShippingOption(
                    label: 'Reguler (${option.name.split('(').first.trim()})',
                    cost: shipping,
                    duration: 'Est. 3-5 hari',
                    isSelected: _selectedShipping == option.key,
                    onSelect: () => setState(() => _selectedShipping = option.key),
                  ),
                )),

                const SizedBox(height: 24),

                // 4. RINGKASAN HARGA
                _TotalReview(subtotal: subtotal, shipping: shipping, total: total),
              ],
            ),
          ),

          // 5. TOMBOL ORDER (FIXED BOTTOM)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Tagihan:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(formatRupiah(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: customPink)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _handlePlaceOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customPink,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Buat Pesanan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 🔥 WIDGETS TAMBAHAN (LANGSUNG DI SINI AGAR TIDAK ERROR) 🔥
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String trailing;
  final VoidCallback onTrailingTap;

  const _SectionHeader({required this.title, required this.icon, required this.trailing, required this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, size: 20, color: customPink),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        if (trailing.isNotEmpty)
          InkWell(
            onTap: onTrailingTap,
            child: Text(trailing, style: const TextStyle(color: customPink, fontWeight: FontWeight.w600)),
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(address.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(address.phone, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(address.address, style: TextStyle(color: Colors.grey.shade600)),
      ]),
    );
  }
}

class _AddressEditor extends StatefulWidget {
  final Address address;
  final Function(Address) onAddressChange;
  final VoidCallback onSave;

  const _AddressEditor({required this.address, required this.onAddressChange, required this.onSave});

  @override
  State<_AddressEditor> createState() => _AddressEditorState();
}

class _AddressEditorState extends State<_AddressEditor> {
  late TextEditingController _nameCtrl, _phoneCtrl, _addrCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.address.name);
    _phoneCtrl = TextEditingController(text: widget.address.phone);
    _addrCtrl = TextEditingController(text: widget.address.address);
  }

  void _save() {
    widget.onAddressChange(widget.address.copyWith(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      address: _addrCtrl.text,
    ));
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama Penerima', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(12))),
        const SizedBox(height: 10),
        TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'No. Telepon', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(12))),
        const SizedBox(height: 10),
        TextField(controller: _addrCtrl, decoration: const InputDecoration(labelText: 'Alamat Lengkap', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(12)), maxLines: 2),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _save, 
            style: ElevatedButton.styleFrom(backgroundColor: customPink, foregroundColor: Colors.white),
            child: const Text('Simpan Alamat')
          ),
        ),
      ]),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onSelect;

  const _PaymentOption({required this.icon, required this.label, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? customPink.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? customPink : Colors.grey.shade200),
        ),
        child: Row(children: [
          Icon(icon, color: isSelected ? customPink : Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
          if (isSelected) const Icon(LucideIcons.checkCircle, color: customPink, size: 20),
        ]),
      ),
    );
  }
}

class _ShippingOption extends StatelessWidget {
  final String label;
  final int cost;
  final String duration;
  final bool isSelected;
  final VoidCallback onSelect;

  const _ShippingOption({required this.label, required this.cost, required this.duration, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? customPink.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? customPink : Colors.grey.shade200),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            Text(duration, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ]),
          Text(cost == 0 ? 'Gratis' : formatRupiah(cost), style: TextStyle(fontWeight: FontWeight.bold, color: cost == 0 ? Colors.green : Colors.black)),
        ]),
      ),
    );
  }
}

class _TotalReview extends StatelessWidget {
  final int subtotal;
  final int shipping;
  final int total;

  const _TotalReview({required this.subtotal, required this.shipping, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        _row('Subtotal Produk', formatRupiah(subtotal)),
        const SizedBox(height: 8),
        _row('Biaya Pengiriman', shipping == 0 ? 'Gratis' : formatRupiah(shipping), isGreen: shipping == 0),
        const Divider(height: 24),
        _row('Total Pembayaran', formatRupiah(total), isBold: true),
      ]),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, bool isGreen = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: Colors.grey.shade700)),
      Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isGreen ? Colors.green : (isBold ? customPink : Colors.black), fontSize: isBold ? 16 : 14)),
    ]);
  }
}