import 'package:flutter/material.dart';

class DrawerAdmin extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const DrawerAdmin({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text("Admin Panel", style: TextStyle(fontSize: 20)),
            ),
          ),
          ListTile(
            selected: selectedIndex == 0,
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () => onTap(0),
          ),
          ListTile(
            selected: selectedIndex == 1,
            leading: const Icon(Icons.food_bank),
            title: const Text("Menu Produk"),
            onTap: () => onTap(1),
          ),
          ListTile(
            selected: selectedIndex == 2,
            leading: const Icon(Icons.receipt_long),
            title: const Text("Data Pesanan"),
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}
