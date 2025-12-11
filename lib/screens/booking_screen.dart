import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

class BookingScreen extends StatefulWidget {
  final VoidCallback goBack;
  final Function(String, {dynamic data}) navigate;
  final String userName;
  final Function(Booking) addBookingToHistory;

  const BookingScreen({
    super.key,
    required this.goBack,
    required this.navigate,
    required this.userName,
    required this.addBookingToHistory,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _date = '';
  String _time = '';
  String _service = '';
  String _location = availableLocations.first.key;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isConfirmed = false;

  final List<String> _availableServices = [
    'Manicure Gel Polish',
    'Pedicure Basic',
    'Nail Art Custom',
    'Refill & Extension'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName == 'Guest' ? '' : widget.userName);
    _phoneController = TextEditingController(text: '081234567890');
    _emailController = TextEditingController(text: 'sarah.nail@mail.com');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_date.isEmpty || _time.isEmpty || _service.isEmpty || _location.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua detail booking.')),
      );
      return;
    }

    final selectedLocationData = availableLocations.firstWhere((l) => l.key == _location);

    final newBooking = Booking(
      id: 'BKG${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
      date: _date,
      time: _time,
      service: _service,
      location: selectedLocationData.name,
      status: 'Confirmed',
    );

    widget.addBookingToHistory(newBooking);

    setState(() {
      _isConfirmed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocationData = availableLocations.firstWhere((l) => l.key == _location);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.goBack,
        ),
        title: const Text(
          'Booking Layanan Kuku',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isConfirmed
            ? _BookingConfirmation(
                service: _service,
                date: _date,
                time: _time,
                locationName: selectedLocationData.name,
                customerName: _nameController.text,
                customerPhone: _phoneController.text,
                customerEmail: _emailController.text,
                navigate: widget.navigate,
              )
            : _BookingForm(
                date: _date,
                setDate: (val) => setState(() => _date = val),
                time: _time,
                setTime: (val) => setState(() => _time = val),
                service: _service,
                setService: (val) => setState(() => _service = val),
                location: _location,
                setLocation: (val) => setState(() => _location = val),
                nameController: _nameController,
                phoneController: _phoneController,
                emailController: _emailController,
                services: _availableServices,
                locations: availableLocations,
                handleSubmit: _handleSubmit,
              ),
      ),
      bottomNavigationBar: _isConfirmed
          ? null
          : Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPink,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }
}

class _BookingConfirmation extends StatelessWidget {
  final String service;
  final String date;
  final String time;
  final String locationName;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final Function(String, {dynamic data}) navigate;

  const _BookingConfirmation({
    required this.service,
    required this.date,
    required this.time,
    required this.locationName,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.navigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            border: Border(top: BorderSide(color: customPink, width: 4)),
          ),
          child: Column(
            children: [
              Icon(LucideIcons.checkCircle, size: 48, color: customPink),
              const SizedBox(height: 16),
              const Text('Booking Berhasil!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Appointment Anda telah dikonfirmasi.', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informasi Pelanggan:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('$customerName | $customerPhone', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(customerEmail, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade700)),
                  const Divider(height: 16, color: Colors.grey),
                  const Text('Lokasi Layanan:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 16, color: customPink),
                      const SizedBox(width: 8),
                      Text(locationName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: customPink)),
                    ],
                  ),
                  const Divider(height: 16, color: Colors.grey),
                  const Text('Layanan & Waktu:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(service, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: customPink)),
                  Text(
                    '${DateTime.parse(date).day}/${DateTime.parse(date).month}/${DateTime.parse(date).year} pada $time',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Kami akan mengirimkan detail dan reminder melalui email.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => navigate('BookingHistory'),
          style: ElevatedButton.styleFrom(
            backgroundColor: customPink,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Lihat Riwayat Booking', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _BookingForm extends StatelessWidget {
  final String date;
  final Function(String) setDate;
  final String time;
  final Function(String) setTime;
  final String service;
  final Function(String) setService;
  final String location;
  final Function(String) setLocation;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final List<String> services;
  final List<Location> locations;
  final VoidCallback handleSubmit;

  const _BookingForm({
    required this.date,
    required this.setDate,
    required this.time,
    required this.setTime,
    required this.service,
    required this.setService,
    required this.location,
    required this.setLocation,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.services,
    required this.locations,
    required this.handleSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.user, size: 20, color: customPink),
                  const SizedBox(width: 8),
                  const Text('Data Diri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              ),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email (untuk konfirmasi)'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.mapPin, size: 20, color: customPink),
                  const SizedBox(width: 8),
                  const Text('Pilih Lokasi Studio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              ...locations.map(
                (loc) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () => setLocation(loc.key),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: loc.key == location ? customPink : Colors.grey.shade300,
                        ),
                        color: loc.key == location ? customPinkLight : Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text(loc.address, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                          if (loc.key == location)
                            Icon(LucideIcons.check, size: 18, color: customPink),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Layanan & Waktu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Layanan Kuku'),
                value: service.isEmpty ? null : service,
                onChanged: (val) => setService(val!),
                items: services
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (pickedDate != null) {
                          setDate(pickedDate.toIso8601String().split('T')[0]);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Tanggal', border: OutlineInputBorder()),
                        child: Text(date.isEmpty ? 'Pilih Tanggal' : date),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Waktu'),
                      value: time.isEmpty ? null : time,
                      onChanged: (val) => setTime(val!),
                      items: ['10:00', '11:30', '13:00', '14:30', '16:00', '17:30']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
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
}
