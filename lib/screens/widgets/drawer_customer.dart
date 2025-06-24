import 'package:flutter/material.dart';

class DrawerCustomer extends StatelessWidget {
  final int selectedIndex;

  const DrawerCustomer({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.lightBlue),
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
            leading: const Icon(Icons.home, color: Colors.lightBlue),
            title: const Text('Menu Produk'),
            selected: selectedIndex == 0,
            onTap: () {
              Navigator.pop(context);
              if (selectedIndex != 0) {
                Navigator.pushReplacementNamed(context, '/customer');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.lightBlue),
            title: const Text('Pesanan Saya'),
            selected: selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              if (selectedIndex != 1) {
                Navigator.pushReplacementNamed(context, '/customer-orders');
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
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
    );
  }
}
