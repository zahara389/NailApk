import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

// ================= SCREENS =================
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
import 'screens/product_detail_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/voucher_screen.dart';
import 'screens/purchase_history_screen.dart';
import 'screens/purchase_detail_screen.dart';

// ================= CORE =================
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
  List<Product> _products = [];
  Product? _selectedProduct;

  late final Dio _dio;
  late final ApiService _apiService;
  late final CartService _cartService;

  List<GalleryItem> _galleryItems = initialGalleryItems;
  GalleryItem? _selectedGalleryItem;
  List<PurchaseHistory> _purchaseHistory = List.from(dummyPurchaseHistory);
  List<Booking> _bookingHistory = List.from(dummyBookingHistory);
  List<NotificationItem> _notifications = List.from(dummyNotifications);
  List<Voucher> _vouchers = List.from(dummyVouchers);

  @override
  void initState() {
    super.initState();

    _dio = createDio();
    _apiService = ApiService(dio: _dio);
    _cartService = CartService(_dio);

    _loadProducts();
  }

  // ================= LOAD =================
  Future<void> _loadProducts() async {
    final products = await _apiService.fetchProducts();
    setState(() => _products = products);
  }

  Future<void> _loadCart() async {
    final items = await _cartService.fetchCart();
    setState(() => _cart = items);
  }

  // ================= ADD TO CART =================
  Future<void> _handleAddToCart(Product product) async {
    await _cartService.addToCart(productId: product.id, quantity: 1);
    await _loadCart();
  }

  // ================= CHECKOUT =================
  Future<void> _handleCheckout() async {
    await _cartService.checkout();
    setState(() {
      _cart.clear();
      navigate('OrderSuccess');
    });
  }

  // ================= NAVIGATION =================
  void navigate(String view, {dynamic data}) async {
    if (view == 'Cart' || view == 'Checkout') {
      await _loadCart();
    }

    setState(() {
      _navigationData = data;
      if (view == 'Login' || view == 'Register') _history.clear();
      _currentView = view;
      _history.add(view);

      if (view == 'PDP' && data is Product) _selectedProduct = data;
      if (view == 'GalleryDetail' && data is GalleryItem) {
        _selectedGalleryItem = data;
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
              await _loadCart();
            }
            setState(() => _isLoggedIn = v);
          },
          setUserName: (n) => setState(() => _userName = n),
          setUserAddress: (a) => setState(() => _userAddress = a),
        );

      case 'Register':
        return RegisterScreen(navigate: navigate, goBack: goBack);

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
          goBack: goBack,
          navigate: navigate,
          newArrivals: _products,
          handleAddToCart: _handleAddToCart,
          setNewArrivals: (l) => setState(() => _products = l),
          onRefresh: _loadProducts,
        );

      case 'PDP':
        return ProductDetailScreen(
          goBack: goBack,
          navigate: navigate,
          product: _selectedProduct!,
          newArrivals: _products,
          cartCount: _cart.length,
          setNewArrivals: (l) => setState(() => _products = l),
          handleAddToCart: _handleAddToCart,
        );

      case 'Cart':
        return ShoppingCartScreen(
          goBack: goBack,
          navigate: navigate,
          cart: _cart,
          updateCartQuantity: (id, qty) async {
            if (qty <= 0) {
              await _cartService.removeCartItem(id);
            } else {
              await _cartService.updateCartItem(
                cartItemId: id,
                quantity: qty,
              );
            }
            await _loadCart();
          },
          removeCartItem: (id) async {
            await _cartService.removeCartItem(id);
            await _loadCart();
          },
        );

      case 'Checkout':
        return CheckoutScreen(
          goBack: goBack,
          navigate: navigate,
          cart: _cart,
          onPlaceOrder: _handleCheckout,
        );

      case 'OrderSuccess':
  return OrderSuccessScreen(
    navigate: navigate,
  );

      case 'Booking':
        return BookingScreen(
          goBack: goBack,
          navigate: navigate,
          userName: _userName,
          addBookingToHistory: (b) => _bookingHistory.insert(0, b),
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