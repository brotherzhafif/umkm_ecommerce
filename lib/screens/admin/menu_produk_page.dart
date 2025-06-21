// File: lib/screens/admin/menu_produk_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../widgets/product_card.dart'; // Ganti dengan path yang sesuai

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
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Menu Produk",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text("Tambah Item"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: selectedCategory,
                      items:
                          kategori.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged:
                          (val) => setState(() => selectedCategory = val!),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 200,
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
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
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
                      if (snapshot.hasError) {
                        return const Center(child: Text('Terjadi kesalahan'));
                      }
                      final docs = snapshot.data?.docs ?? [];
                      final filteredDocs =
                          docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name =
                                (data['nama'] ?? '').toString().toLowerCase();
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
                            filteredDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return ProductCard(
                                nama: data['nama'] ?? '-',
                                jenis: data['jenis'] ?? '-',
                                harga: data['harga'] ?? 0,
                                stok: data['stok'] ?? '-',
                                gambarUrl: data['gambar_url'],
                                onEdit: () => _showForm(context, doc.id, data),
                                onDelete: () async {
                                  await FirebaseFirestore.instance
                                      .collection('produk')
                                      .doc(doc.id)
                                      .delete();
                                },
                              );
                            }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {},
                ),
                ...List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: Text('${i + 1}'),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {},
                ),
              ],
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
    String jenis = existing?['jenis'] ?? 'Makanan';
    final TextEditingController harga = TextEditingController(
      text: existing?['harga']?.toString() ?? '',
    );
    String stok = existing?['stok'] ?? 'Ada';
    String? gambarUrl = existing?['gambar_url'];
    XFile? pickedWebImage;
    Uint8List? pickedWebImageBytes;
    File? pickedImage;
    bool uploading = false;

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        if (kIsWeb) {
          pickedWebImage = picked;
          pickedWebImageBytes = await picked.readAsBytes();
        } else {
          pickedImage = File(picked.path);
        }
        setState(() {});
      }
    }

    Future<String?> uploadImage(dynamic image) async {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = firebase_storage.FirebaseStorage.instance.ref().child(
        'produk/$fileName.jpg',
      );
      if (kIsWeb && image is XFile) {
        await ref.putData(
          await image.readAsBytes(),
          firebase_storage.SettableMetadata(contentType: 'image/jpeg'),
        );
      } else if (image is File) {
        await ref.putFile(
          image,
          firebase_storage.SettableMetadata(contentType: 'image/jpeg'),
        );
      }
      return await ref.getDownloadURL();
    }

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setStateDialog) => AlertDialog(
                  title: Text(docId == null ? "Tambah Produk" : "Edit Produk"),
                  content: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await pickImage();
                              setStateDialog(() {});
                            },
                            child:
                                kIsWeb
                                    ? (pickedWebImageBytes != null
                                        ? Image.memory(
                                          pickedWebImageBytes!,
                                          height: 100,
                                        )
                                        : gambarUrl != null
                                        ? Image.network(gambarUrl, height: 100)
                                        : Container(
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Text('Pilih Gambar (web)'),
                                          ),
                                        ))
                                    : (pickedImage != null
                                        ? Image.file(pickedImage!, height: 100)
                                        : gambarUrl != null
                                        ? Image.network(gambarUrl, height: 100)
                                        : Container(
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Text('Pilih Gambar'),
                                          ),
                                        )),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: nama,
                            decoration: const InputDecoration(
                              labelText: 'Nama Produk',
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            value: jenis,
                            decoration: const InputDecoration(
                              labelText: 'Jenis',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Makanan',
                                child: Text('Makanan'),
                              ),
                              DropdownMenuItem(
                                value: 'Minuman',
                                child: Text('Minuman'),
                              ),
                            ],
                            onChanged:
                                (val) => setStateDialog(() => jenis = val!),
                          ),
                          TextFormField(
                            controller: harga,
                            decoration: const InputDecoration(
                              labelText: 'Harga',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          DropdownButtonFormField<String>(
                            value: stok,
                            decoration: const InputDecoration(
                              labelText: 'Status Stok',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Ada',
                                child: Text('Ada'),
                              ),
                              DropdownMenuItem(
                                value: 'Habis',
                                child: Text('Habis'),
                              ),
                            ],
                            onChanged:
                                (val) => setStateDialog(() => stok = val!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed:
                          uploading
                              ? null
                              : () async {
                                setStateDialog(() => uploading = true);
                                String? url = gambarUrl;
                                if (kIsWeb && pickedWebImage != null) {
                                  url = await uploadImage(pickedWebImage);
                                } else if (!kIsWeb && pickedImage != null) {
                                  url = await uploadImage(pickedImage!);
                                }
                                final data = {
                                  'nama': nama.text,
                                  'jenis': jenis,
                                  'harga': int.tryParse(harga.text) ?? 0,
                                  'stok': stok,
                                  'gambar_url': url,
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
                                setStateDialog(() => uploading = false);
                                Navigator.pop(ctx);
                              },
                      child:
                          uploading
                              ? const CircularProgressIndicator()
                              : const Text("Simpan"),
                    ),
                  ],
                ),
          ),
    );
  }
}
