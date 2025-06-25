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
      case 'Selesai':
        return Colors.green[100]!;
      case 'Diproses':
        return Colors.blue[100]!;
      case 'Dikirim':
        return Colors.orange[100]!;
      case 'Menunggu Konfirmasi':
        return Colors.yellow[100]!;
      case 'Belum Dibayar':
      case 'Menunggu Pembayaran':
        return Colors.red[100]!;
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
                        isDense: true,
                        icon: const Icon(Icons.arrow_drop_down, size: 18),
                        onChanged: (val) {
                          if (val != null && val != order['status']) {
                            onStatusChanged(order['id'], val);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'Menunggu Konfirmasi',
                            child: Text('Menunggu Konfirmasi'),
                          ),
                          DropdownMenuItem(
                            value: 'Diproses',
                            child: Text('Diproses'),
                          ),
                          DropdownMenuItem(
                            value: 'Dikirim',
                            child: Text('Dikirim'),
                          ),
                          DropdownMenuItem(
                            value: 'Selesai',
                            child: Text('Selesai'),
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
