import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

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

// Config, Components, Services
import 'config.dart';
import 'components/bottom_nav_bar.dart';
import 'services/api_service.dart';
import 'services/cart_service.dart';
import 'helpers/session_helper.dart';

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
    address: 'Harap login',
    email: '',
  );

  List<CartItem> _cart = [];
  List<Product> _newArrivals = [];
  Product? _selectedProduct;

  late final Dio _dio;
  late final ApiService _apiService;
  late final CartService _cartService;

  @override
  void initState() {
    super.initState();

    _dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      headers: {'Accept': 'application/json'},
    ));

    _apiService = ApiService(dio: _dio);
    _cartService = CartService(_dio);

    _loadProducts();
  }

  // ================= LOAD PRODUCTS =================
  Future<void> _loadProducts() async {
    final products = await _apiService.fetchProducts();
    setState(() => _newArrivals = products);
  }

  // ================= ADD TO CART (API → DB) =================
  Future<void> _handleAddToCart(Product product) async {
    try {
      await _cartService.addToCart(
        productId: product.id,
        quantity: 1,
      );

      debugPrint("✅ ADD TO CART MASUK DB: ${product.name}");

      setState(() {
        final index = _cart.indexWhere((c) => c.product.id == product.id);
        if (index == -1) {
          _cart.add(CartItem(product: product, quantity: 1));
        } else {
          _cart[index] =
              _cart[index].copyWith(quantity: _cart[index].quantity + 1);
        }
      });
    } catch (e) {
      debugPrint("❌ ADD TO CART ERROR: $e");
    }
  }

  // ================= NAVIGATION =================
  void navigate(String view, {dynamic data}) {
    setState(() {
      _navigationData = data;
      if (view == 'Login' || view == 'Register') _history.clear();
      _currentView = view;
      _history.add(view);

      if (view == 'PDP' && data is Product) {
        _selectedProduct = data;
      }
    });
  }

  void goBack() {
    if (_history.length > 1) {
      _history.removeLast();
      setState(() => _currentView = _history.last);
    }
  }

  // ================= RENDER =================
  Widget _renderView() {
    switch (_currentView) {
      case 'Login':
        return LoginScreen(
          navigate: navigate,
          setIsLoggedIn: (v) async {
            final token = await SessionHelper.getToken();
            if (token != null) {
              _dio.options.headers['Authorization'] = 'Bearer $token';
              debugPrint("TOKEN LOGIN: $token");
            }
            setState(() => _isLoggedIn = v);
          },
          setUserName: (name) => setState(() => _userName = name),
          setUserAddress: (addr) => setState(() => _userAddress = addr),
        );

      case 'Home':
        return HomeScreen(
          navigate: navigate,
          userDisplayName: _isLoggedIn ? _userName : 'Guest',
          cartCount: _cart.length,
          newArrivals: _newArrivals,
          setNewArrivals: (l) => setState(() => _newArrivals = l),
          handleAddToCart: _handleAddToCart,
        );

      case 'AllProducts':
        return AllProductsScreen(
          goBack: goBack,
          navigate: navigate,
          newArrivals: _newArrivals,
          handleAddToCart: _handleAddToCart,
          setNewArrivals: (l) => setState(() => _newArrivals = l),
          onRefresh: _loadProducts,
        );

      case 'PDP':
        return ProductDetailScreen(
          goBack: goBack,
          navigate: navigate,
          product: _selectedProduct!,
          newArrivals: _newArrivals,
          cartCount: _cart.length,
          setNewArrivals: (l) => setState(() => _newArrivals = l),
          handleAddToCart: _handleAddToCart,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _renderView(),
          BottomNavBar(
            currentView: _currentView,
            cartCount: _cart.length,
            navigate: navigate,
          ),
        ],
      ),
    );
  }
}
