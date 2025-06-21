// File: lib/screens/admin/menu_produk_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuProdukPage extends StatefulWidget {
  const MenuProdukPage({super.key});

  @override
  State<MenuProdukPage> createState() => _MenuProdukPageState();
}

class _MenuProdukPageState extends State<MenuProdukPage> {
  String selectedCategory = 'Semua';
  String searchKeyword = '';
  final kategori = ['Semua', 'Makanan', 'Minuman'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Menu Produk", style: TextStyle(fontSize: 24)),
                ElevatedButton.icon(
                  onPressed: () => _showForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text("Tambahkan Item"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedCategory,
                  items:
                      kategori.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (val) => setState(() => selectedCategory = val!),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari nama produk...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(() => searchKeyword = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('produk')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items =
                      snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['nama']?.toLowerCase() ?? '';
                        final jenis = data['jenis'] ?? '';
                        final matchesCategory =
                            selectedCategory == 'Semua' ||
                            jenis == selectedCategory;
                        final matchesSearch =
                            searchKeyword.isEmpty ||
                            name.contains(searchKeyword.toLowerCase());
                        return matchesCategory && matchesSearch;
                      }).toList();

                  return GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children:
                        items.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['nama'] ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Jenis: ${data['jenis'] ?? '-'}'),
                                  Text('Harga: Rp ${data['harga'] ?? 0}'),
                                  Text('Stok: ${data['stok'] ?? '-'}'),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed:
                                            () => _showForm(
                                              context,
                                              doc.id,
                                              data,
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('produk')
                                              .doc(doc.id)
                                              .delete();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForm(
    BuildContext context, [
    String? docId,
    Map<String, dynamic>? existing,
  ]) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nama = TextEditingController(
      text: existing?['nama'] ?? '',
    );
    final TextEditingController jenis = TextEditingController(
      text: existing?['jenis'] ?? '',
    );
    final TextEditingController harga = TextEditingController(
      text: existing?['harga']?.toString() ?? '',
    );
    final TextEditingController stok = TextEditingController(
      text: existing?['stok'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(docId == null ? "Tambah Produk" : "Edit Produk"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nama,
                    decoration: const InputDecoration(labelText: 'Nama Produk'),
                  ),
                  TextFormField(
                    controller: jenis,
                    decoration: const InputDecoration(labelText: 'Jenis'),
                  ),
                  TextFormField(
                    controller: harga,
                    decoration: const InputDecoration(labelText: 'Harga'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: stok,
                    decoration: const InputDecoration(labelText: 'Status Stok'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    'nama': nama.text,
                    'jenis': jenis.text,
                    'harga': int.tryParse(harga.text) ?? 0,
                    'stok': stok.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  };
                  if (docId == null) {
                    await FirebaseFirestore.instance
                        .collection('produk')
                        .add(data);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('produk')
                        .doc(docId)
                        .update(data);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text("Simpan"),
              ),
            ],
          ),
    );
  }
}
