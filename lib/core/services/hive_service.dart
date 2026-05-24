import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/features/auth/data/models/user_model.dart';

/// HiveService initialises Hive and registers TypeAdapters.
///
/// Only adapters for models that are currently persisted via Hive are
/// registered here. TaskModel uses an in-memory store in this phase —
/// add TaskModelAdapter() back when Hive persistence is introduced for tasks.
class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();

    // UserModel — persists auth session across app restarts.
    if (!Hive.isAdapterRegistered(AppConstants.userModelTypeId)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // TODO(phase-3): Register TaskModelAdapter() here when Hive is wired for tasks.
  }

  static Future<Box<T>> openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) return Hive.box<T>(boxName);
    return Hive.openBox<T>(boxName);
  }
}
