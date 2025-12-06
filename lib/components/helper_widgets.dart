import 'package:flutter/material.dart';
import '../config.dart';

// Widget ikon Checkmark kustom
class CustomCheckmark extends StatelessWidget {
  final double size;
  const CustomCheckmark({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.check, size: size);
  }
}

// Widget untuk tombol kembali dengan ChevronLeft
class BackButtonIcon extends StatelessWidget {
  final VoidCallback onBack;
  const BackButtonIcon({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.chevron_left, size: 28),
      onPressed: onBack,
    );
  }
}

// Widget Ikon Sosial (Placeholder)
class SocialIcon extends StatelessWidget {
  final Widget icon;
  final VoidCallback onClick;
  const SocialIcon({super.key, required this.icon, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(child: icon),
      ),
    );
  }
}

// Opsi Pembayaran untuk Checkout Screen
class PaymentOption extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onSelect;

  const PaymentOption({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onSelect,
  });

  Widget _getIconElement() {
    if (icon == 'VISA') {
      return Image.network(
        "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/200px-Visa_Inc._logo.svg.png",
        width: 32,
        height: 24,
        fit: BoxFit.contain,
      );
    } else if (icon == 'QRIS') {
      return const Text('QRIS', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 12));
    } else if (icon == 'COD') {
      return const Text('COD', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 12));
    } else {
      return Text(icon, style: const TextStyle(fontSize: 20));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? customPink : Colors.grey.shade200,
          ),
          color: isSelected ? customPinkLight : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(width: 32, height: 24, child: Center(child: _getIconElement())),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            if (isSelected)
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: customPink,
                  shape: BoxShape.circle,
                ),
                child: const CustomCheckmark(size: 12),
              ),
          ],
        ),
      ),
    );
  }
}

// Opsi Pengiriman untuk Checkout Screen
class ShippingOption extends StatelessWidget {
  final String method;
  final int cost;
  final String duration;
  final bool selected;
  final VoidCallback onSelect;

  const ShippingOption({
    super.key,
    required this.method,
    required this.cost,
    required this.duration,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? customPink : Colors.grey.shade200,
          ),
          color: selected ? customPinkLight : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(duration, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            Text(cost == 0 ? 'Gratis' : formatRupiah(cost), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}