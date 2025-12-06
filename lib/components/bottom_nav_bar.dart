import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config.dart';

class BottomNavBar extends StatelessWidget {
  final String currentView;
  final int cartCount;
  final Function(String) navigate;

  const BottomNavBar({
    super.key,
    required this.currentView,
    required this.cartCount,
    required this.navigate,
  });

  // Tentukan tab aktif berdasarkan currentView
  String _determineActiveTab(String view) {
    if (['Home', 'PDP', 'AllProducts'].contains(view)) {
      return 'Home';
    } else if (['Cart', 'Checkout', 'PaymentProcessing', 'OrderSuccess'].contains(view)) {
      return 'Cart';
    } else if (view == 'Account') {
      return 'Account';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final determinedActiveTab = _determineActiveTab(currentView);
    final isHidden = ['Login', 'Register', 'PaymentProcessing', 'OrderSuccess'].contains(currentView);

    if (isHidden) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: LucideIcons.home,
              label: "Home",
              active: determinedActiveTab == 'Home',
              onTap: () => navigate('Home'),
            ),
            _NavItem(
              icon: LucideIcons.sparkles,
              label: "Gaya",
              active: determinedActiveTab == 'Gaya',
              onTap: () => print('Navigasi ke Gaya'),
            ),
            _NavItem(
              icon: LucideIcons.menu,
              label: "Katalog",
              active: determinedActiveTab == 'Katalog',
              onTap: () => print('Navigasi ke Katalog'),
            ),
            _NavItem(
              icon: LucideIcons.shoppingBag,
              label: "Keranjang",
              active: determinedActiveTab == 'Cart',
              count: cartCount,
              onTap: () => navigate('Cart'),
            ),
            _NavItem(
              icon: LucideIcons.user,
              label: "Akun",
              active: determinedActiveTab == 'Account',
              onTap: () => navigate('Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final int count;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    this.count = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? customPink : Colors.grey.shade600;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 24, color: color),
              if (count > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: customPink,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}