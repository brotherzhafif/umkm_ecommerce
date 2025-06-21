import 'package:flutter/material.dart';

class OrderTableItem extends StatelessWidget {
  final String nama;
  final int jumlah;
  final int total;

  const OrderTableItem({
    super.key,
    required this.nama,
    required this.jumlah,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('$nama x$jumlah'), Text('Rp $total')],
      ),
    );
  }
}
