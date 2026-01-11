import 'package:cloud_firestore/cloud_firestore.dart';

class User {
	final String uid;
	final String name;
	final String email;
	final String? phone;
	final int points;
	final Map<String, dynamic>? address;
	final String? photoUrl;
	final DateTime? createdAt;

	const User({
		required this.uid,
		required this.name,
		required this.email,
		this.phone,
		this.points = 0,
		this.address,
		this.photoUrl,
		this.createdAt,
	});

	User copyWith({
		String? uid,
		String? name,
		String? email,
		String? phone,
		int? points,
		Map<String, dynamic>? address,
		String? photoUrl,
		DateTime? createdAt,
	}) {
		return User(
			uid: uid ?? this.uid,
			name: name ?? this.name,
			email: email ?? this.email,
			phone: phone ?? this.phone,
			points: points ?? this.points,
			address: address ?? this.address,
			photoUrl: photoUrl ?? this.photoUrl,
			createdAt: createdAt ?? this.createdAt,
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
			photoUrl: map['photoUrl'] as String?,
			createdAt: createdAt,
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
			if (photoUrl != null) 'photoUrl': photoUrl,
			if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
		};
	}

	@override
	String toString() {
		return 'User(uid: $uid, name: $name, email: $email, points: $points)';
	}
}