import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; 

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
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.grey.shade600),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: customPink, width: 2)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
          border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
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
  // State untuk Routing
  String _currentView = 'Login';
  final List<String> _history = ['Login'];

  // State Otentikasi
  bool _isLoggedIn = false;
  String _userName = 'Guest';
  Address _userAddress = Address(name: 'Guest', phone: '', address: 'Harap login untuk mengisi alamat.', email: '');

  // State Produk dan Galeri
  List<CartItem> _cart = [];
  List<Product> _newArrivals = initialNewArrivals;
  List<GalleryItem> _galleryItems = initialGalleryItems;
  
  // State Detail
  Product? _selectedProduct;
  GalleryItem? _selectedGalleryItem;

  // State Transaksi
  PaymentDetails? _paymentDetails;
  List<PurchaseHistory> _purchaseHistory = dummyPurchaseHistory;
  List<Booking> _bookingHistory = dummyBookingHistory;
  List<NotificationItem> _notifications = dummyNotifications;


  // MARK: - Navigation Functions
  void navigate(String view, {dynamic data}) {
    setState(() {
      if (view == 'Login' || view == 'Register') {
        _history.clear();
      }
      
      if (view == 'Home' && _currentView != 'Login' && _currentView != 'Register') {
        _history.removeRange(1, _history.length);
      }

      _currentView = view;
      _history.add(view);

      // Handle selection updates
      if (view == 'PDP' && data is Product) {
        _selectedProduct = _newArrivals.firstWhere((p) => p.id == data.id);
      } else {
        _selectedProduct = null;
      }
      
      if (view == 'GalleryDetail' && data is GalleryItem) {
        _selectedGalleryItem = _galleryItems.firstWhere((g) => g.id == data.id);
      } else {
        _selectedGalleryItem = null;
      }
      
      // Clear cart after OrderSuccess
      if (view == 'OrderSuccess') {
        _cart.clear();
      }
    });
  }

  void goBack() {
    if (_history.length > 1) {
      _history.removeLast();
      final previousView = _history.last;
      setState(() {
        _currentView = previousView;
        
        // Clear selected items if not returning to their specific detail screens
        if (previousView != 'PDP') _selectedProduct = null;
        if (previousView != 'GalleryDetail') _selectedGalleryItem = null;
      });
    } else {
      if (_currentView != 'Login' && _currentView != 'Register') {
        navigate('Home');
      }
    }
  }
  
  // MARK: - State Management Functions
  
  void setUserAddress(Address address) {
    setState(() {
      _userAddress = address;
    });
  }
  
  void toggleProductFavorite(int productId) {
    setState(() {
      _newArrivals = _newArrivals.map((p) {
        if (p.id == productId) {
          return p.copyWith(isFavorite: !p.isFavorite);
        }
        return p;
      }).toList();
    });
  }

  void toggleGalleryFavorite(int itemId) {
    setState(() {
      _galleryItems = _galleryItems.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isFavorite: !item.isFavorite);
        }
        return item;
      }).toList();
    });
  }

  void handleAddToCart(Product product) {
    setState(() {
      final existingItemIndex = _cart.indexWhere((item) => item.product.id == product.id);

      if (existingItemIndex >= 0) {
        final existingItem = _cart[existingItemIndex];
        _cart[existingItemIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
      } else {
        final masterProduct = _newArrivals.firstWhere((p) => p.id == product.id);
        _cart.add(CartItem(product: masterProduct, quantity: 1));
      }
    });
  }

  void updateCartQuantity(int productId, int delta) {
    setState(() {
      final updatedCart = _cart.map((item) {
        if (item.product.id == productId) {
          return item.copyWith(quantity: item.quantity + delta);
        }
        return item;
      }).where((item) => item.quantity > 0).toList();

      _cart = updatedCart;
    });
  }
  
  void addPurchaseToHistory(PurchaseHistory order) {
    setState(() {
      _purchaseHistory = [order, ..._purchaseHistory];
      _cart.clear();
    });
  }

  void addBookingToHistory(Booking booking) {
    setState(() {
      _bookingHistory = [booking, ..._bookingHistory];
    });
  }

  void markNotificationAsRead(int id) {
    setState(() {
      _notifications = _notifications.map((n) => n.id == id ? n.copyWith(read: true) : n).toList();
    });
  }
  
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  // MARK: - Render View
  Widget _renderView() {
    switch (_currentView) {
      case 'Login':
        return LoginScreen(
          navigate: navigate,
          setIsLoggedIn: (val) => setState(() => _isLoggedIn = val),
          setUserName: (name) => setState(() => _userName = name),
          setUserAddress: setUserAddress,
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
          currentView: _currentView,
        );
      case 'PDP':
        if (_selectedProduct == null) return const Center(child: Text('Produk tidak ditemukan.'));
        return ProductDetailScreen(
          goBack: goBack,
          navigate: navigate,
          product: _selectedProduct!,
          handleAddToCart: handleAddToCart,
          cartCount: cartCount,
          setNewArrivals: (list) => setState(() => _newArrivals = list),
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
          setPaymentDetails: (details) => setState(() => _paymentDetails = details),
          addPurchaseToHistory: addPurchaseToHistory,
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
          setIsLoggedIn: (val) => setState(() => _isLoggedIn = val),
          userName: _userName,
          currentView: _currentView,
          purchaseHistory: _purchaseHistory,
          notifications: _notifications,
          userAddress: _userAddress,
        );
      case 'PaymentProcessing':
        return PaymentProcessingScreen(
          goBack: goBack,
          navigate: navigate,
          paymentDetails: _paymentDetails,
          addPurchaseToHistory: addPurchaseToHistory,
        );
      case 'OrderSuccess':
        return OrderSuccessScreen(navigate: navigate);
      case 'Gallery':
        return GalleryScreen(
          navigate: navigate, 
          goBack: goBack, 
          galleryItems: _galleryItems, 
          toggleFavorite: toggleGalleryFavorite, 
        );
      case 'GalleryDetail':
        if (_selectedGalleryItem == null) return const Center(child: Text('Galeri tidak ditemukan.'));
        return GalleryDetailScreen(
          goBack: goBack, 
          item: _selectedGalleryItem!, 
          toggleFavorite: toggleGalleryFavorite, 
          navigate: navigate,
        );
      case 'Booking':
        return BookingScreen(
          goBack: goBack, 
          navigate: navigate, 
          userName: _userName, 
          addBookingToHistory: addBookingToHistory,
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
      case 'Notifications':
        return NotificationScreen(
          goBack: goBack, 
          navigate: navigate, 
          notifications: _notifications, 
          markAsRead: markNotificationAsRead,
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
        return HomeScreen(
          navigate: navigate,
          userDisplayName: _isLoggedIn ? _userName : 'Guest',
          cartCount: cartCount,
          newArrivals: _newArrivals,
          setNewArrivals: (list) => setState(() => _newArrivals = list),
          handleAddToCart: handleAddToCart,
          currentView: _currentView,
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
              cartCount: cartCount,
              navigate: navigate,
            ),
          ],
        ),
      ),
    );
  }
}