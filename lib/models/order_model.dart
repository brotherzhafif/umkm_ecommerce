class OrderModel {
  final String id;
  final String pelanggan;
  final String meja;
  final String? catatan;
  final String status;
  final int total;
  final DateTime tanggal;
  final String? buktiPembayaranUrl;
  final String? idPembayaran;
  final List<OrderItemModel>? items;
  final bool? pembayaranDivalidasi;
  final DateTime? waktuValidasi;

  OrderModel({
    required this.id,
    required this.pelanggan,
    required this.meja,
    this.catatan,
    required this.status,
    required this.total,
    required this.tanggal,
    this.buktiPembayaranUrl,
    this.idPembayaran,
    this.items,
    this.pembayaranDivalidasi,
    this.waktuValidasi,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      pelanggan: map['pelanggan'] ?? '',
      meja: map['meja'] ?? '',
      catatan: map['catatan'],
      status: map['status'] ?? 'Menunggu Konfirmasi',
      total: map['total'] ?? 0,
      tanggal: map['tanggal']?.toDate() ?? DateTime.now(),
      buktiPembayaranUrl: map['bukti_pembayaran_url'],
      idPembayaran: map['id_pembayaran'],
      items: null, // Items loaded separately
      pembayaranDivalidasi: map['pembayaran_divalidasi'],
      waktuValidasi: map['waktu_validasi']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pelanggan': pelanggan,
      'meja': meja,
      'catatan': catatan,
      'status': status,
      'total': total,
      'tanggal': tanggal,
      'bukti_pembayaran_url': buktiPembayaranUrl,
      'id_pembayaran': idPembayaran,
      'pembayaran_divalidasi': pembayaranDivalidasi,
      'waktu_validasi': waktuValidasi,
    };
  }
}

class OrderItemModel {
  final String nama;
  final int jumlah;
  final int total;

  OrderItemModel({
    required this.nama,
    required this.jumlah,
    required this.total,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      nama: map['nama'] ?? '',
      jumlah: map['jumlah'] ?? 0,
      total: map['total'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'nama': nama, 'jumlah': jumlah, 'total': total};
  }
}
