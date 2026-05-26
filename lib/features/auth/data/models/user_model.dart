import 'package:hive/hive.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// UserModel is the DATA layer representation of a user.
///
/// Standalone class (does NOT extend UserEntity) so hive_generator can
/// produce a TypeAdapter. Conversion is handled by [fromEntity] / [toEntity].
///
/// [needsEmailConfirmation] is a transient flag — it is NOT persisted to Hive
/// because it is only relevant during the sign-up flow. The Hive adapter
/// ignores it (no @HiveField annotation).
@HiveType(typeId: AppConstants.userModelTypeId)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  /// True when Supabase requires the user to confirm their email before
  /// the session is active. Not stored in Hive.
  final bool needsEmailConfirmation;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.needsEmailConfirmation = false,
  });

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        name: entity.name,
        email: entity.email,
      );

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        email: email,
        needsEmailConfirmation: needsEmailConfirmation,
      );
}
