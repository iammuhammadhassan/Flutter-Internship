class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.company,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String company;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final companyData = json['company'] as Map<String, dynamic>?;

    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
      username: json['username'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      phone: json['phone'] as String? ?? 'N/A',
      website: json['website'] as String? ?? 'N/A',
      company: companyData?['name'] as String? ?? 'N/A',
    );
  }
}
