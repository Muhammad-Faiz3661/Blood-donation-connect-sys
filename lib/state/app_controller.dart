import 'package:flutter/foundation.dart';

import '../data/local_store.dart';
import '../models/app_models.dart';

class AppController extends ChangeNotifier {
  AppController({LocalStore? store}) : _store = store ?? LocalStore();

  final LocalStore _store;
  List<AppUser> _users = [];
  List<DonationRequest> _requests = [];
  String? _currentUserId;
  bool isLoading = true;

  AppUser? get currentUser {
    for (final user in _users) {
      if (user.id == _currentUserId) return user;
    }
    return null;
  }

  List<AppUser> get users => List.unmodifiable(_users);
  List<DonationRequest> get requests => List.unmodifiable(_requests);

  Future<void> initialize() async {
    _users = await _store.loadUsers();
    _requests = await _store.loadRequests();
    _currentUserId = await _store.loadCurrentUserId();
    if (!_users.any((user) => user.id == _currentUserId)) {
      _currentUserId = null;
    }
    isLoading = false;
    notifyListeners();
  }

  List<AppUser> get availableDonors => _users
      .where((user) =>
          user.role == AccountRole.donor &&
          user.isAvailable &&
          user.id != _currentUserId)
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  List<DonationRequest> get incomingRequests {
    final user = currentUser;
    if (user == null) return [];
    return _requests
        .where((request) => request.donorId == user.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<DonationRequest> get outgoingRequests {
    final user = currentUser;
    if (user == null) return [];
    return _requests
        .where((request) => request.requesterId == user.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  AppUser? userById(String id) {
    for (final user in _users) {
      if (user.id == id) return user;
    }
    return null;
  }

  Future<void> createProfile({
    required String name,
    required String phone,
    required String location,
    required String bloodGroup,
    required AccountRole role,
  }) async {
    final user = AppUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      phone: phone.trim(),
      location: location.trim(),
      bloodGroup: bloodGroup,
      role: role,
    );
    _users = [..._users, user];
    _currentUserId = user.id;
    await _store.saveUsers(_users);
    await _store.saveCurrentUserId(user.id);
    notifyListeners();
  }

  Future<void> switchProfile(String? userId) async {
    _currentUserId = userId;
    await _store.saveCurrentUserId(userId);
    notifyListeners();
  }

  Future<void> setAvailability(bool isAvailable) async {
    final user = currentUser;
    if (user == null || user.role != AccountRole.donor) return;
    _users = _users
        .map((item) => item.id == user.id
            ? item.copyWith(isAvailable: isAvailable)
            : item)
        .toList();
    await _store.saveUsers(_users);
    notifyListeners();
  }

  Future<void> createRequest({
    required AppUser donor,
    required String hospital,
    required String location,
    required String note,
  }) async {
    final requester = currentUser;
    if (requester == null || donor.role != AccountRole.donor) return;
    final request = DonationRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      donorId: donor.id,
      requesterId: requester.id,
      requesterName: requester.name,
      requesterPhone: requester.phone,
      bloodGroup: donor.bloodGroup,
      location: location.trim(),
      hospital: hospital.trim(),
      note: note.trim(),
      createdAt: DateTime.now(),
    );
    _requests = [..._requests, request];
    await _store.saveRequests(_requests);
    notifyListeners();
  }

  Future<void> updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
    _requests = _requests
        .map((request) => request.id == requestId
            ? request.copyWith(status: status)
            : request)
        .toList();
    await _store.saveRequests(_requests);
    notifyListeners();
  }
}