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
      child: Container(
        color: Colors.lightBlue,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.lightBlue),
              child: Row(
                children: [
                  Image.asset('assets/icon.png', width: 40, height: 40),
                  const SizedBox(width: 16),
                  const Text(
                    'UMKM Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              selected: selectedIndex == 0,
              leading: const Icon(Icons.dashboard, color: Colors.white),
              title: const Text(
                "Dashboard",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => onTap(0),
            ),
            ListTile(
              selected: selectedIndex == 1,
              leading: const Icon(Icons.food_bank, color: Colors.white),
              title: const Text(
                "Menu Produk",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => onTap(1),
            ),
            ListTile(
              selected: selectedIndex == 2,
              leading: const Icon(Icons.receipt_long, color: Colors.white),
              title: const Text(
                "Data Pesanan",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => onTap(2),
            ),
            ListTile(
              selected: selectedIndex == 3,
              leading: const Icon(Icons.bar_chart, color: Colors.white),
              title: const Text(
                "Laporan",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}
