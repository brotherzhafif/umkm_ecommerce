import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    // Hitung data untuk metrik
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
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('pesanan')
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          // Analisis makanan favorit
                          final Map<String, int> makananCount = {};

                          for (var pesanan in snapshot.data!.docs) {
                            FirebaseFirestore.instance
                                .collection('pesanan')
                                .doc(pesanan.id)
                                .collection('items')
                                .get()
                                .then((items) {
                                  for (var item in items.docs) {
                                    final data = item.data();
                                    final nama = data['nama'] as String;
                                    final jumlah = data['jumlah'] as int;

                                    // Cek apakah makanan
                                    if (nama.contains('Nasi') ||
                                        nama.contains('Ayam') ||
                                        nama.contains('Mie') ||
                                        nama.contains('Bakso')) {
                                      makananCount[nama] =
                                          (makananCount[nama] ?? 0) + jumlah;
                                    }
                                  }
                                });
                          }

                          List<MapEntry<String, int>> sortedMakanan =
                              makananCount.entries.toList()
                                ..sort((a, b) => b.value.compareTo(a.value));

                          return Column(
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
                                child: Center(
                                  child:
                                      sortedMakanan.isEmpty
                                          ? const Text(
                                            'Belum Ada Makanan Terjual',
                                          )
                                          : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                sortedMakanan.isNotEmpty
                                                    ? sortedMakanan[0].key
                                                    : '-',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                sortedMakanan.isNotEmpty
                                                    ? '${sortedMakanan[0].value} porsi'
                                                    : '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _legendDot(Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(
                                    sortedMakanan.isNotEmpty
                                        ? sortedMakanan[0].key
                                        : 'Nasi Goreng',
                                  ),
                                  const SizedBox(width: 16),
                                  _legendDot(Colors.purple),
                                  const SizedBox(width: 8),
                                  Text(
                                    sortedMakanan.length > 1
                                        ? sortedMakanan[1].key
                                        : 'Ayam Bakar',
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
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
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('pesanan')
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          // Analisis minuman favorit
                          final Map<String, int> minumanCount = {};

                          for (var pesanan in snapshot.data!.docs) {
                            FirebaseFirestore.instance
                                .collection('pesanan')
                                .doc(pesanan.id)
                                .collection('items')
                                .get()
                                .then((items) {
                                  for (var item in items.docs) {
                                    final data = item.data();
                                    final nama = data['nama'] as String;
                                    final jumlah = data['jumlah'] as int;

                                    // Cek apakah minuman
                                    if (nama.contains('Es') ||
                                        nama.contains('Jus') ||
                                        nama.contains('Teh') ||
                                        nama.contains('Kopi')) {
                                      minumanCount[nama] =
                                          (minumanCount[nama] ?? 0) + jumlah;
                                    }
                                  }
                                });
                          }

                          List<MapEntry<String, int>> sortedMinuman =
                              minumanCount.entries.toList()
                                ..sort((a, b) => b.value.compareTo(a.value));

                          return Column(
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
                                child: Center(
                                  child:
                                      sortedMinuman.isEmpty
                                          ? const Text(
                                            'Belum Ada Minuman Terjual',
                                          )
                                          : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                sortedMinuman.isNotEmpty
                                                    ? sortedMinuman[0].key
                                                    : '-',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                sortedMinuman.isNotEmpty
                                                    ? '${sortedMinuman[0].value} porsi'
                                                    : '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _legendDot(Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    sortedMinuman.isNotEmpty
                                        ? sortedMinuman[0].key
                                        : 'Es Teh',
                                  ),
                                  const SizedBox(width: 16),
                                  _legendDot(Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    sortedMinuman.length > 1
                                        ? sortedMinuman[1].key
                                        : 'Jus Alpukat',
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
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
          padding: const EdgeInsets.all(24),
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
                child: Icon(icon, color: color, size: 24),
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
