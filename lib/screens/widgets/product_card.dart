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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double imageHeight = constraints.maxWidth * 0.5;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Container(
            constraints: const BoxConstraints(minHeight: 1000),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      gambarUrl != null && gambarUrl != ''
                          ? Image.network(
                            gambarUrl!,
                            height: imageHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: imageHeight,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 24),
                                  ),
                                ),
                          )
                          : Container(
                            height: imageHeight,
                            color: Colors.grey[300],
                            width: double.infinity,
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 20),
                            ),
                          ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Jenis: $jenis',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        'Harga: Rp $harga',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text('Stok: $stok', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.orange,
                      ),
                      tooltip: 'Edit produk',
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      tooltip: 'Hapus produk',
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
