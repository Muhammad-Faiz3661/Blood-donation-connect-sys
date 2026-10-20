enum AccountRole { donor, recipient }

enum RequestStatus { pending, accepted, declined, completed, cancelled }

const bloodGroups = <String>[
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
];

String statusLabel(RequestStatus status) => switch (status) {
      RequestStatus.pending => 'Awaiting response',
      RequestStatus.accepted => 'Accepted',
      RequestStatus.declined => 'Declined',
      RequestStatus.completed => 'Completed',
      RequestStatus.cancelled => 'Cancelled',
    };

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.bloodGroup,
    required this.role,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String phone;
  final String location;
  final String bloodGroup;
  final AccountRole role;
  final bool isAvailable;

  AppUser copyWith({bool? isAvailable}) => AppUser(
        id: id,
        name: name,
        phone: phone,
        location: location,
        bloodGroup: bloodGroup,
        role: role,
        isAvailable: isAvailable ?? this.isAvailable,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'location': location,
        'bloodGroup': bloodGroup,
        'role': role.name,
        'isAvailable': isAvailable,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        location: json['location'] as String,
        bloodGroup: json['bloodGroup'] as String,
        role: AccountRole.values.firstWhere(
          (role) => role.name == json['role'],
          orElse: () => AccountRole.recipient,
        ),
        isAvailable: json['isAvailable'] as bool? ?? true,
      );
}

class DonationRequest {
  const DonationRequest({
    required this.id,
    required this.donorId,
    required this.requesterId,
    required this.requesterName,
    required this.requesterPhone,
    required this.bloodGroup,
    required this.location,
    required this.hospital,
    required this.note,
    required this.createdAt,
    this.status = RequestStatus.pending,
  });

  final String id;
  final String donorId;
  final String requesterId;
  final String requesterName;
  final String requesterPhone;
  final String bloodGroup;
  final String location;
  final String hospital;
  final String note;
  final DateTime createdAt;
  final RequestStatus status;

  DonationRequest copyWith({RequestStatus? status}) => DonationRequest(
        id: id,
        donorId: donorId,
        requesterId: requesterId,
        requesterName: requesterName,
        requesterPhone: requesterPhone,
        bloodGroup: bloodGroup,
        location: location,
        hospital: hospital,
        note: note,
        createdAt: createdAt,
        status: status ?? this.status,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'donorId': donorId,
        'requesterId': requesterId,
        'requesterName': requesterName,
        'requesterPhone': requesterPhone,
        'bloodGroup': bloodGroup,
        'location': location,
        'hospital': hospital,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };

  factory DonationRequest.fromJson(Map<String, dynamic> json) =>
      DonationRequest(
        id: json['id'] as String,
        donorId: json['donorId'] as String,
        requesterId: json['requesterId'] as String,
        requesterName: json['requesterName'] as String,
        requesterPhone: json['requesterPhone'] as String,
        bloodGroup: json['bloodGroup'] as String,
        location: json['location'] as String,
        hospital: json['hospital'] as String,
        note: json['note'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: RequestStatus.values.firstWhere(
          (status) => status.name == json['status'],
          orElse: () => RequestStatus.pending,
        ),
      );
}