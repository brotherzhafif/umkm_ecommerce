// File: lib/screens/admin/data_pesanan_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataPesananPage extends StatelessWidget {
  const DataPesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Data Pesanan",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    DropdownButton<int>(
                      value: 10,
                      items: const [
                        DropdownMenuItem(value: 10, child: Text('10')),
                        DropdownMenuItem(value: 25, child: Text('25')),
                        DropdownMenuItem(value: 50, child: Text('50')),
                      ],
                      onChanged: (v) {},
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: const InputDecoration(hintText: 'Cari...'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('ID Pesanan')),
                              DataColumn(label: Text('Lokasi/Meja')),
                              DataColumn(label: Text('Pelanggan')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Tanggal')),
                              DataColumn(label: Text('Total Harga')),
                              DataColumn(label: Text('ID Pembayaran')),
                              DataColumn(label: Text('Aksi')),
                            ],
                            rows:
                                docs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  Color statusColor;
                                  switch (data['status']) {
                                    case 'Selesai':
                                      statusColor = Colors.green[200]!;
                                      break;
                                    case 'Diproses':
                                      statusColor = Colors.blue[200]!;
                                      break;
                                    case 'Dikirim':
                                      statusColor = Colors.orange[200]!;
                                      break;
                                    case 'Pembayaran Selesai':
                                      statusColor = Colors.teal[200]!;
                                      break;
                                    case 'Menunggu Konfirmasi':
                                      statusColor = Colors.yellow[200]!;
                                      break;
                                    case 'Belum Dibayar':
                                    case 'Menunggu Pembayaran':
                                      statusColor = Colors.red[200]!;
                                      break;
                                    default:
                                      statusColor = Colors.grey[200]!;
                                  }
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(doc.id)),
                                      // Show either table number or delivery address
                                      DataCell(
                                        Text(
                                          data['tipe_pengiriman'] ==
                                                  'address_delivery'
                                              ? (data['alamat_pengiriman'] !=
                                                          null &&
                                                      data['alamat_pengiriman']
                                                          .toString()
                                                          .isNotEmpty
                                                  ? '📍 ' +
                                                      data['alamat_pengiriman']
                                                          .toString()
                                                          .substring(
                                                            0,
                                                            data['alamat_pengiriman']
                                                                        .toString()
                                                                        .length >
                                                                    15
                                                                ? 15
                                                                : data['alamat_pengiriman']
                                                                    .toString()
                                                                    .length,
                                                          ) +
                                                      '...'
                                                  : '-')
                                              : '🪑 Meja ${data['meja'] ?? '-'}',
                                        ),
                                      ),
                                      DataCell(Text(data['pelanggan'] ?? '-')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(data['status'] ?? '-'),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          data['tanggal']
                                                  ?.toDate()
                                                  .toString()
                                                  .split(' ')[0] ??
                                              '-',
                                        ),
                                      ),
                                      DataCell(
                                        Text('Rp ${data['total'] ?? 0}'),
                                      ),
                                      DataCell(
                                        Text(data['id_pembayaran'] ?? '-'),
                                      ),
                                      DataCell(
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightBlue,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
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
                        ),
                      ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green[100]!;
      case 'Diproses':
        return Colors.blue[100]!;
      case 'Dikirim':
        return Colors.orange[100]!;
      case 'Pembayaran Selesai':
        return Colors.teal[100]!;
      case 'Menunggu Konfirmasi':
        return Colors.yellow[100]!;
      case 'Belum Dibayar':
      case 'Menunggu Pembayaran':
        return Colors.red[100]!;
      default:
        return Colors.grey[200]!;
    }
  }
}
