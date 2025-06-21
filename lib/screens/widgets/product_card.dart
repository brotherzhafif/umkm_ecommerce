import 'package:flutter/material.dart';

class OrderTable extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final void Function(String id) onDetail;
  final void Function(String id, String status) onStatusChanged;

  const OrderTable({
    super.key,
    required this.orders,
    required this.onDetail,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID Pesanan')),
          DataColumn(label: Text('No Meja')),
          DataColumn(label: Text('Pelanggan')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Tanggal')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('Pembayaran')),
          DataColumn(label: Text('Aksi')),
        ],
        rows:
            orders.map((order) {
              return DataRow(
                cells: [
                  DataCell(Text(order['id'] ?? '')),
                  DataCell(Text(order['meja'] ?? '')),
                  DataCell(Text(order['pelanggan'] ?? '')),
                  DataCell(
                    DropdownButton<String>(
                      value: order['status'],
                      onChanged:
                          (val) =>
                              val != null
                                  ? onStatusChanged(order['id'], val)
                                  : null,
                      items: const [
                        DropdownMenuItem(
                          value: 'Selesai Pembayaran',
                          child: Text('Selesai Pembayaran'),
                        ),
                        DropdownMenuItem(
                          value: 'Sedang Diproses',
                          child: Text('Sedang Diproses'),
                        ),
                        DropdownMenuItem(
                          value: 'Menunggu Pembayaran',
                          child: Text('Menunggu Pembayaran'),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(order['tanggal'] ?? '')),
                  DataCell(Text('Rp ${order['total'] ?? 0}')),
                  DataCell(Text(order['id_pembayaran'] ?? '')),
                  DataCell(
                    ElevatedButton(
                      onPressed: () => onDetail(order['id']),
                      child: const Text('Detail'),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}
