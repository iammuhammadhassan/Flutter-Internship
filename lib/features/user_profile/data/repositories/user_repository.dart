import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/network/http_service.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore, HttpService? httpService})
    : _firestore = firestore,
      _httpService = httpService ?? HttpService();

  final FirebaseFirestore? _firestore;
  final HttpService _httpService;
  static const String _usersApiUrl = 'https://jsonplaceholder.typicode.com/users';

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      (_firestore ?? FirebaseFirestore.instance).collection('users');

  Future<void> saveLoggedInUserDetails({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _usersCollection.doc(uid).set(<String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<UserModel>> fetchUsersFromApi() async {
    final dynamic response = await _httpService.getJson(_usersApiUrl);

    if (response is! List<dynamic>) {
      throw const FormatException('Invalid users response format.');
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList(growable: false);
  }
}
