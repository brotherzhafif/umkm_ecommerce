// File: lib/screens/customer/customer_home.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/drawer_customer.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final List<Map<String, dynamic>> cart = [];

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait for customer pages
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

  void addToCart(Map<String, dynamic> item) {
    final index = cart.indexWhere((e) => e['id'] == item['id']);
    if (index >= 0) {
      setState(() {
        cart[index]['jumlah']++;
      });
    } else {
      setState(() {
        cart.add({...item, 'jumlah': 1});
      });
    }
  }

  void removeFromCart(String itemId) {
    final index = cart.indexWhere((e) => e['id'] == itemId);
    if (index >= 0) {
      setState(() {
        if (cart[index]['jumlah'] > 1) {
          cart[index]['jumlah']--;
        } else {
          cart.removeAt(index);
        }
      });
    }
  }

  int getItemQuantity(String itemId) {
    final index = cart.indexWhere((e) => e['id'] == itemId);
    return index >= 0 ? cart[index]['jumlah'] : 0;
  }

  int getTotal() => cart.fold(
    0,
    (sum, item) => sum + ((item['jumlah'] * item['harga']) as int),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Image.asset('assets/icon.png', fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            const Text(
              "Pelanggan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
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
      drawer: DrawerCustomer(
        selectedIndex: 0, // or the appropriate index for this page
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio:
                        0.75, // Control the height-to-width ratio of grid items
                    children:
                        docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final itemId = doc.id;
                          final quantity = getItemQuantity(itemId);

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image section
                                SizedBox(
                                  width: double.infinity,
                                  height: 80,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child:
                                        data['gambar_url'] != null &&
                                                data['gambar_url'] != ''
                                            ? Image.network(
                                              data['gambar_url'],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                      ),
                                                    ),
                                                  ),
                                            )
                                            : Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                                // Product info and controls
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['nama'] ?? '-',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Rp ${data['harga'] ?? 0}',
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (quantity > 0)
                                              Text(
                                                'x$quantity',
                                                style: TextStyle(
                                                  color: Colors.lightBlue,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                        // Quantity controls
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Minus button
                                                GestureDetector(
                                                  onTap:
                                                      quantity > 0
                                                          ? () =>
                                                              removeFromCart(
                                                                itemId,
                                                              )
                                                          : null,
                                                  child: Container(
                                                    width: 28,
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          quantity > 0
                                                              ? Colors.red[300]
                                                              : Colors
                                                                  .grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 16,
                                                      color:
                                                          quantity > 0
                                                              ? Colors.white
                                                              : Colors
                                                                  .grey[600],
                                                    ),
                                                  ),
                                                ),
                                                // Quantity input
                                                Container(
                                                  width: 40,
                                                  height: 28,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '$quantity',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                // Plus button
                                                GestureDetector(
                                                  onTap:
                                                      () => addToCart({
                                                        'id': itemId,
                                                        'nama': data['nama'],
                                                        'harga': data['harga'],
                                                      }),
                                                  child: Container(
                                                    width: 28,
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      color: Colors.lightBlue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
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
                              ],
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detail Pesanan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...cart.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${item['nama']} x${item['jumlah']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              "Rp ${item['jumlah'] * item['harga']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (cart.isNotEmpty) const Divider(),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              cart.isEmpty
                                  ? Colors.grey[300]
                                  : Colors.lightBlue,
                          foregroundColor:
                              cart.isEmpty ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
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
                        child: const Text(
                          "Pesan Sekarang",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
}
