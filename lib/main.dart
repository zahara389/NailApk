import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/all_products_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/shopping_cart_screen.dart';
import 'screens/checkout_screen.dart';

// Config & Components
import 'config.dart';
import 'components/bottom_nav_bar.dart';

// Services
import 'services/api_service.dart';
import 'services/cart_service.dart';
import 'helpers/session_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
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

  bool _isLoggedIn = false;
  String _userName = 'Guest';

  List<CartItem> _cart = [];
  List<Product> _products = [];
  Product? _selectedProduct;

  late final Dio _dio;
  late final ApiService _apiService;
  late final CartService _cartService;

  @override
  void initState() {
    super.initState();

    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        headers: {'Accept': 'application/json'},
      ),
    );

    _apiService = ApiService(dio: _dio);
    _cartService = CartService(_dio);

    _loadProducts();
  }

  // ================= LOAD PRODUCTS =================
  Future<void> _loadProducts() async {
    final products = await _apiService.fetchProducts();
    setState(() => _products = products);
  }

  // ================= LOAD CART =================
  Future<void> _loadCartFromApi() async {
    final items = await _cartService.fetchCart();
    setState(() => _cart = items);
  }

  // ================= ADD TO CART =================
  Future<void> _handleAddToCart(Product product) async {
    await _cartService.addToCart(
      productId: product.id,
      quantity: 1,
    );
    await _loadCartFromApi();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ================= CHECKOUT =================
  Future<void> _handleCheckout() async {
    await _cartService.checkout();
    await _loadCartFromApi();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesanan berhasil dibuat'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _currentView = 'Home';
    });
  }

  // ================= NAVIGATION =================
  void navigate(String view, {dynamic data}) async {
    if (view == 'Cart' || view == 'Checkout') {
      await _loadCartFromApi();
    }

    setState(() {
      _currentView = view;
      if (view == 'PDP' && data is Product) {
        _selectedProduct = data;
      }
    });
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
              await _loadCartFromApi();
            }
            setState(() => _isLoggedIn = v);
          },
          setUserName: (n) => setState(() => _userName = n),
          setUserAddress: (_) {},
        );

      case 'Home':
        return HomeScreen(
          navigate: navigate,
          userDisplayName: _isLoggedIn ? _userName : 'Guest',
          cartCount: _cart.length,
          newArrivals: _products,
          setNewArrivals: (l) => setState(() => _products = l),
          handleAddToCart: _handleAddToCart,
        );

      case 'AllProducts':
        return AllProductsScreen(
          goBack: () => navigate('Home'),
          navigate: navigate,
          newArrivals: _products,
          handleAddToCart: _handleAddToCart,
          setNewArrivals: (l) => setState(() => _products = l),
          onRefresh: _loadProducts,
        );

      case 'PDP':
        return ProductDetailScreen(
          goBack: () => navigate('Home'),
          navigate: navigate,
          product: _selectedProduct!,
          newArrivals: _products,
          cartCount: _cart.length,
          setNewArrivals: (l) => setState(() => _products = l),
          handleAddToCart: _handleAddToCart,
        );

      // ================= CART =================
      case 'Cart':
        return ShoppingCartScreen(
          goBack: () => navigate('Home'),
          navigate: navigate,
          cart: _cart,
          updateCartQuantity: (cartItemId, qty) async {
            if (qty <= 0) {
              await _cartService.removeCartItem(cartItemId);
            } else {
              await _cartService.updateCartItem(
                cartItemId: cartItemId,
                quantity: qty,
              );
            }
            await _loadCartFromApi();
          },
          removeCartItem: (cartItemId) async {
            await _cartService.removeCartItem(cartItemId);
            await _loadCartFromApi();
          },
        );

      // ================= CHECKOUT =================
      case 'Checkout':
        return CheckoutScreen(
          goBack: () => navigate('Cart'),
          navigate: navigate,
          cart: _cart,
          onPlaceOrder: _handleCheckout,
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
          if (_currentView == 'Home' ||
              _currentView == 'AllProducts' ||
              _currentView == 'Cart')
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
