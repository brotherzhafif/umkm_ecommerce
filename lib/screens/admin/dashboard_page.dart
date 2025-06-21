import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Dashboard", style: TextStyle(fontSize: 24)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _statCard("Pelanggan Bulan Ini", "120", Icons.people),
            _statCard("Penjualan Bulan Ini", "240", Icons.shopping_cart),
            _statCard(
              "Pendapatan Bulan Ini",
              "Rp 3.500.000",
              Icons.attach_money,
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text("Makanan Favorit"),
        Container(
          height: 200,
          color: Colors.grey[200],
          child: Center(child: Text("Pie Chart Makanan")),
        ),
        const SizedBox(height: 16),
        const Text("Minuman Favorit"),
        Container(
          height: 200,
          color: Colors.grey[200],
          child: Center(child: Text("Pie Chart Minuman")),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
