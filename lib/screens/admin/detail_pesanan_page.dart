// File: lib/screens/admin/detail_pesanan_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailPesananPage extends StatelessWidget {
  final String pesananId;
  const DetailPesananPage({super.key, required this.pesananId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: FutureBuilder<DocumentSnapshot>(
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

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID Pesanan: $pesananId"),
                      Text("Nama Pelanggan: ${data['pelanggan'] ?? '-'}"),
                      Text("No Meja: ${data['meja'] ?? '-'}"),
                      Text("Status: ${data['status'] ?? '-'}"),
                      const SizedBox(height: 16),
                      const Text(
                        "Daftar Item Pesanan:",
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

                          final items = snapshot.data!.docs;

                          return Column(
                            children:
                                items.map((itemDoc) {
                                  final item =
                                      itemDoc.data() as Map<String, dynamic>;
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${item['nama']} x${item['jumlah']}",
                                      ),
                                      Text("Rp ${item['total']}"),
                                    ],
                                  );
                                }).toList(),
                          );
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
                        "Detail Pembayaran",
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
                            return const Text("Loading...");
                          }

                          final bayar =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          if (bayar == null)
                            return const Text("Belum ada pembayaran");

                          final itemList = bayar['items'] as List<dynamic>?;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ID Pembayaran: ${data['id_pembayaran'] ?? '-'}",
                              ),
                              const SizedBox(height: 8),
                              if (itemList != null)
                                Column(
                                  children:
                                      itemList.map((item) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${item['nama']} x${item['jumlah']}",
                                            ),
                                            Text("Rp ${item['total']}"),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              const Divider(),
                              Text(
                                "Total Harga Pesanan: Rp ${bayar['total'] ?? 0}",
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
            ),
          );
        },
      ),
    );
  }
}
