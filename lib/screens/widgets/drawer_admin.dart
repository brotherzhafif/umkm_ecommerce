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
            ExpansionTile(
              leading: const Icon(Icons.bar_chart, color: Colors.white),
              title: const Text(
                "Laporan",
                style: TextStyle(color: Colors.white),
              ),
              children: [
                ListTile(
                  selected: selectedIndex == 3,
                  leading: const Icon(Icons.bar_chart, color: Colors.white),
                  title: const Text(
                    "Laporan Penjualan",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => onTap(3),
                ),
                ListTile(
                  selected: selectedIndex == 4,
                  leading: const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                  ),
                  title: const Text(
                    "Laporan Keuntungan",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => onTap(4),
                ),
              ],
            ),
            const Divider(color: Colors.white70),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Yakin ingin logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => false,
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
