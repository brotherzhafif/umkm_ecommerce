// File: lib/screens/admin/detail_pesanan_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/order_table_item.dart';

class DetailPesananPage extends StatelessWidget {
  final String pesananId;
  const DetailPesananPage({super.key, required this.pesananId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icon.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Detail Pesanan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('pesanan')
                        .doc(pesananId)
                        .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID Pesanan: $pesananId',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Nama Pelanggan: ${data['pelanggan'] ?? '-'}'),
                            Text('No Meja: ${data['meja'] ?? '-'}'),
                            Text('Status: ${data['status'] ?? '-'}'),
                            const SizedBox(height: 16),
                            const Text(
                              'Daftar Item Pesanan:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<QuerySnapshot>(
                              future:
                                  FirebaseFirestore.instance
                                      .collection('pesanan')
                                      .doc(pesananId)
                                      .collection('items')
                                      .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                final items =
                                    snapshot.data!.docs.map((itemDoc) {
                                      final item =
                                          itemDoc.data()
                                              as Map<String, dynamic>;
                                      return OrderTableItem(
                                        nama: item['nama'],
                                        jumlah: item['jumlah'],
                                        total: item['total'],
                                      );
                                    }).toList();
                                return Column(children: items);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Pembayaran',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<DocumentSnapshot>(
                              future:
                                  FirebaseFirestore.instance
                                      .collection('pembayaran')
                                      .doc(data['id_pembayaran'])
                                      .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Text('Loading...');
                                }
                                final bayar =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>?;
                                if (bayar == null)
                                  return const Text('Belum ada pembayaran');
                                final itemList =
                                    bayar['items'] as List<dynamic>?;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID Pembayaran: ${data['id_pembayaran'] ?? '-'}',
                                    ),
                                    const SizedBox(height: 8),
                                    if (itemList != null)
                                      Column(
                                        children:
                                            itemList.map((item) {
                                              return OrderTableItem(
                                                nama: item['nama'],
                                                jumlah: item['jumlah'],
                                                total: item['total'],
                                              );
                                            }).toList(),
                                      ),
                                    const Divider(),
                                    Text(
                                      'Total Harga Pesanan: Rp ${bayar['total'] ?? 0}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
