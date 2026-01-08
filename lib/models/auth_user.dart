class AuthUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final bool isActive;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.isActive,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'isActive': isActive,
      };
}
