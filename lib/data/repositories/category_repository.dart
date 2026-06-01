import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../db/app_db.dart';
import 'habit_repository.dart';

part 'category_repository.g.dart';

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) =>
    CategoryRepository(ref.watch(appDbProvider));

/// User-defined habit categories that augment the preset enum.
class CategoryRepository {
  CategoryRepository(this._db);
  final AppDb _db;
  static const _uuid = Uuid();

  Stream<List<UserCategory>> watchAll() =>
      (_db.select(_db.userCategories)
            ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
          .watch();

  Future<List<UserCategory>> readAll() =>
      (_db.select(_db.userCategories)
            ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
          .get();

  Future<String> create(String label) async {
    final id = _uuid.v4();
    await _db.into(_db.userCategories).insert(UserCategoriesCompanion.insert(
          id: id,
          label: label.trim(),
          createdAt: DateTime.now(),
        ));
    return id;
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.userCategories)..where((c) => c.id.equals(id)))
        .go();
  }
}

final userCategoriesStreamProvider =
    StreamProvider<List<UserCategory>>(
        (ref) => ref.watch(categoryRepositoryProvider).watchAll());
