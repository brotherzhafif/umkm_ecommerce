import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Store analytics data by category
  final Map<String, Map<String, int>> productCountsByCategory = {
    'makanan': {},
    'minuman': {},
  };
  bool isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    setState(() => isLoadingProducts = true);

    try {
      // First, fetch all orders
      final orderSnapshot =
          await FirebaseFirestore.instance.collection('pesanan').get();

      // Process each order to get items
      for (var orderDoc in orderSnapshot.docs) {
        final orderData = orderDoc.data();
        final orderId = orderDoc.id;

        // Get items from the order's subcollection
        final itemsSnapshot =
            await FirebaseFirestore.instance
                .collection('pesanan')
                .doc(orderId)
                .collection('items')
                .get();

        // Process each item in the order
        for (var itemDoc in itemsSnapshot.docs) {
          final itemData = itemDoc.data();

          // Extract item details - using the actual field names from your DB
          final String itemName = itemData['nama'] ?? 'Unknown';
          final int itemQuantity = itemData['jumlah'] ?? 0;

          // Categorize item (since we don't have direct category in items)
          final String category = _categorizeItem(itemName);

          // Add to the appropriate category counter
          if (!productCountsByCategory.containsKey(category)) {
            productCountsByCategory[category] = {};
          }

          // Update the count for this item
          productCountsByCategory[category]![itemName] =
              (productCountsByCategory[category]![itemName] ?? 0) +
              itemQuantity;
        }
      }

      print('Loaded data: ${productCountsByCategory.toString()}');
    } catch (e) {
      print('Error loading product data: $e');
    } finally {
      setState(() => isLoadingProducts = false);
    }
  }

  // Helper method to categorize items by name
  String _categorizeItem(String name) {
    final nameLower = name.toLowerCase();

    // Common food items
    if (nameLower.contains('nasi') ||
        nameLower.contains('ayam') ||
        nameLower.contains('mie') ||
        nameLower.contains('bakso') ||
        nameLower.contains('sate') ||
        nameLower.contains('soto')) {
      return 'makanan';
    }
    // Common drink items
    else if (nameLower.contains('es') ||
        nameLower.contains('jus') ||
        nameLower.contains('teh') ||
        nameLower.contains('kopi') ||
        nameLower.contains('sake')) {
      return 'minuman';
    }
    // Default category
    else {
      return 'makanan'; // Default to food
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metrics row builder
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, userSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('pesanan')
                          .snapshots(),
                  builder: (context, pesananSnapshot) {
                    // Calculate metrics
                    int totalPelanggan =
                        userSnapshot.hasData
                            ? userSnapshot.data!.docs.where((doc) {
                              final userData =
                                  doc.data() as Map<String, dynamic>;
                              return userData['role'] == 'customer';
                            }).length
                            : 0;

                    int totalPesanan =
                        pesananSnapshot.hasData
                            ? pesananSnapshot.data!.docs.length
                            : 0;

                    int totalPendapatan = 0;
                    if (pesananSnapshot.hasData) {
                      for (var doc in pesananSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        totalPendapatan += (data['total'] as int?) ?? 0;
                      }
                    }

                    final currencyFormat = NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    );

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _metricCard(
                          'Pelanggan Bulan Ini',
                          '$totalPelanggan',
                          Icons.people,
                          Colors.cyan,
                        ),
                        _metricCard(
                          'Penjualan Bulan Ini',
                          '$totalPesanan',
                          Icons.shopping_cart,
                          Colors.lightBlue,
                        ),
                        _metricCard(
                          'Pendapatan Bulan Ini',
                          currencyFormat.format(totalPendapatan),
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // Product analytics cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildProductAnalyticsCard(
                    title: 'Makanan Terlaris',
                    productCounts: productCountsByCategory['makanan'] ?? {},
                    color: Colors.orange,
                    isLoading: isLoadingProducts,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildProductAnalyticsCard(
                    title: 'Minuman Terlaris',
                    productCounts: productCountsByCategory['minuman'] ?? {},
                    color: Colors.blue,
                    isLoading: isLoadingProducts,
                  ),
                ),
              ],
            ),

            // Debug section - remove in production
            if (isLoadingProducts)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: Text('Loading product data...')),
              )
            else if (productCountsByCategory['makanan']?.isEmpty == true &&
                productCountsByCategory['minuman']?.isEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Column(
                    children: [
                      const Text('No product data available. Debug info:'),
                      Text(
                        'Categories: ${productCountsByCategory.keys.join(", ")}',
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadProductData,
                        child: const Text('Refresh Data'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductAnalyticsCard({
    required String title,
    required Map<String, int> productCounts,
    required Color color,
    required bool isLoading,
  }) {
    // Sort products by count
    List<MapEntry<String, int>> sortedProducts =
        productCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child:
                            sortedProducts.isEmpty
                                ? Text(
                                  'Belum ada ${title.toLowerCase()} terjual',
                                  style: TextStyle(color: Colors.grey[600]),
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      sortedProducts[0].key,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      '${sortedProducts[0].value} porsi',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 20),
                                    // Simple bar chart visualization
                                    if (sortedProducts.length > 1)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          for (
                                            int i = 0;
                                            i < sortedProducts.length && i < 3;
                                            i++
                                          )
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 30,
                                                    height:
                                                        80 *
                                                        (sortedProducts[i]
                                                                .value /
                                                            sortedProducts[0]
                                                                .value),
                                                    color:
                                                        i == 0
                                                            ? color
                                                            : i == 1
                                                            ? Colors.green
                                                            : Colors.purple,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    sortedProducts[i].key
                                                        .split(' ')
                                                        .first,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Show top products as legend
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          sortedProducts.isEmpty
                              ? [const Text('Tidak ada data yang tersedia')]
                              : [
                                for (
                                  int i = 0;
                                  i < sortedProducts.length && i < 3;
                                  i++
                                )
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        _legendDot(
                                          i == 0
                                              ? color
                                              : i == 1
                                              ? Colors.green
                                              : Colors.purple,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${sortedProducts[i].key} (${sortedProducts[i].value})',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
