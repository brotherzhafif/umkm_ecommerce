import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerOrderHistoryPage extends StatefulWidget {
  const CustomerOrderHistoryPage({super.key});

  @override
  State<CustomerOrderHistoryPage> createState() =>
      _CustomerOrderHistoryPageState();
}

class _CustomerOrderHistoryPageState extends State<CustomerOrderHistoryPage> {
  final user = FirebaseAuth.instance.currentUser;

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
      default:
        return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset('assets/icon.png'),
            ),
            const SizedBox(width: 16),
            const Text(
              "Pesanan Saya",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlue),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset('assets/icon.png'),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'UMKM',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.lightBlue),
              title: const Text('Menu Produk'),
              onTap: () => Navigator.pushReplacementNamed(context, '/customer'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.lightBlue),
              title: const Text('Pesanan Saya'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.of(context).pop();
                await showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Yakin ingin logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await FirebaseAuth.instance.signOut();
                              if (!mounted) return;
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => false,
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Riwayat Pesanan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('pesanan')
                      .where(
                        'pelanggan',
                        isEqualTo: user?.email ?? user?.displayName,
                      )
                      .orderBy('tanggal', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Belum ada pesanan",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                final pesananDocs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pesananDocs.length,
                  itemBuilder: (context, index) {
                    final pesanan =
                        pesananDocs[index].data() as Map<String, dynamic>;
                    final pesananId = pesananDocs[index].id;
                    final tanggal =
                        (pesanan['tanggal'] as Timestamp?)?.toDate() ??
                        DateTime.now();
                    final formattedDate =
                        "${tanggal.day}/${tanggal.month}/${tanggal.year} ${tanggal.hour}:${tanggal.minute}";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Pesanan #${pesananId.substring(0, 6)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      pesanan['status'] ?? '',
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    pesanan['status'] ?? 'Menunggu Konfirmasi',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Tanggal:"),
                                Text(formattedDate),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("No Meja:"),
                                Text(pesanan['meja'] ?? '-'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total:"),
                                Text("Rp ${pesanan['total'] ?? 0}"),
                              ],
                            ),
                            if (pesanan['catatan'] != null &&
                                pesanan['catatan'] != '')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Catatan:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(pesanan['catatan']),
                                ],
                              ),
                            const SizedBox(height: 8),
                            StreamBuilder<QuerySnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection('pesanan')
                                      .doc(pesananId)
                                      .collection('items')
                                      .snapshots(),
                              builder: (context, itemsSnapshot) {
                                if (!itemsSnapshot.hasData) {
                                  return const SizedBox();
                                }

                                final items = itemsSnapshot.data!.docs;
                                return ExpansionTile(
                                  title: const Text(
                                    "Detail Pesanan",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  children:
                                      items.map((item) {
                                        final itemData =
                                            item.data() as Map<String, dynamic>;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${itemData['nama']} x${itemData['jumlah']}",
                                              ),
                                              Text("Rp ${itemData['total']}"),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            if (pesanan['bukti_pembayaran_url'] != null)
                              ExpansionTile(
                                title: const Text(
                                  "Bukti Pembayaran",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        pesanan['bukti_pembayaran_url'],
                                        fit: BoxFit.cover,
                                        height: 200,
                                        width: double.infinity,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            height: 200,
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            height: 200,
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (pesanan['status'] == 'Menunggu Konfirmasi' &&
                                pesanan['bukti_pembayaran_url'] == null)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  "* Upload bukti pembayaran untuk proses selanjutnya",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
