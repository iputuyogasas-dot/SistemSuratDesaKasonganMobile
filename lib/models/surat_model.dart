// lib/models/surat_model.dart

class SuratModel {
  final String id;
  final String nomorSurat;
  final String jenisSurat;
  final String namaPemohon;
  final String nik;
  final String keperluan;
  final String keterangan;
  final String status;
  final DateTime tanggalPengajuan;
  final String userId; // ← ID user yang mengajukan

  SuratModel({
    required this.id,
    required this.nomorSurat,
    required this.jenisSurat,
    required this.namaPemohon,
    required this.nik,
    required this.keperluan,
    required this.keterangan,
    required this.status,
    required this.tanggalPengajuan,
    required this.userId,
  });

  SuratModel copyWith({
    String? id,
    String? nomorSurat,
    String? jenisSurat,
    String? namaPemohon,
    String? nik,
    String? keperluan,
    String? keterangan,
    String? status,
    DateTime? tanggalPengajuan,
    String? userId,
  }) {
    return SuratModel(
      id: id ?? this.id,
      nomorSurat: nomorSurat ?? this.nomorSurat,
      jenisSurat: jenisSurat ?? this.jenisSurat,
      namaPemohon: namaPemohon ?? this.namaPemohon,
      nik: nik ?? this.nik,
      keperluan: keperluan ?? this.keperluan,
      keterangan: keterangan ?? this.keterangan,
      status: status ?? this.status,
      tanggalPengajuan: tanggalPengajuan ?? this.tanggalPengajuan,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomorSurat': nomorSurat,
      'jenisSurat': jenisSurat,
      'namaPemohon': namaPemohon,
      'nik': nik,
      'keperluan': keperluan,
      'keterangan': keterangan,
      'status': status,
      'tanggalPengajuan': tanggalPengajuan.toIso8601String(),
      'userId': userId,
    };
  }

  factory SuratModel.fromMap(Map<String, dynamic> map) {
    return SuratModel(
      id: map['id'] as String,
      nomorSurat: map['nomorSurat'] as String,
      jenisSurat: map['jenisSurat'] as String,
      namaPemohon: map['namaPemohon'] as String,
      nik: map['nik'] as String,
      keperluan: map['keperluan'] as String,
      keterangan: map['keterangan'] as String,
      status: map['status'] as String,
      tanggalPengajuan: DateTime.parse(map['tanggalPengajuan'] as String),
      userId: map['userId'] as String? ?? '', // backward compat
    );
  }
}
