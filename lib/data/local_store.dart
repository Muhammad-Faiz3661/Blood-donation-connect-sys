import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';

class LocalStore {
  static const _usersKey = 'pulse.users';
  static const _requestsKey = 'pulse.requests';
  static const _currentUserKey = 'pulse.currentUser';

  Future<List<AppUser>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_usersKey), AppUser.fromJson);
  }

  Future<List<DonationRequest>> loadRequests() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_requestsKey), DonationRequest.fromJson);
  }

  Future<String?> loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  Future<void> saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _usersKey,
      jsonEncode(users.map((user) => user.toJson()).toList()),
    );
  }

  Future<void> saveRequests(List<DonationRequest> requests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _requestsKey,
      jsonEncode(requests.map((request) => request.toJson()).toList()),
    );
  }

  Future<void> saveCurrentUserId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, id);
    }
  }

  List<T> _decodeList<T>(
    String? value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value == null) return <T>[];
    try {
      final decoded = jsonDecode(value) as List<dynamic>;
      return decoded
          .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on FormatException {
      return <T>[];
    } on TypeError {
      return <T>[];
    }
  }
}