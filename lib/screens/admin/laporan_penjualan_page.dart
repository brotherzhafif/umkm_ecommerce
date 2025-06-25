import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LaporanPenjualanPage extends StatefulWidget {
  const LaporanPenjualanPage({super.key});

  @override
  State<LaporanPenjualanPage> createState() => _LaporanPenjualanPageState();
}

class _LaporanPenjualanPageState extends State<LaporanPenjualanPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> salesData = [];
  DateTimeRange? selectedDateRange;
  String selectedPeriod = 'all'; // 'all', 'daily', 'weekly', 'monthly'

  @override
  void initState() {
    super.initState();
    // Set default date range to current month
    final now = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
    _loadSalesData();
  }

  Future<void> _loadSalesData() async {
    setState(() => isLoading = true);

    try {
      // Query orders from Firestore
      final QuerySnapshot ordersSnapshot =
          await FirebaseFirestore.instance
              .collection('pesanan')
              .orderBy('tanggal', descending: true)
              .get();

      List<Map<String, dynamic>> newSalesData = [];

      // Process each order
      for (var doc in ordersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final orderId = doc.id;
        final Timestamp? timestamp = data['tanggal'] as Timestamp?;
        final DateTime orderDate = timestamp?.toDate() ?? DateTime.now();

        // Apply date filter if selected
        if (selectedDateRange != null) {
          if (orderDate.isBefore(selectedDateRange!.start) ||
              orderDate.isAfter(
                selectedDateRange!.end.add(const Duration(days: 1)),
              )) {
            continue; // Skip orders outside date range
          }
        }

        // Get order items
        final QuerySnapshot itemsSnapshot =
            await FirebaseFirestore.instance
                .collection('pesanan')
                .doc(orderId)
                .collection('items')
                .get();

        // Process order details
        final List<Map<String, dynamic>> items =
            itemsSnapshot.docs
                .map((itemDoc) => itemDoc.data() as Map<String, dynamic>)
                .toList();

        // Add to sales data
        newSalesData.add({
          'id': orderId,
          'tanggal': orderDate,
          'pelanggan': data['pelanggan'] ?? 'Unknown',
          'status': data['status'] ?? 'Unknown',
          'total': data['total'] ?? 0,
          'items': items,
        });
      }

      // Sort by date (newest first)
      newSalesData.sort(
        (a, b) =>
            (b['tanggal'] as DateTime).compareTo(a['tanggal'] as DateTime),
      );

      setState(() {
        salesData = newSalesData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading sales data: $e');
      setState(() => isLoading = false);
    }
  }

  // Calculate summary metrics
  Map<String, dynamic> _calculateSummary() {
    int totalOrders = salesData.length;
    int totalRevenue = salesData.fold(
      0,
      (sum, order) => sum + (order['total'] as int),
    );
    int totalItems = salesData.fold(0, (sum, order) {
      final items = order['items'] as List<Map<String, dynamic>>;
      return sum +
          items.fold(0, (itemSum, item) => itemSum + (item['jumlah'] as int));
    });

    // Calculate average order value
    double averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'totalItems': totalItems,
      'averageOrderValue': averageOrderValue,
    };
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Select date range
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.lightBlue),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null && pickedRange != selectedDateRange) {
      setState(() {
        selectedDateRange = pickedRange;
        selectedPeriod = 'custom';
      });
      _loadSalesData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _calculateSummary();
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title and period selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Laporan Penjualan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: selectedPeriod,
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('Semua Waktu'),
                        ),
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text('Hari Ini'),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('Minggu Ini'),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('Bulan Ini'),
                        ),
                        DropdownMenuItem(
                          value: 'custom',
                          child: Text('Kustom'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        final now = DateTime.now();
                        DateTimeRange? newRange;

                        switch (value) {
                          case 'all':
                            newRange = null;
                            break;
                          case 'daily':
                            newRange = DateTimeRange(
                              start: DateTime(now.year, now.month, now.day),
                              end: now,
                            );
                            break;
                          case 'weekly':
                            newRange = DateTimeRange(
                              start: now.subtract(
                                Duration(days: now.weekday - 1),
                              ),
                              end: now,
                            );
                            break;
                          case 'monthly':
                            newRange = DateTimeRange(
                              start: DateTime(now.year, now.month, 1),
                              end: DateTime(now.year, now.month + 1, 0),
                            );
                            break;
                          case 'custom':
                            _selectDateRange(context);
                            return;
                        }

                        setState(() {
                          selectedDateRange = newRange;
                          selectedPeriod = value;
                        });
                        _loadSalesData();
                      },
                    ),
                    const SizedBox(width: 16),
                    if (selectedPeriod == 'custom')
                      OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          selectedDateRange != null
                              ? '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}'
                              : 'Pilih Tanggal',
                        ),
                        onPressed: () => _selectDateRange(context),
                      ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Data',
                      onPressed: _loadSalesData,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Summary cards
            Column(
              children: [
                Row(
                  children: [
                    _summaryCard(
                      'Total Pesanan',
                      summary['totalOrders'].toString(),
                      Icons.receipt,
                      Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _summaryCard(
                      'Total Pendapatan',
                      currencyFormat.format(summary['totalRevenue']),
                      Icons.monetization_on,
                      Colors.green,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _summaryCard(
                      'Total Item Terjual',
                      summary['totalItems'].toString(),
                      Icons.shopping_cart,
                      Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    _summaryCard(
                      'Rata-rata Nilai Pesanan',
                      currencyFormat.format(summary['averageOrderValue']),
                      Icons.bar_chart,
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sales data table
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Riwayat Penjualan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : salesData.isEmpty
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Tidak ada data penjualan untuk periode ini',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                        : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.grey.shade100,
                            ),
                            columns: const [
                              DataColumn(label: Text('No.')),
                              DataColumn(label: Text('Tanggal')),
                              DataColumn(label: Text('ID Pesanan')),
                              DataColumn(label: Text('Pelanggan')),
                              DataColumn(label: Text('Jumlah Item')),
                              DataColumn(label: Text('Total')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: List<DataRow>.generate(salesData.length, (
                              index,
                            ) {
                              final order = salesData[index];
                              final items =
                                  order['items'] as List<Map<String, dynamic>>;
                              final totalItems = items.fold(
                                0,
                                (sum, item) => sum + (item['jumlah'] as int),
                              );

                              return DataRow(
                                cells: [
                                  DataCell(Text('${index + 1}')),
                                  DataCell(Text(_formatDate(order['tanggal']))),
                                  DataCell(Text(order['id'].substring(0, 6))),
                                  DataCell(Text(order['pelanggan'])),
                                  DataCell(Text('$totalItems')),
                                  DataCell(
                                    Text(currencyFormat.format(order['total'])),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order['status']),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        order['status'],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
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

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green.shade100;
      case 'Diproses':
        return Colors.blue.shade100;
      case 'Dikirim':
        return Colors.orange.shade100;
      case 'Menunggu Konfirmasi':
        return Colors.yellow.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}
