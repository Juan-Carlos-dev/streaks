import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import 'user_providers.dart';
import 'auth_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<User>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  // Simple prefix search
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isGreaterThanOrEqualTo: query)
      .where('username', isLessThanOrEqualTo: query + '\uf8ff')
      .limit(20)
      .get();

  return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
});

final recentUsersProvider = FutureProvider<List<User>>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null || currentUser.recentSearches.isEmpty) return [];

  // Fetch users in recentSearches
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where(FieldPath.documentId, whereIn: currentUser.recentSearches.take(10).toList())
      .get();

  final users = snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
  
  // Sort them to match the order in recentSearches
  final orderedUsers = <User>[];
  for (final uid in currentUser.recentSearches) {
    try {
      final user = users.firstWhere((u) => u.uid == uid);
      orderedUsers.add(user);
    } catch (_) {
      // User not found in the fetch (maybe deleted or limit reached)
    }
  }
  return orderedUsers;
});

final saveSearchHistoryProvider = Provider((ref) => (String searchedUid) async {
  final authUid = ref.read(authStateProvider).value;
  if (authUid == null) return;

  final userDoc = FirebaseFirestore.instance.collection('users').doc(authUid);
  
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(userDoc);
    if (!snapshot.exists) return;
    
    final data = snapshot.data()!;
    final recentSearches = List<String>.from(data['recentSearches'] ?? []);
    
    // Remove if already exists to put it at the top
    recentSearches.remove(searchedUid);
    // Add to top
    recentSearches.insert(0, searchedUid);
    // Limit to 10
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }
    
    transaction.update(userDoc, {'recentSearches': recentSearches});
  });
  
  ref.invalidate(recentUsersProvider);
});

final clearSearchHistoryProvider = Provider((ref) => () async {
  final authUid = ref.read(authStateProvider).value;
  if (authUid == null) return;

  final userDoc = FirebaseFirestore.instance.collection('users').doc(authUid);
  await userDoc.update({'recentSearches': []});
  
  ref.invalidate(recentUsersProvider);
});

final removeSearchHistoryItemProvider = Provider((ref) => (String targetUid) async {
  final authUid = ref.read(authStateProvider).value;
  if (authUid == null) return;

  final userDoc = FirebaseFirestore.instance.collection('users').doc(authUid);
  
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(userDoc);
    if (!snapshot.exists) return;
    
    final data = snapshot.data()!;
    final recentSearches = List<String>.from(data['recentSearches'] ?? []);
    
    recentSearches.remove(targetUid);
    
    transaction.update(userDoc, {'recentSearches': recentSearches});
  });
  
  ref.invalidate(recentUsersProvider);
});

final suggestedUsersProvider = FutureProvider<List<User>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .limit(20)
      .get();
      
  return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
});
