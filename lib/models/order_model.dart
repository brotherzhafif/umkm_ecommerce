class OrderModel {
  final String id;
  final String pelanggan;
  final String? phone; // Add phone field
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
  // New fields for delivery options
  final String? alamat_pengiriman;
  final String tipe_pengiriman;
  final String? info_pengiriman;
  final String metode_pembayaran;

  OrderModel({
    required this.id,
    required this.pelanggan,
    this.phone, // Add phone parameter
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
    this.alamat_pengiriman,
    this.tipe_pengiriman = 'dine_in',
    this.info_pengiriman,
    this.metode_pembayaran = 'transfer',
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      pelanggan: map['pelanggan'] ?? '',
      phone: map['phone'], // Add phone from map
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
      alamat_pengiriman: map['alamat_pengiriman'],
      tipe_pengiriman: map['tipe_pengiriman'] ?? 'dine_in',
      info_pengiriman: map['info_pengiriman'],
      metode_pembayaran: map['metode_pembayaran'] ?? 'transfer',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pelanggan': pelanggan,
      'phone': phone, // Add phone to map
      'meja': meja,
      'catatan': catatan,
      'status': status,
      'total': total,
      'tanggal': tanggal,
      'bukti_pembayaran_url': buktiPembayaranUrl,
      'id_pembayaran': idPembayaran,
      'pembayaran_divalidasi': pembayaranDivalidasi,
      'waktu_validasi': waktuValidasi,
      'alamat_pengiriman': alamat_pengiriman,
      'tipe_pengiriman': tipe_pengiriman,
      'info_pengiriman': info_pengiriman,
      'metode_pembayaran': metode_pembayaran,
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
