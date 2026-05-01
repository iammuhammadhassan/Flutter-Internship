class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as int? ?? 0,
      name: data['name'] as String? ?? 'N/A',
      username: data['username'] as String? ?? 'N/A',
      email: data['email'] as String? ?? 'N/A',
      phone: data['phone'] as String? ?? 'N/A',
      website: data['website'] as String? ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'website': website,
    };
  }
}
