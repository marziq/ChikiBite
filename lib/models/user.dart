import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final int points;
  final Map<String, dynamic>? address;
  final List<Map<String, dynamic>>? addresses;
  final String? photoUrl;
  final DateTime? createdAt;
  final List<String>? favoriteItems;
  final List<Map<String, dynamic>>? paymentMethods;
  final Map<String, bool>? notificationSettings;
  final String? language;

  const User({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.points = 0,
    this.address,
    this.addresses,
    this.photoUrl,
    this.createdAt,
    this.favoriteItems,
    this.paymentMethods,
    this.notificationSettings,
    this.language,
  });

  User copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    int? points,
    Map<String, dynamic>? address,
    List<Map<String, dynamic>>? addresses,
    String? photoUrl,
    DateTime? createdAt,
    List<String>? favoriteItems,
    List<Map<String, dynamic>>? paymentMethods,
    Map<String, bool>? notificationSettings,
    String? language,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      points: points ?? this.points,
      address: address ?? this.address,
      addresses: addresses ?? this.addresses,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      favoriteItems: favoriteItems ?? this.favoriteItems,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      language: language ?? this.language,
    );
  }

  factory User.fromMap(Map<String, dynamic> map, {String? docId}) {
    final created = map['createdAt'];
    DateTime? createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is String) {
      createdAt = DateTime.tryParse(created);
    } else if (created is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(created);
    }

    return User(
      uid: (map['uid'] as String?) ?? docId ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      points: (map['points'] as num?)?.toInt() ?? 0,
      address: (map['address'] as Map?)?.cast<String, dynamic>(),
      addresses: (map['addresses'] as List?)
          ?.map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      photoUrl: map['photoUrl'] as String?,
      createdAt: createdAt,
      favoriteItems: (map['favoriteItems'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      paymentMethods: (map['paymentMethods'] as List?)
          ?.map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      notificationSettings: (map['notificationSettings'] as Map?)
          ?.cast<String, bool>(),
      language: map['language'] as String?,
    );
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      return User.fromMap(data, docId: doc.id);
    }
    return User(uid: doc.id, name: '', email: '');
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'points': points,
      if (address != null) 'address': address,
      if (addresses != null) 'addresses': addresses,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (favoriteItems != null) 'favoriteItems': favoriteItems,
      if (paymentMethods != null) 'paymentMethods': paymentMethods,
      if (notificationSettings != null)
        'notificationSettings': notificationSettings,
      if (language != null) 'language': language,
    };
  }

  @override
  String toString() {
    return 'User(uid: $uid, name: $name, email: $email, points: $points)';
  }
}
