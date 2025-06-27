// File: lib/routes.dart
import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';
import 'screens/admin/admin_home.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/admin/dashboard_page.dart';
import 'screens/admin/menu_produk_page.dart';
import 'screens/admin/data_pesanan_page.dart';
import 'screens/admin/detail_pesanan_page.dart';
import 'screens/customer/customer_home.dart';
import 'screens/customer/customer_order_page.dart';
import 'screens/customer/customer_order_history_page.dart';
import 'screens/customer/customer_order_detail_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const WelcomePage(),
  '/login': (context) => const LoginPage(),
  '/admin': (context) => const AdminHome(),
  '/register': (context) => const RegisterPage(),
  '/dashboard': (context) => const DashboardPage(),
  '/menu-produk': (context) => const MenuProdukPage(),
  '/data-pesanan': (context) => const DataPesananPage(),
  '/customer': (context) => const CustomerHome(),
  '/order': (context) {
    final cart =
        ModalRoute.of(context)!.settings.arguments
            as List<Map<String, dynamic>>;
    return CustomerOrderPage(cart: cart);
  },
  '/detail-pesanan': (context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    return DetailPesananPage(pesananId: id);
  },
  '/customer-orders': (context) => const CustomerOrderHistoryPage(),
  '/customer-order-detail': (context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    return CustomerOrderDetailPage(orderId: id);
  },
};
