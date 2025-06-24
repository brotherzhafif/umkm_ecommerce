// File: lib/screens/customer/customer_order_page.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CustomerOrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  const CustomerOrderPage({super.key, required this.cart});

  @override
  State<CustomerOrderPage> createState() => _CustomerOrderPageState();
}

class _CustomerOrderPageState extends State<CustomerOrderPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController mejaController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  bool loading = false;
  File? _buktiPembayaran;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait for customer order page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Restore all orientations when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  int getTotal() => widget.cart.fold(
    0,
    (sum, item) => sum + ((item['jumlah'] * item['harga']) as int),
  );

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Optimize image quality
    );

    if (pickedFile != null) {
      setState(() {
        _buktiPembayaran = File(pickedFile.path);
      });

      // Show confirmation snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar berhasil dipilih')),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_buktiPembayaran == null) return null;

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${namaController.text.replaceAll(' ', '_')}';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('bukti_pembayaran')
          .child('$fileName.jpg');

      final uploadTask = storageRef.putFile(_buktiPembayaran!);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // You could update a progress indicator here if desired
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  Future<void> submitOrder() async {
    // Validasi form
    if (namaController.text.isEmpty || mejaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan nomor meja harus diisi')),
      );
      return;
    }

    setState(() => loading = true);

    // Upload bukti pembayaran jika ada
    if (_buktiPembayaran != null) {
      _uploadedImageUrl = await _uploadImage();
      if (_uploadedImageUrl == null) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengupload bukti pembayaran')),
        );
        return;
      }
    }

    final total = getTotal();
    final now = DateTime.now();
    String orderId = '';

    try {
      // Create order document
      final pesananRef = await FirebaseFirestore.instance
          .collection('pesanan')
          .add({
            'pelanggan': namaController.text,
            'meja': mejaController.text,
            'catatan': catatanController.text,
            'status':
                _uploadedImageUrl != null
                    ? 'Menunggu Konfirmasi'
                    : 'Belum Dibayar',
            'total': total,
            'tanggal': now,
            'bukti_pembayaran_url': _uploadedImageUrl,
            'createdAt': FieldValue.serverTimestamp(),
          });

      orderId = pesananRef.id;

      // Add order items to subcollection
      for (var item in widget.cart) {
        await pesananRef.collection('items').add({
          'nama': item['nama'],
          'jumlah': item['jumlah'],
          'total': item['jumlah'] * item['harga'],
        });
      }

      // Create payment record if proof was uploaded
      if (_uploadedImageUrl != null) {
        final paymentRef = await FirebaseFirestore.instance
            .collection('pembayaran')
            .doc(pesananRef.id)
            .set({
              'id_pesanan': pesananRef.id,
              'items':
                  widget.cart
                      .map(
                        (item) => {
                          'nama': item['nama'],
                          'jumlah': item['jumlah'],
                          'harga': item['harga'],
                          'total': item['jumlah'] * item['harga'],
                        },
                      )
                      .toList(),
              'total': total,
              'waktu_pembayaran': now,
              'bukti_pembayaran_url': _uploadedImageUrl,
              'status': 'Menunggu Konfirmasi',
            });

        await pesananRef.update({'id_pembayaran': pesananRef.id});
      }

      // Success handling
      setState(() => loading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat')));

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
              "Konfirmasi Pesanan",
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.lightBlue),
              title: const Text('Pesanan Saya'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Pelanggan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama pelanggan harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: mejaController,
                      decoration: InputDecoration(
                        labelText: 'Nomor Meja',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor meja harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: catatanController,
                      decoration: InputDecoration(
                        labelText: 'Catatan (opsional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Upload Bukti Pembayaran",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200, // Increased height for better visibility
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey),
                        ),
                        child:
                            _buktiPembayaran != null
                                ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        _buktiPembayaran!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _buktiPembayaran = null;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.upload_file,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      "Tap untuk upload bukti pembayaran",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Format: JPG, PNG",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _buktiPembayaran == null
                          ? "* Pesanan tanpa bukti pembayaran akan berstatus 'Belum Dibayar'"
                          : "* Bukti pembayaran akan divalidasi oleh admin",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Ringkasan Pesanan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ...widget.cart.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${item['nama']} x${item['jumlah']}",
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      "Rp ${item['jumlah'] * item['harga']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        onPressed: loading ? null : submitOrder,
                        child:
                            loading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Pesan Sekarang",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
