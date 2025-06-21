import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String nama;
  final String jenis;
  final int harga;
  final String stok;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.nama,
    required this.jenis,
    required this.harga,
    required this.stok,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Jenis: $jenis'),
            Text('Harga: Rp $harga'),
            Text('Stok: $stok'),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
