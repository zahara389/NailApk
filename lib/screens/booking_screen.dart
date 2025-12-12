import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';
import '../components/helper_widgets.dart';

// ===============================
// MODEL YANG DIPERLUKAN
// ===============================
class Booking {
  final String id;
  final String date;
  final String time;
  final String service;
  final String location;
  final String status;

  Booking({
    required this.id,
    required this.date,
    required this.time,
    required this.service,
    required this.location,
    required this.status,
  });
}

class Location {
  final String key;
  final String name;
  final String address;

  Location({
    required this.key,
    required this.name,
    required this.address,
  });
}

// ===============================
// DUMMY LOCATION
// ===============================
final List<Location> availableLocations = [
  Location(
    key: 'STUDIO_A',
    name: 'Nail Studio - Jakarta Pusat',
    address: 'Jl. Melati No. 12, Jakarta Pusat',
  ),
  Location(
    key: 'STUDIO_B',
    name: 'Nail Studio - BSD',
    address: 'The Breeze, BSD City',
  ),
  Location(
    key: 'STUDIO_C',
    name: 'Nail Studio - Bandung',
    address: 'Jl. Riau No. 22, Bandung',
  ),
];

// ===============================
// BOOKING SCREEN
// ===============================
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
    _nameController = TextEditingController(
      text: widget.userName == 'Guest' ? '' : widget.userName,
    );
    _phoneController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_date.isEmpty ||
        _time.isEmpty ||
        _service.isEmpty ||
        _location.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua detail booking.')),
      );
      return;
    }

    final locationData =
        availableLocations.firstWhere((l) => l.key == _location);

    final booking = Booking(
      id: 'BKG${DateTime.now().millisecondsSinceEpoch}',
      date: _date,
      time: _time,
      service: _service,
      location: locationData.name,
      status: 'Confirmed',
    );

    widget.addBookingToHistory(booking);

    setState(() => _isConfirmed = true);
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocation =
        availableLocations.firstWhere((l) => l.key == _location);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.goBack,
        ),
        title: const Text('Booking Layanan Kuku'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: _isConfirmed ? 16 : 130,
            ),
            child: _isConfirmed
                ? _BookingConfirmation(
                    service: _service,
                    date: _date,
                    time: _time,
                    locationName: selectedLocation.name,
                    customerName: _nameController.text,
                    customerPhone: _phoneController.text,
                    customerEmail: _emailController.text,
                    navigate: widget.navigate,
                  )
                : _BookingForm(
                    date: _date,
                    setDate: (v) => setState(() => _date = v),
                    time: _time,
                    setTime: (v) => setState(() => _time = v),
                    service: _service,
                    setService: (v) => setState(() => _service = v),
                    location: _location,
                    setLocation: (v) => setState(() => _location = v),
                    nameController: _nameController,
                    phoneController: _phoneController,
                    emailController: _emailController,
                    services: _availableServices,
                    locations: availableLocations,
                  ),
          ),

          // BOTTOM BUTTON
          if (!_isConfirmed)
            Positioned(
              bottom: 70,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customPink,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ===============================
// BOOKING CONFIRMATION
// ===============================
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
    final formatted = DateTime.tryParse(date);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08), blurRadius: 10)
            ],
            border: Border(top: BorderSide(color: customPink, width: 4)),
          ),
          child: Column(
            children: [
              Icon(LucideIcons.checkCircle, size: 48, color: customPink),
              const SizedBox(height: 16),
              const Text(
                'Booking Berhasil!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Appointment Anda telah dikonfirmasi.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Data Pelanggan:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(customerName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(customerPhone),
                    Text(customerEmail),
                    const Divider(),
                    const Text('Lokasi Studio:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(locationName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    const Text('Layanan & Waktu:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(service,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(
                      formatted == null
                          ? date
                          : '${formatted.day}/${formatted.month}/${formatted.year} • $time',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => navigate('BookingHistory'),
          style: ElevatedButton.styleFrom(
            backgroundColor: customPink,
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'Lihat Riwayat Booking',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// ===============================
// BOOKING FORM
// ===============================
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
  });

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'Pilih Tanggal';
    final d = DateTime.parse(isoDate);
    final m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // DATA DIRI
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _box,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.user, size: 20, color: customPink),
                  const SizedBox(width: 8),
                  const Text('Data Diri',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // LOKASI
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _box,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.mapPin, size: 20, color: customPink),
                  const SizedBox(width: 8),
                  const Text('Pilih Lokasi Studio',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              ...locations.map((loc) {
                final active = loc.key == location;
                return InkWell(
                  onTap: () => setLocation(loc.key),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: active ? customPink : Colors.grey.shade300),
                      color: active ? customPinkLight : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(loc.address,
                                  style: TextStyle(
                                      color: Colors.grey.shade600, fontSize: 12)),
                            ]),
                        if (active)
                          Icon(LucideIcons.check, color: customPink, size: 20),
                      ],
                    ),
                  ),
                );
              })
            ],
          ),
        ),

        const SizedBox(height: 24),

        // LAYANAN & WAKTU
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _box,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Layanan & Waktu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Layanan'),
                value: service.isEmpty ? null : service,
                onChanged: (v) => setService(v!),
                items: services
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final pick = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 120)),
                        );
                        if (pick != null) {
                          setDate(pick.toIso8601String().split('T')[0]);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: _inputStyle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tanggal',
                                      style: TextStyle(
                                          color: Colors.grey.shade600)),
                                  Text(
                                    date.isEmpty
                                        ? 'Pilih tanggal'
                                        : _formatDate(date),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ]),
                            Icon(LucideIcons.calendar,
                                size: 20, color: Colors.grey.shade600),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Waktu'),
                      value: time.isEmpty ? null : time,
                      onChanged: (v) => setTime(v!),
                      items: [
                        '10:00',
                        '11:30',
                        '13:00',
                        '14:30',
                        '16:00',
                        '17:30'
                      ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration get _box => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
        ],
      );

  BoxDecoration get _inputStyle => BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      );
}
