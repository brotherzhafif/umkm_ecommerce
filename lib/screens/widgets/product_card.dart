import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String nama;
  final String jenis;
  final int harga;
  final String stok;
  final String? gambarUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.nama,
    required this.jenis,
    required this.harga,
    required this.stok,
    required this.gambarUrl,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child:
                gambarUrl != null && gambarUrl != ''
                    ? Image.network(
                      gambarUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            height: 100,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image),
                            ),
                          ),
                    )
                    : Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Jenis: $jenis'),
                Text('Harga: Rp $harga'),
                Text('Stok: $stok'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'assets/icon.png',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: Image.asset(
                        'assets/icon.png',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
