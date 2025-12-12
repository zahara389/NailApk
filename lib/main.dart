import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Screens
import 'screens/account_screen.dart';
import 'screens/all_products_screen.dart';
import 'screens/booking_history_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/gallery_detail_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/help_faq_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/order_success_screen.dart';
import 'screens/payment_processing_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/voucher_screen.dart';

// Components & Config
import 'config.dart';
import 'components/bottom_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const NailStudioApp());
}

class NailStudioApp extends StatelessWidget {
  const NailStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nail Studio App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: customPink,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: customPink),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle:
              TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  // Routing State
  String _currentView = 'Login';
  final List<String> _history = ['Login'];

  // User State
  bool _isLoggedIn = false;
  String _userName = 'Guest';
  Address _userAddress =
      Address(name: 'Guest', phone: '', address: 'Harap login untuk isi alamat.', email: '');

  // Product State
  List<CartItem> _cart = [];
  List<Product> _newArrivals = initialNewArrivals;
  Product? _selectedProduct;

  // Gallery State
  List<GalleryItem> _galleryItems = initialGalleryItems;
  GalleryItem? _selectedGalleryItem;

  // Transaction State
  PaymentDetails? _paymentDetails;
  List<PurchaseHistory> _purchaseHistory = dummyPurchaseHistory;
  List<Booking> _bookingHistory = dummyBookingHistory;
  List<NotificationItem> _notifications = dummyNotifications;

  // NAVIGATION
  void navigate(String view, {dynamic data}) {
    setState(() {
      // Login / Register resets history
      if (view == 'Login' || view == 'Register') {
        _history.clear();
      }

      // Home clears to single root
      if (view == 'Home' && _currentView != 'Login' && _currentView != 'Register') {
        _history.removeRange(1, _history.length);
      }

      _currentView = view;
      _history.add(view);

      // Product Detail Picker
      if (view == 'PDP' && data is Product) {
        _selectedProduct = _newArrivals.firstWhere((p) => p.id == data.id);
      } else {
        if (view != 'PDP') _selectedProduct = null;
      }

      // Gallery Detail Picker
      if (view == 'GalleryDetail' && data is GalleryItem) {
        _selectedGalleryItem = _galleryItems.firstWhere((g) => g.id == data.id);
      } else {
        if (view != 'GalleryDetail') _selectedGalleryItem = null;
      }

      // Clear cart after success
      if (view == 'OrderSuccess') _cart.clear();
    });
  }

  void goBack() {
    if (_history.length > 1) {
      _history.removeLast();
      final previousView = _history.last;

      setState(() {
        _currentView = previousView;

        if (previousView != 'PDP') _selectedProduct = null;
        if (previousView != 'GalleryDetail') _selectedGalleryItem = null;
      });
    } else {
      if (_currentView != 'Login' && _currentView != 'Register') {
        navigate('Home');
      }
    }
  }

  // STATE ACTIONS
  void handleAddToCart(Product product) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == product.id);

      if (index >= 0) {
        _cart[index] =
            _cart[index].copyWith(quantity: _cart[index].quantity + 1);
      } else {
        _cart.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  void updateCartQuantity(int id, int delta) {
    setState(() {
      _cart = _cart
          .map((item) => item.product.id == id
              ? item.copyWith(quantity: item.quantity + delta)
              : item)
          .where((item) => item.quantity > 0)
          .toList();
    });
  }

  int get cartCount => _cart.fold(0, (t, i) => t + i.quantity);

  // RENDER VIEW
  Widget _renderView() {
    switch (_currentView) {
      case 'Login':
        return LoginScreen(
          navigate: navigate,
          setIsLoggedIn: (v) => setState(() => _isLoggedIn = v),
          setUserName: (name) => setState(() => _userName = name),
          setUserAddress: (addr) => setState(() => _userAddress = addr),
        );

      case 'Register':
        return RegisterScreen(navigate: navigate, goBack: goBack);

      case 'Home':
        return HomeScreen(
          navigate: navigate,
          userDisplayName: _isLoggedIn ? _userName : 'Guest',
          cartCount: cartCount,
          newArrivals: _newArrivals,
          setNewArrivals: (list) => setState(() => _newArrivals = list),
          handleAddToCart: handleAddToCart,
        );

      case 'PDP':
        if (_selectedProduct == null) {
          return const Center(child: Text("Produk tidak ditemukan."));
        }
        return ProductDetailScreen(
          goBack: goBack,
          navigate: navigate,
          product: _selectedProduct!,
          handleAddToCart: handleAddToCart,
          cartCount: cartCount,
          setNewArrivals: (list) => setState(() => _newArrivals = list),
          newArrivals: _newArrivals, // <--- FIX PENTING
        );

      case 'Cart':
        return ShoppingCartScreen(
          goBack: goBack,
          navigate: navigate,
          cart: _cart,
          updateCartQuantity: updateCartQuantity,
        );

      case 'Checkout':
        return CheckoutScreen(
          goBack: goBack,
          navigate: navigate,
          cart: _cart,
          setPaymentDetails: (p) => setState(() => _paymentDetails = p),
          addPurchaseToHistory: (h) =>
              setState(() => _purchaseHistory = [h, ..._purchaseHistory]),
          initialAddress: _userAddress,
        );

      case 'AllProducts':
        return AllProductsScreen(
          goBack: goBack,
          navigate: navigate,
          newArrivals: _newArrivals,
          handleAddToCart: handleAddToCart,
          setNewArrivals: (list) => setState(() => _newArrivals = list),
        );

      case 'Account':
        return AccountScreen(
          goBack: goBack,
          navigate: navigate,
          isLoggedIn: _isLoggedIn,
          setIsLoggedIn: (v) => setState(() => _isLoggedIn = v),
          userName: _userName,
          purchaseHistory: _purchaseHistory,
          notifications: _notifications,
          userAddress: _userAddress,
          currentView: _currentView,
        );

      case 'Gallery':
        return GalleryScreen(
          navigate: navigate,
          goBack: goBack,
          galleryItems: _galleryItems,
          toggleFavorite: (id) {
            setState(() {
              _galleryItems = _galleryItems
                  .map((i) =>
                      i.id == id ? i.copyWith(isFavorite: !i.isFavorite) : i)
                  .toList();
            });
          },
        );

      case 'GalleryDetail':
        if (_selectedGalleryItem == null) {
          return const Center(child: Text("Galeri tidak ditemukan."));
        }
        return GalleryDetailScreen(
          goBack: goBack,
          item: _selectedGalleryItem!,
          toggleFavorite: (id) {
            setState(() {
              _galleryItems = _galleryItems
                  .map((i) =>
                      i.id == id ? i.copyWith(isFavorite: !i.isFavorite) : i)
                  .toList();
            });
          },
          navigate: navigate,
        );

      case 'PaymentProcessing':
        return PaymentProcessingScreen(
          goBack: goBack,
          navigate: navigate,
          paymentDetails: _paymentDetails,
          addPurchaseToHistory: (h) =>
              setState(() => _purchaseHistory = [h, ..._purchaseHistory]),
        );

      case 'OrderSuccess':
        return OrderSuccessScreen(navigate: navigate);

      case 'Favorites':
        return FavoritesScreen(
          goBack: goBack,
          navigate: navigate,
          newArrivals: _newArrivals,
          galleryItems: _galleryItems,
        );

      case 'Notifications':
        return NotificationScreen(
          goBack: goBack,
          navigate: navigate,
          notifications: _notifications,
          markAsRead: (id) {
            setState(() {
              _notifications = _notifications
                  .map((n) => n.id == id ? n.copyWith(read: true) : n)
                  .toList();
            });
          },
        );

      case 'Booking':
        return BookingScreen(
          goBack: goBack,
          navigate: navigate,
          userName: _userName,
          addBookingToHistory: (b) =>
              setState(() => _bookingHistory = [b, ..._bookingHistory]),
        );

      case 'BookingHistory':
        return BookingHistoryScreen(
          goBack: goBack,
          navigate: navigate,
          history: _bookingHistory,
        );

      case 'Vouchers':
        return VoucherScreen(
          goBack: goBack,
          navigate: navigate,
          vouchers: dummyVouchers,
        );

      case 'Settings':
        return SettingsScreen(
          goBack: goBack,
          navigate: navigate,
        );

      case 'HelpFAQ':
        return HelpFAQScreen(
          goBack: goBack,
          navigate: navigate,
        );

      default:
        return const Center(child: Text("Unknown Route"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            _renderView(),
            BottomNavBar(
              currentView: _currentView,
              cartCount: cartCount,
              navigate: navigate,
            ),
          ],
        ),
      ),
    );
  }
}