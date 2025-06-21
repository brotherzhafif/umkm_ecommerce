import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_page.dart';
import 'menu_produk_page.dart';
import 'data_pesanan_page.dart';
import '../widgets/drawer_admin.dart';

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
  void initState() {
    super.initState();
    // Lock orientation to landscape when entering admin panel
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore orientation to allow all when leaving admin panel
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset('assets/icon.png', width: 28, height: 28),
            ),
            const SizedBox(width: 16),
            const Text('Admin Panel', style: TextStyle(color: Colors.white)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
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
      drawer: DrawerAdmin(
        selectedIndex: selectedIndex,
        onTap: (i) {
          setState(() => selectedIndex = i);
          Navigator.pop(context);
        },
      ),
      body:
          isWide
              ? Row(
                children: [
                  Container(
                    width: 220,
                    color: Colors.lightBlue,
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        _SidebarMenu(
                          selectedIndex: selectedIndex,
                          onTap: (i) => setState(() => selectedIndex = i),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey[100],
                      child: pages[selectedIndex],
                    ),
                  ),
                ],
              )
              : Container(
                color: Colors.grey[100],
                width: double.infinity,
                height: double.infinity,
                child: pages[selectedIndex],
              ),
    );
  }
}

class _SidebarMenu extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  const _SidebarMenu({required this.selectedIndex, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SidebarItem(
          icon: Icons.dashboard,
          label: 'Dashboard',
          selected: selectedIndex == 0,
          onTap: () => onTap(0),
        ),
        _SidebarItem(
          icon: Icons.food_bank,
          label: 'Menu Produk',
          selected: selectedIndex == 1,
          onTap: () => onTap(1),
        ),
        _SidebarItem(
          icon: Icons.receipt_long,
          label: 'Data Pesanan',
          selected: selectedIndex == 2,
          onTap: () => onTap(2),
        ),
        const SizedBox(height: 24),
        const Divider(color: Colors.white70),
        _SidebarItem(
          icon: Icons.bar_chart,
          label: 'Laporan Penjualan',
          selected: false,
          onTap: () {},
        ),
        _SidebarItem(
          icon: Icons.monetization_on,
          label: 'Laporan Keuntungan',
          selected: false,
          onTap: () {},
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        label,
        style: TextStyle(color: selected ? Colors.white : Colors.white70),
      ),
      selected: selected,
      selectedTileColor: Colors.lightBlue[700],
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
