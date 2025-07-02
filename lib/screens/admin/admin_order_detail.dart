import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:umkm_ecommerce/models/order_model.dart';

class AdminOrderDetail extends StatefulWidget {
  final String orderId;

  const AdminOrderDetail({super.key, required this.orderId});

  @override
  State<AdminOrderDetail> createState() => _AdminOrderDetailState();
}

class _AdminOrderDetailState extends State<AdminOrderDetail> {
  bool isLoading = true;
  OrderModel? order;
  List<OrderItemModel> items = [];

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    try {
      // Get order data
      final orderDoc =
          await FirebaseFirestore.instance
              .collection('pesanan')
              .doc(widget.orderId)
              .get();

      if (!orderDoc.exists) {
        setState(() => isLoading = false);
        return;
      }

      // Create order model
      final orderData = orderDoc.data() as Map<String, dynamic>;
      order = OrderModel.fromMap(widget.orderId, orderData);

      // Get order items
      final itemsSnapshot =
          await FirebaseFirestore.instance
              .collection('pesanan')
              .doc(widget.orderId)
              .collection('items')
              .get();

      items =
          itemsSnapshot.docs
              .map((doc) => OrderItemModel.fromMap(doc.data()))
              .toList();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading order: $e')));
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    try {
      // Use a loading indicator
      setState(() => isLoading = true);

      // Update the order status
      await FirebaseFirestore.instance
          .collection('pesanan')
          .doc(widget.orderId)
          .update({
            'status': newStatus,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      // Update the local order object
      setState(() {
        if (order != null) {
          order = OrderModel(
            id: order!.id,
            pelanggan: order!.pelanggan,
            meja: order!.meja,
            catatan: order!.catatan,
            status: newStatus,
            total: order!.total,
            tanggal: order!.tanggal,
            buktiPembayaranUrl: order!.buktiPembayaranUrl,
            idPembayaran: order!.idPembayaran,
            pembayaranDivalidasi: order!.pembayaranDivalidasi,
            waktuValidasi: order!.waktuValidasi,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status pesanan berhasil diupdate ke $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan #${widget.orderId.substring(0, 6)}'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : order == null
              ? const Center(child: Text('Pesanan tidak ditemukan'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Informasi Pesanan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(order!.status),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    order!.status,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            _infoRow('ID Pesanan', order!.id),
                            _infoRow('Pelanggan', order!.pelanggan),

                            // Display phone number if available
                            if (order!.phone != null &&
                                order!.phone!.isNotEmpty)
                              _infoRow('No. HP Pelanggan', order!.phone!),

                            // Display either table number or delivery address
                            order!.tipe_pengiriman == 'address_delivery'
                                ? _infoRow(
                                  'Alamat Pengiriman',
                                  order!.alamat_pengiriman ?? '-',
                                )
                                : _infoRow('No. Meja', order!.meja),

                            _infoRow(
                              'Tanggal',
                              '${order!.tanggal.day}/${order!.tanggal.month}/${order!.tanggal.year} ${order!.tanggal.hour}:${order!.tanggal.minute}',
                            ),
                            _infoRow('Total', 'Rp ${order!.total}'),
                            if (order!.catatan != null &&
                                order!.catatan!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Catatan:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(order!.catatan!),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Item',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Divider(),
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${item.nama} x${item.jumlah}'),
                                    Text('Rp ${item.total}'),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Rp ${order!.total}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (order!.buktiPembayaranUrl != null)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bukti Pembayaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  order!.buktiPembayaranUrl!,
                                  height: 300,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Update Status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              value: order!.status,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Menunggu Konfirmasi',
                                  child: Text('Menunggu Konfirmasi'),
                                ),
                                DropdownMenuItem(
                                  value: 'Selesai Pembayaran',
                                  child: Text('Selesai Pembayaran'),
                                ),
                                DropdownMenuItem(
                                  value: 'Menunggu Diproses',
                                  child: Text('Menunggu Diproses'),
                                ),
                                DropdownMenuItem(
                                  value: 'Sedang Diproses',
                                  child: Text('Sedang Diproses'),
                                ),
                                DropdownMenuItem(
                                  value: 'Selesai',
                                  child: Text('Selesai'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null && value != order!.status) {
                                  _updateOrderStatus(value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Kembali'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
