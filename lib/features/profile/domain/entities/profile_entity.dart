import 'package:equatable/equatable.dart';

/// ProfileEntity holds display data for the user's profile screen.
class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}
