import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _metricCard(
              'Pelanggan Bulan Ini',
              '120',
              Icons.people,
              Colors.cyan,
            ),
            _metricCard(
              'Penjualan Bulan Ini',
              '240',
              Icons.shopping_cart,
              Colors.lightBlue,
            ),
            _metricCard(
              'Pendapatan Bulan Ini',
              'Rp 3.500.000',
              Icons.attach_money,
              Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Makanan Favorit Bulan Ini',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(child: Text('Pie Chart Makanan')),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _legendDot(Colors.orange),
                          const SizedBox(width: 8),
                          const Text('Nasi Goreng'),
                          const SizedBox(width: 16),
                          _legendDot(Colors.purple),
                          const SizedBox(width: 8),
                          const Text('Ayam Bakar'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Minuman Favorit Bulan Ini',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(child: Text('Pie Chart Minuman')),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _legendDot(Colors.blue),
                          const SizedBox(width: 8),
                          const Text('Es Teh'),
                          const SizedBox(width: 16),
                          _legendDot(Colors.green),
                          const SizedBox(width: 8),
                          const Text('Jus Alpukat'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: color, size: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
