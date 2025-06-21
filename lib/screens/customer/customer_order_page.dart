// File: lib/screens/customer/customer_order_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerOrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  const CustomerOrderPage({super.key, required this.cart});

  @override
  State<CustomerOrderPage> createState() => _CustomerOrderPageState();
}

class _CustomerOrderPageState extends State<CustomerOrderPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController mejaController = TextEditingController();
  bool loading = false;

  int getTotal() => widget.cart.fold(
    0,
    (sum, item) => sum + ((item['jumlah'] * item['harga']) as int),
  );

  Future<void> submitOrder() async {
    if (namaController.text.isEmpty || mejaController.text.isEmpty) return;
    setState(() => loading = true);

    final total = getTotal();
    final now = DateTime.now();

    final pesananRef = await FirebaseFirestore.instance
        .collection('pesanan')
        .add({
          'pelanggan': namaController.text,
          'meja': mejaController.text,
          'status': 'Menunggu Pembayaran',
          'total': total,
          'tanggal': now,
        });

    for (var item in widget.cart) {
      await pesananRef.collection('items').add({
        'nama': item['nama'],
        'jumlah': item['jumlah'],
        'total': item['jumlah'] * item['harga'],
      });
    }

    await FirebaseFirestore.instance
        .collection('pembayaran')
        .doc(pesananRef.id)
        .set({
          'id_pesanan': pesananRef.id,
          'items': widget.cart,
          'total': total,
          'waktu_pembayaran': now,
        });

    await pesananRef.update({'id_pembayaran': pesananRef.id});

    setState(() => loading = false);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Konfirmasi Pesanan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pelanggan',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: mejaController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Meja',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Ringkasan Pesanan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: [
                          ...widget.cart.map(
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitOrder,
                        child: const Text("Bayar Sekarang"),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
