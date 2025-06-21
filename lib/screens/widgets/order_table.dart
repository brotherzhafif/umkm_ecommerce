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

  Color _statusColor(String status) {
    switch (status) {
      case 'Selesai Pembayaran':
        return Colors.green[100]!;
      case 'Menunggu Diproses':
        return Colors.yellow[100]!;
      case 'Sedang Diproses':
        return Colors.blue[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(order['status'] ?? ''),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: order['status'],
                        underline: const SizedBox(),
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
                            value: 'Menunggu Diproses',
                            child: Text('Menunggu Diproses'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(order['tanggal'] ?? '')),
                  DataCell(Text('Rp ${order['total'] ?? 0}')),
                  DataCell(Text(order['id_pembayaran'] ?? '')),
                  DataCell(
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
