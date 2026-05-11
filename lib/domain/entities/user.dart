import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String username;
  final String bio;
  final String photoUrl;
  final bool isPrivateProfile;
  final int profileGradientIndex;
  final UserStats stats;
  final Map<String, dynamic> widgetConfig;

  const User({
    required this.uid,
    required this.email,
    required this.username,
    this.bio = '',
    this.photoUrl = '',
    this.isPrivateProfile = false,
    this.profileGradientIndex = 0,
    this.stats = const UserStats(),
    this.widgetConfig = const {},
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      bio: data['bio'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      isPrivateProfile: data['isPrivateProfile'] ?? false,
      profileGradientIndex: data['profileGradientIndex'] ?? 0,
      stats: data['stats'] != null
          ? UserStats.fromMap(Map<String, dynamic>.from(data['stats']))
          : const UserStats(),
      widgetConfig: data['widgetConfig'] != null
          ? Map<String, dynamic>.from(data['widgetConfig'])
          : {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'bio': bio,
      'photoUrl': photoUrl,
      'isPrivateProfile': isPrivateProfile,
      'profileGradientIndex': profileGradientIndex,
      'stats': stats.toMap(),
      'widgetConfig': widgetConfig,
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? username,
    String? bio,
    String? photoUrl,
    bool? isPrivateProfile,
    int? profileGradientIndex,
    UserStats? stats,
    Map<String, dynamic>? widgetConfig,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      isPrivateProfile: isPrivateProfile ?? this.isPrivateProfile,
      profileGradientIndex: profileGradientIndex ?? this.profileGradientIndex,
      stats: stats ?? this.stats,
      widgetConfig: widgetConfig ?? this.widgetConfig,
    );
  }
}

class UserStats {
  final int currentGlobalStreak;
  final int postsCount;
  final int totalMinutes;

  const UserStats({
    this.currentGlobalStreak = 0,
    this.postsCount = 0,
    this.totalMinutes = 0,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      currentGlobalStreak: map['currentGlobalStreak'] ?? 0,
      postsCount: map['postsCount'] ?? 0,
      totalMinutes: map['totalMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentGlobalStreak': currentGlobalStreak,
      'postsCount': postsCount,
      'totalMinutes': totalMinutes,
    };
  }
}
