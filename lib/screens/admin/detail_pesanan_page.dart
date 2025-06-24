// File: lib/screens/admin/detail_pesanan_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/order_table_item.dart';

class DetailPesananPage extends StatefulWidget {
  final String pesananId;
  const DetailPesananPage({super.key, required this.pesananId});

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  String? _selectedStatus;
  bool _isUpdating = false;

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) return;

    setState(() => _isUpdating = true);

    try {
      await FirebaseFirestore.instance
          .collection('pesanan')
          .doc(widget.pesananId)
          .update({'status': _selectedStatus});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status pesanan diperbarui ke $_selectedStatus'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _validatePayment() async {
    setState(() => _isUpdating = true);

    try {
      await FirebaseFirestore.instance
          .collection('pesanan')
          .doc(widget.pesananId)
          .update({
            'status': 'Diproses',
            'pembayaran_divalidasi': true,
            'waktu_validasi': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran telah divalidasi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icon.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Detail Pesanan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pesanan')
                .doc(widget.pesananId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          _selectedStatus = data['status'];

          final tanggal = (data['tanggal'] as Timestamp?)?.toDate();
          final formattedDate =
              tanggal != null
                  ? "${tanggal.day}/${tanggal.month}/${tanggal.year} ${tanggal.hour}:${tanggal.minute}"
                  : "-";

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN - Order Details
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Pesanan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'ID Pesanan: ${widget.pesananId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Nama Pelanggan: ${data['pelanggan'] ?? '-'}'),
                            Text('No Meja: ${data['meja'] ?? '-'}'),
                            Text('Tanggal: $formattedDate'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('Status: '),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      data['status'] ?? '',
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    data['status'] ?? 'Menunggu Konfirmasi',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedStatus,
                                    decoration: const InputDecoration(
                                      labelText: 'Ubah Status',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Menunggu Pembayaran',
                                        child: Text('Menunggu Pembayaran'),
                                      ),
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
                                    onChanged: (val) {
                                      setState(() => _selectedStatus = val);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _isUpdating ? null : _updateStatus,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child:
                                      _isUpdating
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text('Update'),
                                ),
                              ],
                            ),

                            if (data['catatan'] != null &&
                                data['catatan'] != '')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Catatan Pelanggan:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Text(data['catatan']),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 24),
                            const Text(
                              'Daftar Item Pesanan:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StreamBuilder<QuerySnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection('pesanan')
                                      .doc(widget.pesananId)
                                      .collection('items')
                                      .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                final items = snapshot.data!.docs;
                                return Card(
                                  elevation: 0,
                                  color: Colors.grey[100],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        ...items.map((itemDoc) {
                                          final item =
                                              itemDoc.data()
                                                  as Map<String, dynamic>;
                                          return OrderTableItem(
                                            nama: item['nama'],
                                            jumlah: item['jumlah'],
                                            total: item['total'] ?? 0,
                                          );
                                        }),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total Harga Pesanan:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Rp ${data['total'] ?? 0}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // RIGHT COLUMN - Payment Details
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Pembayaran',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Card(
                              elevation: 0,
                              color: Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('ID Pembayaran:'),
                                        Text(data['id_pembayaran'] ?? '-'),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Status Validasi:'),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                data['pembayaran_divalidasi'] ==
                                                        true
                                                    ? Colors.green[100]
                                                    : Colors.orange[100],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            data['pembayaran_divalidasi'] ==
                                                    true
                                                ? 'Sudah Divalidasi'
                                                : 'Belum Divalidasi',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (data['bukti_pembayaran_url'] != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          const Text(
                                            'Bukti Pembayaran:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              data['bukti_pembayaran_url'],
                                              height: 300,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    height: 300,
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 40,
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          if (data['pembayaran_divalidasi'] !=
                                              true)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 24,
                                              ),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                    Icons.check_circle,
                                                  ),
                                                  label: const Text(
                                                    'Validasi Pembayaran',
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                  ),
                                                  onPressed:
                                                      _isUpdating
                                                          ? null
                                                          : _validatePayment,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    if (data['bukti_pembayaran_url'] == null)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 16),
                                        child: Text(
                                          'Pelanggan belum mengupload bukti pembayaran',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
      case 'Menunggu Pembayaran':
        return Colors.grey[300]!;
      default:
        return Colors.grey[200]!;
    }
  }
}
