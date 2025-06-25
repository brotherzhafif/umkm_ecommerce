import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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
                  FirebaseFirestore.instance.collection('pesanan').snapshots(),
              builder: (context, pesananSnapshot) {
                // Calculate metrics
                if (!pesananSnapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _metricCard(
                        'Pelanggan Bulan Ini',
                        '0',
                        Icons.people,
                        Colors.cyan,
                      ),
                      _metricCard(
                        'Penjualan Bulan Ini',
                        '0',
                        Icons.shopping_cart,
                        Colors.lightBlue,
                      ),
                      _metricCard(
                        'Pendapatan Bulan Ini',
                        'Rp 0',
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ],
                  );
                }

                // Get current month orders
                final now = DateTime.now();
                final startOfMonth = DateTime(now.year, now.month, 1);

                // Count unique customers from orders this month
                final Set<String> uniqueCustomers = {};
                int totalPesanan = 0;
                int totalPendapatan = 0;

                for (var doc in pesananSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final Timestamp? orderTimestamp =
                      data['tanggal'] as Timestamp?;

                  // Skip if no timestamp
                  if (orderTimestamp == null) continue;

                  final orderDate = orderTimestamp.toDate();

                  // Check if order is from current month
                  if (orderDate.isAfter(startOfMonth)) {
                    // Count the order
                    totalPesanan++;

                    // Add revenue
                    totalPendapatan += (data['total'] as int?) ?? 0;

                    // Add unique customer name to set
                    final customerName = data['pelanggan'] as String?;
                    if (customerName != null && customerName.isNotEmpty) {
                      uniqueCustomers.add(customerName);
                    }
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
                      '${uniqueCustomers.length}',
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

    // Take top 5 products for the chart
    final topProducts = sortedProducts.take(5).toList();

    // Prepare pie chart data
    final List<PieChartSectionData> sections = [];
    final List<Color> chartColors = [
      color,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    // Calculate the total of top products for percentage
    final int totalCount = topProducts.fold(
      0,
      (sum, product) => sum + product.value,
    );

    // Create sections for pie chart
    for (int i = 0; i < topProducts.length; i++) {
      final product = topProducts[i];
      final percentage =
          totalCount > 0
              ? (product.value / totalCount * 100).toStringAsFixed(1)
              : '0';

      sections.add(
        PieChartSectionData(
          value: product.value.toDouble(),
          title: '$percentage%',
          radius: 50, // Reduced radius from 70 to 50
          titleStyle: const TextStyle(
            fontSize: 8, // Smaller font size from 10 to 8
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          color: chartColors[i % chartColors.length],
          badgeWidget: null,
          badgePositionPercentageOffset: 1.5,
        ),
      );
    }

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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 220, // Reduced height from 260 to 220
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child:
                            sortedProducts.isEmpty
                                ? Text(
                                  'Belum ada ${title.toLowerCase()} terjual',
                                  style: TextStyle(color: Colors.grey[600]),
                                )
                                : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Add the most popular product at the top
                                      if (sortedProducts.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical:
                                                6, // Reduced padding from 8 to 6
                                          ),

                                          child: Column(
                                            children: [
                                              Text(
                                                'Paling Populer',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      12, // Reduced from default
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                sortedProducts[0].key,
                                                style: const TextStyle(
                                                  fontSize:
                                                      14, // Reduced from 16 to 14
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${sortedProducts[0].value} porsi',
                                                style: TextStyle(
                                                  fontSize:
                                                      12, // Reduced from 14 to 12
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      // Pie chart
                                      Expanded(
                                        child:
                                            topProducts.isEmpty
                                                ? const Center(
                                                  child: Text('Tidak ada data'),
                                                )
                                                : Padding(
                                                  padding: const EdgeInsets.only(
                                                    top:
                                                        4, // Reduced from 8 to 4
                                                    bottom:
                                                        12, // Reduced from 16 to 12
                                                  ),
                                                  child: PieChart(
                                                    PieChartData(
                                                      sections: sections,
                                                      centerSpaceRadius:
                                                          30, // Reduced from 50 to 30
                                                      sectionsSpace:
                                                          2, // Reduced from 4 to 2
                                                      pieTouchData:
                                                          PieTouchData(
                                                            touchCallback:
                                                                (_, __) {},
                                                            enabled: true,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ],
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Legend for the pie chart - cleaner layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          sortedProducts.isEmpty
                              ? [const Text('Tidak ada data yang tersedia')]
                              : [
                                // Title for the legend
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'Persentase Penjualan:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                // Legend items with grid layout for better space usage
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 8,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                  itemCount: topProducts.length,
                                  itemBuilder: (context, i) {
                                    return Row(
                                      children: [
                                        _legendDot(
                                          chartColors[i % chartColors.length],
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${topProducts[i].key.length > 15 ? topProducts[i].key.substring(0, 15) + '...' : topProducts[i].key}',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        if (totalCount > 0)
                                          Text(
                                            '${(topProducts[i].value / totalCount * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    );
                                  },
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
                  shape: BoxShape.circle,
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
