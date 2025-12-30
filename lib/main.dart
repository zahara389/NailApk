import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Screens
import 'screens/account_screen.dart';
import 'screens/all_products_screen.dart';
import 'screens/booking_history_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/shopping_cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/gallery_detail_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/order_success_screen.dart';
import 'screens/payment_processing_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/voucher_screen.dart';
import 'screens/purchase_history_screen.dart';
import 'screens/purchase_detail_screen.dart';

// Components, Services & Models
import 'config.dart';
import 'components/bottom_nav_bar.dart';
import 'services/api_service.dart';

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
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
  String _currentView = 'Login';
  final List<String> _history = ['Login'];
  dynamic _navigationData;

  bool _isLoggedIn = false;
  String _userName = 'Guest';
  Address _userAddress = Address(
    name: 'Guest',
    phone: '',
    address: 'Harap login untuk isi alamat.',
    email: '',
  );

  List<CartItem> _cart = [];
  List<Product> _newArrivals = [];
  Product? _selectedProduct;

  late final ApiService _apiService;

  List<GalleryItem> _galleryItems = initialGalleryItems;
  GalleryItem? _selectedGalleryItem;
  PaymentDetails? _paymentDetails;
  List<PurchaseHistory> _purchaseHistory = List.from(dummyPurchaseHistory);
  List<Booking> _bookingHistory = List.from(dummyBookingHistory);
  List<NotificationItem> _notifications = List.from(dummyNotifications);
  List<Voucher> _vouchers = List.from(dummyVouchers);

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _apiService.fetchProducts();
      setState(() => _newArrivals = products);
      debugPrint("API: Berhasil memuat ${products.length} produk.");
    } catch (e) {
      debugPrint('API Error (Load): $e');
    }
  }

  Future<Product?> _createProduct(
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    try {
      final p = await _apiService.createProduct(payload, imagePath: imagePath);
      if (p != null) {
        _loadProducts();
      }
      return p;
    } catch (e) {
      debugPrint('API Error (Create): $e');
      return null;
    }
  }

  Future<Product?> _updateProduct(
    int id,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    try {
      final p = await _apiService.updateProduct(id, payload, imagePath: imagePath);
      if (p != null) {
        _loadProducts();
      }
      return p;
    } catch (e) {
      debugPrint('API Error (Update): $e');
      return null;
    }
  }

  Future<bool> _deleteProduct(int id) async {
    try {
      await _apiService.deleteProduct(id);
      _loadProducts();
      return true;
    } catch (e) {
      debugPrint('API Error (Delete): $e');
      return false;
    }
  }

  void navigate(String view, {dynamic data}) {
    setState(() {
      _navigationData = data;
      if (view == 'Login' || view == 'Register') _history.clear();
      _currentView = view;
      _history.add(view);

      if (view == 'PDP' && data is Product) {
        _selectedProduct = data;
      }
      if (view == 'GalleryDetail' && data is GalleryItem) {
        _selectedGalleryItem = data;
      }
      if (view == 'OrderSuccess') _cart.clear();
    });
  }

  void goBack() {
    if (_history.length > 1) {
      _history.removeLast();
      setState(() => _currentView = _history.last);
    } else {
      navigate('Home');
    }
  }

  void _addPurchaseToHistory(PurchaseHistory order) {
    setState(() {
      _purchaseHistory.insert(0, order);
    });
  }

  void _addBookingToHistory(Booking booking) {
    setState(() {
      _bookingHistory.insert(0, booking);
    });
  }

  void _toggleProductFavorite(Product product) {
    setState(() {
      final index = _newArrivals.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _newArrivals[index] = _newArrivals[index].copyWith(
          isFavorite: !_newArrivals[index].isFavorite,
        );
      }
    });
  }

  void _toggleGalleryFavorite(int itemId) {
    setState(() {
      final index = _galleryItems.indexWhere((g) => g.id == itemId);
      if (index != -1) {
        _galleryItems[index] = _galleryItems[index].copyWith(
          isFavorite: !_galleryItems[index].isFavorite,
        );
      }
      if (_selectedGalleryItem?.id == itemId) {
        _selectedGalleryItem = _galleryItems[index];
      }
    });
  }

  void _markNotificationAsRead(int notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(read: true);
      }
    });
  }

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
        return RegisterScreen(
          navigate: navigate,
          goBack: goBack,
        );

      case 'Home':
        return HomeScreen(
          navigate: navigate,
          userDisplayName: _isLoggedIn ? _userName : 'Guest',
          cartCount: _cart.length,
          newArrivals: _newArrivals,
          setNewArrivals: (list) => setState(() => _newArrivals = list),
          handleAddToCart: (p) => setState(() {
            _cart.add(CartItem(product: p, quantity: 1));
          }),
        );

      case 'AllProducts':
        return AllProductsScreen(
          goBack: goBack,
          navigate: navigate,
          newArrivals: _newArrivals,
          handleAddToCart: (p) => setState(() {
            _cart.add(CartItem(product: p, quantity: 1));
          }),
          setNewArrivals: (list) => setState(() => _newArrivals = list),
          onRefresh: _loadProducts,
          onCreate: (payload, {imagePath}) =>
              _createProduct(payload, imagePath: imagePath),
          onUpdate: (id, payload, {imagePath}) =>
              _updateProduct(id, payload, imagePath: imagePath),
          onDelete: _deleteProduct,
        );

      case 'PDP':
        return ProductDetailScreen(
          goBack: goBack,
          navigate: navigate,
          product: _selectedProduct ?? _newArrivals.first,
          newArrivals: _newArrivals,
          cartCount: _cart.length,
          setNewArrivals: (list) => setState(() => _newArrivals = list),
          handleAddToCart: (p) => setState(() {
            _cart.add(CartItem(product: p, quantity: 1));
          }),
        );

      case 'Cart':
        return ShoppingCartScreen(
          goBack: goBack,
          navigate: navigate,
          cart: _cart,
          updateCartQuantity: (productId, delta) {
            setState(() {
              final index = _cart.indexWhere((item) => item.product.id == productId);
              if (index != -1) {
                if (delta == -9999) {
                  // Hapus item
                  _cart.removeAt(index);
                } else {
                  // Update quantity
                  final newQuantity = _cart[index].quantity + delta;
                  if (newQuantity <= 0) {
                    _cart.removeAt(index);
                  } else {
                    _cart[index] = _cart[index].copyWith(quantity: newQuantity);
                  }
                }
              }
            });
          },
        );

      case 'Checkout':
        return CheckoutScreen(
          goBack: goBack,
          navigate: navigate,
          cart: _cart,
          initialAddress: _userAddress,
          setPaymentDetails: (details) => setState(() {
            _paymentDetails = details;
          }),
          addPurchaseToHistory: _addPurchaseToHistory,
        );

      case 'PaymentProcessing':
        return PaymentProcessingScreen(
          goBack: goBack,
          navigate: navigate,
          paymentDetails: _paymentDetails,
          addPurchaseToHistory: _addPurchaseToHistory,
        );

      case 'OrderSuccess':
        return OrderSuccessScreen(
          navigate: navigate,
        );

      case 'Gallery':
        return GalleryScreen(
          goBack: goBack,
          navigate: navigate,
          galleryItems: _galleryItems,
          toggleFavorite: _toggleGalleryFavorite,
        );

      case 'GalleryDetail':
        return GalleryDetailScreen(
          goBack: goBack,
          navigate: navigate,
          item: _selectedGalleryItem ?? _galleryItems.first,
          toggleFavorite: _toggleGalleryFavorite,
        );

      case 'Booking':
        return BookingScreen(
          goBack: goBack,
          navigate: navigate,
          userName: _userName,
          addBookingToHistory: _addBookingToHistory,
        );

      case 'BookingHistory':
        return BookingHistoryScreen(
          goBack: goBack,
          navigate: navigate,
          history: _bookingHistory,
        );

      case 'Favorites':
        return FavoritesScreen(
          goBack: goBack,
          navigate: navigate,
          newArrivals: _newArrivals,
          galleryItems: _galleryItems,
        );

      case 'Notification':
        return NotificationScreen(
          goBack: goBack,
          navigate: navigate,
          notifications: _notifications,
          markAsRead: _markNotificationAsRead,
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

      case 'Settings':
        return SettingsScreen(
          goBack: goBack,
          navigate: navigate,
        );

      case 'HelpFAQ':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.help_outline, size: 100, color: customPink),
              const SizedBox(height: 20),
              const Text('Help & FAQ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: goBack,
                style: ElevatedButton.styleFrom(backgroundColor: customPink),
                child: const Text('Kembali'),
              ),
            ],
          ),
        );

      case 'Voucher':
        return VoucherScreen(
          goBack: goBack,
          navigate: navigate,
          vouchers: _vouchers,
        );

      case 'PurchaseHistory':
        return PurchaseHistoryScreen(
          goBack: goBack,
          navigate: navigate,
          purchaseHistory: _purchaseHistory,
        );

      case 'PurchaseDetail':
        return PurchaseDetailScreen(
          goBack: goBack,
          order: _navigationData as PurchaseHistory,
        );

      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 100, color: customPink),
              const SizedBox(height: 20),
              Text(
                'Screen: $_currentView',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Screen tidak ditemukan'),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => navigate('Home'),
                style: ElevatedButton.styleFrom(backgroundColor: customPink),
                child: const Text('Kembali ke Home'),
              ),
            ],
          ),
        );
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
              cartCount: _cart.length,
              navigate: navigate,
            ),
          ],
        ),
      ),
    );
  }
}