import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DrawerCustomer extends StatelessWidget {
  final int selectedIndex;

  const DrawerCustomer({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.lightBlue,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.lightBlue),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset('assets/icon.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'UMKM',
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
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text(
                'Menu Produk',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                if (selectedIndex != 0) {
                  Navigator.pushReplacementNamed(context, '/customer');
                }
              },
            ),
            ListTile(
              selected: selectedIndex == 1,
              leading: const Icon(Icons.receipt_long, color: Colors.white),
              title: const Text(
                'Pesanan Saya',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                if (selectedIndex != 1) {
                  Navigator.pushReplacementNamed(context, '/customer-orders');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
