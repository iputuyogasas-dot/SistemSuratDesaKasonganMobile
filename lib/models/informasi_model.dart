// lib/models/informasi_model.dart

class InformasiModel {
  final String id;
  final String judul;
  final String isi;
  final String tipe; // 'Pengumuman' | 'Berita'
  final String kategori; // 'Penting' | 'Kesehatan' | 'Kegiatan' | 'Administrasi' | 'Umum'
  final DateTime tanggal;
  final String dibuatOleh;

  const InformasiModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tipe,
    required this.kategori,
    required this.tanggal,
    required this.dibuatOleh,
  });

  InformasiModel copyWith({
    String? id,
    String? judul,
    String? isi,
    String? tipe,
    String? kategori,
    DateTime? tanggal,
    String? dibuatOleh,
  }) {
    return InformasiModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      tipe: tipe ?? this.tipe,
      kategori: kategori ?? this.kategori,
      tanggal: tanggal ?? this.tanggal,
      dibuatOleh: dibuatOleh ?? this.dibuatOleh,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'tipe': tipe,
      'kategori': kategori,
      'tanggal': tanggal.toIso8601String(),
      'dibuatOleh': dibuatOleh,
    };
  }

  factory InformasiModel.fromMap(Map<String, dynamic> map) {
    return InformasiModel(
      id: map['id'] as String,
      judul: map['judul'] as String,
      isi: map['isi'] as String,
      tipe: map['tipe'] as String? ?? 'Pengumuman',
      kategori: map['kategori'] as String? ?? 'Umum',
      tanggal: DateTime.parse(map['tanggal'] as String),
      dibuatOleh: map['dibuatOleh'] as String? ?? '',
    );
  }
}
