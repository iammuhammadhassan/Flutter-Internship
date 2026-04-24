import '../../../../core/network/http_service.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  final HttpService _httpService;
  static const String _primaryUsersUrl = 'https://dummyjson.com/users?limit=10';
  static const String _fallbackUsersUrl =
      'https://jsonplaceholder.typicode.com/users';

  Future<List<UserModel>> fetchUsers() async {
    try {
      final dynamic data = await _httpService.getJson(_primaryUsersUrl);
      return _parseUsers(data);
    } catch (error) {
      if (_isForbidden(error)) {
        final dynamic fallbackData = await _httpService.getJson(
          _fallbackUsersUrl,
        );
        return _parseUsers(fallbackData);
      }

      rethrow;
    }
  }

  List<UserModel> _parseUsers(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList(growable: false);
    }

    if (data is Map<String, dynamic>) {
      final dynamic users = data['users'];

      if (users is List) {
        return users
            .whereType<Map<String, dynamic>>()
            .map(_mapDummyJsonUser)
            .toList(growable: false);
      }
    }

    throw const FormatException('Expected a list of users from API.');
  }

  UserModel _mapDummyJsonUser(Map<String, dynamic> json) {
    final companyData = json['company'] as Map<String, dynamic>?;

    return UserModel(
      id: json['id'] as int? ?? 0,
      name: '${json['firstName'] ?? 'N/A'} ${json['lastName'] ?? ''}'.trim(),
      username: json['username'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      phone: json['phone'] as String? ?? 'N/A',
      website: json['domain'] as String? ?? 'N/A',
      company: companyData?['name'] as String? ?? 'N/A',
    );
  }

  bool _isForbidden(Object error) {
    final String message = error.toString().toLowerCase();
    return message.contains('403') || message.contains('forbidden');
  }
}
