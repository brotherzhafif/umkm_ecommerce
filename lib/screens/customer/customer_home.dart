// File: lib/screens/customer/customer_home.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final List<Map<String, dynamic>> cart = [];

  void addToCart(Map<String, dynamic> item) {
    final index = cart.indexWhere((e) => e['id'] == item['id']);
    if (index >= 0) {
      cart[index]['jumlah']++;
    } else {
      cart.add({...item, 'jumlah': 1});
    }
    setState(() {});
  }

  int getTotal() => cart.fold(
    0,
    (sum, item) => sum + ((item['jumlah'] * item['harga']) as int),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelanggan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Daftar Menu", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('produk')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children:
                        docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child:
                                      data['gambar_url'] != null &&
                                              data['gambar_url'] != ''
                                          ? Image.network(
                                            data['gambar_url'],
                                            height: 80,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      height: 80,
                                                      width: double.infinity,
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                        ),
                                                      ),
                                                    ),
                                          )
                                          : Container(
                                            height: 80,
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                              ),
                                            ),
                                          ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['nama'] ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text("Rp ${data['harga'] ?? 0}"),
                                      const SizedBox(height: 4),
                                      ElevatedButton(
                                        onPressed:
                                            () => addToCart({
                                              'id': doc.id,
                                              'nama': data['nama'],
                                              'harga': data['harga'],
                                            }),
                                        child: const Text("Order"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text("Detail Pesanan", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ...cart.map(
                    (item) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${item['nama']} x${item['jumlah']}"),
                        Text("Rp ${item['jumlah'] * item['harga']}"),
                      ],
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Harga Pesanan:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rp ${getTotal()}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed:
                        cart.isEmpty
                            ? null
                            : () {
                              Navigator.pushNamed(
                                context,
                                '/order',
                                arguments: cart,
                              );
                            },
                    child: const Text("Bayar Sekarang"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
