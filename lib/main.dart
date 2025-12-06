import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Screens
import 'screens/account_screen.dart';
import 'screens/all_products_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/order_success_screen.dart';
import 'screens/payment_processing_screen.dart';
import 'screens/register_screen.dart';
import 'screens/product_detail_screen.dart';

// Components & Config
import 'config.dart';
import 'components/bottom_nav_bar.dart';

void main() {
  // Pastikan warna status bar & navigasi bar sesuai dengan tema
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparan status bar
    statusBarIconBrightness: Brightness.dark, // Icon gelap
    systemNavigationBarColor: Colors.white, // Warna navigasi bar putih
    systemNavigationBarIconBrightness: Brightness.dark, // Icon navigasi bar gelap
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
        fontFamily: 'Roboto', // Menggunakan font default untuk kesederhanaan
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
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
  // State untuk Routing
  String _currentView = 'Login';
  final List<String> _history = ['Login']; // History hanya menyimpan nama view

  // State Otentikasi
  bool _isLoggedIn = false;
  String _userName = 'Guest';

  // State Keranjang
  List<CartItem> _cart = [];
  List<Product> _newArrivals = initialNewArrivals;

  // State Produk Detail
  Product? _selectedProduct;

  // State Pembayaran
  PaymentDetails? _paymentDetails;

  // MARK: - Navigation Functions
  void navigate(String view, {dynamic data}) {
    setState(() {
      _currentView = view;
      _history.add(view);

      if (view == 'PDP' && data is Product) {
        _selectedProduct = data;
      } else if (view != 'PDP') {
        _selectedProduct = null;
      }
    });
    print('Navigating to: $view');
  }

  void goBack() {
    if (_history.length > 1) {
      _history.removeLast();
      final previousView = _history.last;
      setState(() {
        _currentView = previousView;
        if (_currentView != 'PDP') {
          _selectedProduct = null;
        }
      });
      print('Going back to: $_currentView');
    } else {
      // Jika tidak bisa kembali, navigasi ke Home
      if (_currentView != 'Login' && _currentView != 'Register') {
        navigate('Home');
      }
    }
  }

  // MARK: - Cart Functions
  void handleAddToCart(Product product) {
    setState(() {
      final existingItemIndex = _cart.indexWhere((item) => item.product.id == product.id);

      if (existingItemIndex >= 0) {
        // Update quantity
        final existingItem = _cart[existingItemIndex];
        _cart[existingItemIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
      } else {
        // Add new item
        _cart.add(CartItem(product: product, quantity: 1));
      }
    });
    print('Produk ID ${product.id} ditambahkan ke keranjang. Total item: ${cartCount}');
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

  // Hitung total item di keranjang
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  // MARK: - Render View
  Widget _renderView() {
    switch (_currentView) {
      case 'Login':
        return LoginScreen(
          navigate: navigate,
          setIsLoggedIn: (val) => setState(() => _isLoggedIn = val),
          setUserName: (name) => setState(() => _userName = name),
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
        // Tambahkan pengecekan null safety
        if (_selectedProduct == null) {
          // Jika produk tidak ada, kembali ke Home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigate('Home');
          });
          return const Center(child: CircularProgressIndicator());
        }
        return ProductDetailScreen(
          goBack: goBack,
          navigate: navigate,
          product: _selectedProduct!,
          handleAddToCart: handleAddToCart,
          cartCount: cartCount,
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
        );
      case 'AllProducts':
        return AllProductsScreen(
          goBack: goBack,
          navigate: navigate,
          newArrivals: _newArrivals,
          handleAddToCart: handleAddToCart,
        );
      case 'Account':
        return AccountScreen(
          goBack: goBack,
          navigate: navigate,
          isLoggedIn: _isLoggedIn,
          setIsLoggedIn: (val) => setState(() => _isLoggedIn = val),
          userName: _userName,
          currentView: _currentView,
        );
      case 'PaymentProcessing':
        return PaymentProcessingScreen(
          goBack: goBack,
          navigate: navigate,
          paymentDetails: _paymentDetails,
          cart: _cart,
        );
      case 'OrderSuccess':
        return OrderSuccessScreen(navigate: navigate);
      default:
        return Center(child: Text('404 - View not found: $_currentView'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false, // Biarkan layar mengatur padding sendiri
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