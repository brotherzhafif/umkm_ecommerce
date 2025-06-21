// File: lib/screens/admin/data_pesanan_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataPesananPage extends StatelessWidget {
  const DataPesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Data Pesanan", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('pesanan')
                        .orderBy('tanggal', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID Pesanan')),
                        DataColumn(label: Text('No Meja')),
                        DataColumn(label: Text('Pelanggan')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Total Harga')),
                        DataColumn(label: Text('ID Pembayaran')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows:
                          docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(Text(doc.id)),
                                DataCell(Text(data['meja'] ?? '-')),
                                DataCell(Text(data['pelanggan'] ?? '-')),
                                DataCell(
                                  _buildStatusDropdown(doc.id, data['status']),
                                ),
                                DataCell(
                                  Text(
                                    data['tanggal']?.toDate().toString().split(
                                          ' ',
                                        )[0] ??
                                        '-',
                                  ),
                                ),
                                DataCell(Text('Rp ${data['total'] ?? 0}')),
                                DataCell(Text(data['id_pembayaran'] ?? '-')),
                                DataCell(
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/detail-pesanan',
                                        arguments: doc.id,
                                      );
                                    },
                                    child: const Text("Detail"),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(String docId, String currentStatus) {
    final statuses = [
      'Selesai Pembayaran',
      'Sedang Diproses',
      'Menunggu Pembayaran',
    ];

    return DropdownButton<String>(
      value: currentStatus,
      onChanged: (val) {
        if (val != null) {
          FirebaseFirestore.instance.collection('pesanan').doc(docId).update({
            'status': val,
          });
        }
      },
      items:
          statuses.map((s) {
            return DropdownMenuItem(value: s, child: Text(s));
          }).toList(),
    );
  }
}
