import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'menu_produk_page.dart';
import 'data_pesanan_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    DashboardPage(),
    MenuProdukPage(),
    DataPesananPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      drawer:
          isMobile
              ? Drawer(child: ListView(children: _buildDrawerItems()))
              : null,
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.food_bank),
                  label: Text('Produk'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.list_alt),
                  label: Text('Pesanan'),
                ),
              ],
            ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return [
      ListTile(
        title: const Text("Dashboard"),
        onTap: () => setState(() => selectedIndex = 0),
      ),
      ListTile(
        title: const Text("Produk"),
        onTap: () => setState(() => selectedIndex = 1),
      ),
      ListTile(
        title: const Text("Pesanan"),
        onTap: () => setState(() => selectedIndex = 2),
      ),
    ];
  }
}
