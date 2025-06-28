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
  final TextEditingController alamatController = TextEditingController();

  bool loading = false;
  File? _buktiPembayaran;
  String? _uploadedImageUrl;

  // New form fields
  String deliveryOption = 'dine_in'; // 'dine_in', 'address_delivery'
  String? selectedTable;
  String paymentMethod = 'transfer'; // 'transfer', 'cash'

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
    // Make sure we're not trying to access context after disposal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
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
    // Enhanced validation
    if (namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama pelanggan harus diisi')),
      );
      return;
    }

    if (deliveryOption == 'dine_in' && selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih nomor meja untuk makan di tempat')),
      );
      return;
    }

    if (deliveryOption == 'dine_in' && selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih nomor meja untuk pengantaran')),
      );
      return;
    }

    if (deliveryOption == 'address_delivery' && alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat pengiriman harus diisi')),
      );
      return;
    }

    if (paymentMethod == 'transfer' && _buktiPembayaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload bukti pembayaran untuk metode transfer'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    // Upload payment proof if transfer method
    if (paymentMethod == 'transfer' && _buktiPembayaran != null) {
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
      // Determine order status based on payment method
      String orderStatus;
      if (paymentMethod == 'cash') {
        orderStatus = 'Belum Dibayar';
      } else {
        orderStatus =
            _uploadedImageUrl != null ? 'Menunggu Konfirmasi' : 'Belum Dibayar';
      }

      // Create delivery info
      String deliveryInfo = '';
      String tableNumber = '';

      switch (deliveryOption) {
        case 'dine_in':
          deliveryInfo = 'Antar ke Meja';
          tableNumber = selectedTable ?? '';
          break;
        case 'address_delivery':
          deliveryInfo = 'Antar ke Alamat: ${alamatController.text}';
          tableNumber = '';
          break;
      }

      // Create order document
      final pesananRef = await FirebaseFirestore.instance
          .collection('pesanan')
          .add({
            'pelanggan': namaController.text,
            'meja': tableNumber,
            'alamat_pengiriman':
                deliveryOption == 'address_delivery'
                    ? alamatController.text
                    : null,
            'tipe_pengiriman': deliveryOption,
            'info_pengiriman': deliveryInfo,
            'catatan': catatanController.text,
            'metode_pembayaran': paymentMethod,
            'status': orderStatus,
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
        await FirebaseFirestore.instance
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
              'metode_pembayaran': paymentMethod,
            });

        await pesananRef.update({'id_pembayaran': pesananRef.id});
      }

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
                    // Customer name
                    TextFormField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Pelanggan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Delivery options
                    const Text(
                      "Opsi Pengiriman",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Antar ke Meja'),
                          value: 'dine_in',
                          groupValue: deliveryOption,
                          onChanged: (value) {
                            setState(() {
                              deliveryOption = value!;
                              selectedTable = null;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Antar ke Alamat'),
                          value: 'address_delivery',
                          groupValue: deliveryOption,
                          onChanged: (value) {
                            setState(() {
                              deliveryOption = value!;
                              selectedTable = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Table selection (for dine_in and dine_in)
                    if (deliveryOption == 'dine_in' ||
                        deliveryOption == 'dine_in')
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Nomor Meja',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        value: selectedTable,
                        items: List.generate(10, (index) {
                          final tableNumber = (index + 1).toString();
                          return DropdownMenuItem(
                            value: tableNumber,
                            child: Text('Meja $tableNumber'),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            selectedTable = value;
                          });
                        },
                      ),

                    // Address input (for address_delivery)
                    if (deliveryOption == 'address_delivery')
                      TextFormField(
                        controller: alamatController,
                        decoration: InputDecoration(
                          labelText: 'Alamat Pengiriman',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        maxLines: 2,
                      ),

                    const SizedBox(height: 16),

                    // Notes
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

                    // Payment method selection
                    const Text(
                      "Metode Pembayaran",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Transfer Bank (Upload Bukti)'),
                          value: 'transfer',
                          groupValue: paymentMethod,
                          onChanged: (value) {
                            setState(() {
                              paymentMethod = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Bayar di Tempat'),
                          value: 'cash',
                          groupValue: paymentMethod,
                          onChanged: (value) {
                            setState(() {
                              paymentMethod = value!;
                              _buktiPembayaran =
                                  null; // Clear any uploaded image
                            });
                          },
                        ),
                      ],
                    ),

                    // Payment proof upload (only for transfer)
                    if (paymentMethod == 'transfer') ...[
                      const SizedBox(height: 16),
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
                          height: 200,
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
                    ],

                    const SizedBox(height: 24),

                    // Order summary
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

                    // Submit button
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
