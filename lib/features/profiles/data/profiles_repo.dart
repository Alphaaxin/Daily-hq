import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_db.dart';
import '../../../core/providers.dart';

class ProfilesRepo {
  ProfilesRepo(this.db);
  final AppDb db;

  Stream<List<Profile>> watch() =>
      (db.select(db.profiles)
            ..where((t) => t.archived.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.sort), (t) => OrderingTerm.asc(t.id)]))
          .watch();

  Future<void> add(String name, int color) async {
    final n = await db.select(db.profiles).get();
    await db
        .into(db.profiles)
        .insert(ProfilesCompanion.insert(name: name.trim(), color: Value(color), sort: Value(n.length)));
  }

  Future<void> rename(int id, String name) =>
      (db.update(db.profiles)..where((t) => t.id.equals(id))).write(ProfilesCompanion(name: Value(name.trim())));

  Future<void> archive(int id) =>
      (db.update(db.profiles)..where((t) => t.id.equals(id))).write(const ProfilesCompanion(archived: Value(true)));
}

final profilesRepoProvider = Provider((ref) => ProfilesRepo(ref.watch(dbProvider)));
final profilesProvider = StreamProvider<List<Profile>>((ref) => ref.watch(profilesRepoProvider).watch());

/// Selected work-profile filter on Today: null = All.
class ProfileFilter extends Notifier<int?> {
  @override
  int? build() => null;
  void select(int? id) => state = id;
}

final profileFilterProvider = NotifierProvider<ProfileFilter, int?>(ProfileFilter.new);
