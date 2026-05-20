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
  final List<String> followedGroups;
  final List<String> recentSearches;
  final List<String> customGradient;
  final Map<String, dynamic> notificationConfig;
  final List<String> hiddenUsers;
  final List<String> reportedPosts;
  final String bannerEmojiPattern;
  final String bannerEmojiStyle;
  final double bannerEmojiSize;
  final double bannerEmojiRotation;
  final double bannerEmojiOpacity;
  final String bannerEmojiSeed;
  final double bannerEmojiSpacing;

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
    this.followedGroups = const [],
    this.recentSearches = const [],
    this.customGradient = const ['#3D8EF0', '#64B5F6'], // Default blue gradient
    this.notificationConfig = const {
      'dailyReminderEnabled': true,
      'dailyReminderTime': '20:00',
      'notifyLikes': true,
      'notifyComments': true,
      'notifyFollowers': true,
    },
    this.hiddenUsers = const [],
    this.reportedPosts = const [],
    this.bannerEmojiPattern = '',
    this.bannerEmojiStyle = 'none',
    this.bannerEmojiSize = 16.0,
    this.bannerEmojiRotation = 0.0,
    this.bannerEmojiOpacity = 0.20,
    this.bannerEmojiSeed = '',
    this.bannerEmojiSpacing = 1.0,
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
      followedGroups: List<String>.from(data['followedGroups'] ?? []),
      recentSearches: List<String>.from(data['recentSearches'] ?? []),
      customGradient: List<String>.from(data['customGradient'] ?? ['#3D8EF0', '#64B5F6']),
      notificationConfig: data['notificationConfig'] != null
          ? Map<String, dynamic>.from(data['notificationConfig'])
          : {
              'dailyReminderEnabled': true,
              'dailyReminderTime': '20:00',
              'notifyLikes': true,
              'notifyComments': true,
              'notifyFollowers': true,
            },
      hiddenUsers: List<String>.from(data['hiddenUsers'] ?? []),
      reportedPosts: List<String>.from(data['reportedPosts'] ?? []),
      bannerEmojiPattern: data['bannerEmojiPattern'] ?? '',
      bannerEmojiStyle: data['bannerEmojiStyle'] ?? 'none',
      bannerEmojiSize: (data['bannerEmojiSize'] ?? 16.0) is int 
          ? (data['bannerEmojiSize'] as int).toDouble() 
          : (data['bannerEmojiSize'] ?? 16.0) as double,
      bannerEmojiRotation: (data['bannerEmojiRotation'] ?? 0.0) is int 
          ? (data['bannerEmojiRotation'] as int).toDouble() 
          : (data['bannerEmojiRotation'] ?? 0.0) as double,
      bannerEmojiOpacity: (data['bannerEmojiOpacity'] ?? 0.20) is int 
          ? (data['bannerEmojiOpacity'] as int).toDouble() 
          : (data['bannerEmojiOpacity'] ?? 0.20) as double,
      bannerEmojiSeed: data['bannerEmojiSeed'] ?? '',
      bannerEmojiSpacing: (data['bannerEmojiSpacing'] ?? 1.0) is int
          ? (data['bannerEmojiSpacing'] as int).toDouble()
          : (data['bannerEmojiSpacing'] ?? 1.0) as double,
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
      'followedGroups': followedGroups,
      'recentSearches': recentSearches,
      'customGradient': customGradient,
      'notificationConfig': notificationConfig,
      'hiddenUsers': hiddenUsers,
      'reportedPosts': reportedPosts,
      'bannerEmojiPattern': bannerEmojiPattern,
      'bannerEmojiStyle': bannerEmojiStyle,
      'bannerEmojiSize': bannerEmojiSize,
      'bannerEmojiRotation': bannerEmojiRotation,
      'bannerEmojiOpacity': bannerEmojiOpacity,
      'bannerEmojiSeed': bannerEmojiSeed,
      'bannerEmojiSpacing': bannerEmojiSpacing,
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
    List<String>? followedGroups,
    List<String>? recentSearches,
    List<String>? customGradient,
    Map<String, dynamic>? notificationConfig,
    List<String>? hiddenUsers,
    List<String>? reportedPosts,
    String? bannerEmojiPattern,
    String? bannerEmojiStyle,
    double? bannerEmojiSize,
    double? bannerEmojiRotation,
    double? bannerEmojiOpacity,
    String? bannerEmojiSeed,
    double? bannerEmojiSpacing,
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
      followedGroups: followedGroups ?? this.followedGroups,
      recentSearches: recentSearches ?? this.recentSearches,
      customGradient: customGradient ?? this.customGradient,
      notificationConfig: notificationConfig ?? this.notificationConfig,
      hiddenUsers: hiddenUsers ?? this.hiddenUsers,
      reportedPosts: reportedPosts ?? this.reportedPosts,
      bannerEmojiPattern: bannerEmojiPattern ?? this.bannerEmojiPattern,
      bannerEmojiStyle: bannerEmojiStyle ?? this.bannerEmojiStyle,
      bannerEmojiSize: bannerEmojiSize ?? this.bannerEmojiSize,
      bannerEmojiRotation: bannerEmojiRotation ?? this.bannerEmojiRotation,
      bannerEmojiOpacity: bannerEmojiOpacity ?? this.bannerEmojiOpacity,
      bannerEmojiSeed: bannerEmojiSeed ?? this.bannerEmojiSeed,
      bannerEmojiSpacing: bannerEmojiSpacing ?? this.bannerEmojiSpacing,
    );
  }
}


  class UserStats {
    final int currentGlobalStreak;
    final int postsCount;
    final int totalMinutes;
    final int followersCount;  // 👈 añadir
    final int followingCount;  // 👈 añadir

  const UserStats({
    this.currentGlobalStreak = 0,
    this.postsCount = 0,
    this.totalMinutes = 0,
    this.followersCount = 0,  // 👈 añadir
    this.followingCount = 0,  // 👈 añadir
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      currentGlobalStreak: map['currentGlobalStreak'] ?? 0,
      postsCount: map['postsCount'] ?? 0,
      totalMinutes: map['totalMinutes'] ?? 0,
      followersCount: map['followersCount'] ?? 0,  // 👈 añadir
      followingCount: map['followingCount'] ?? 0,  // 👈 añadir
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentGlobalStreak': currentGlobalStreak,
      'postsCount': postsCount,
      'totalMinutes': totalMinutes,
      'followersCount': followersCount,  // 👈 añadir
      'followingCount': followingCount,  // 👈 añadir
    };
  }
}