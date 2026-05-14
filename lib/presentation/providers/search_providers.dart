import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

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
