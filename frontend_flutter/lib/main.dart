import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/index.dart';
import 'services/index.dart';
import 'utils/index.dart';
import 'screens/index.dart';
import 'screens/seller_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API client
  final apiClient = ApiClient();
  await apiClient.initialize();
  
  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatefulWidget {
  final ApiClient apiClient;
  
  const MyApp({
    Key? key,
    required this.apiClient,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    // Initialize AuthProvider and restore user
    final authService = AuthService(widget.apiClient);
    _authProvider = AuthProvider(authService);
    _authProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final productService = ProductService(widget.apiClient);
    final orderService = OrderService(widget.apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        Provider(create: (_) => productService),
        Provider(create: (_) => orderService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'NexiBazaar E-Commerce',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.mode,
            home: _buildHome(),
            routes: {
              '/home': (_) => const HomeScreen(),
              '/cart': (_) => const CartScreen(),
              '/orders': (_) => const OrdersScreen(),
              '/seller-dashboard': (_) => const SellerDashboardScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
            },
          );
        },
      ),
    );
  }

  /// Build home screen - show splash during init, then login or home
  Widget _buildHome() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Show loading/splash while initializing
        if (!auth.isInitialized) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 64, color: Colors.blue),
                  SizedBox(height: 24),
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading NexiBazaar...'),
                ],
              ),
            ),
          );
        }

        // Show login if not authenticated
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        // Show home if authenticated
        return const HomeScreen();
      },
    );
  }
}
