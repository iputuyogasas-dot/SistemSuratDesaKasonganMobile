// lib/models/user_model.dart

class UserModel {
  final String id;
  final String username;
  final String password;
  final String role;
  final String namaLengkap;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.namaLengkap,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? password,
    String? role,
    String? namaLengkap,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      namaLengkap: namaLengkap ?? this.namaLengkap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'namaLengkap': namaLengkap,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      namaLengkap: map['namaLengkap'] as String,
    );
  }
}
