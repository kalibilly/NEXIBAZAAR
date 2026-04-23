import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/index.dart';
import 'services/index.dart';
import 'utils/index.dart';
import 'screens/index.dart';
import 'screens/seller_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final authService = AuthService(apiClient);
    final productService = ProductService(apiClient);
    final orderService = OrderService(apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
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
            home: const HomeScreen(),
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
}
