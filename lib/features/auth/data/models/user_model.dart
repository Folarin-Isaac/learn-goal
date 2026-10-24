import 'package:lengoal/core/utils/jwt_decoder.dart';
import 'package:lengoal/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const new({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
  });

  factory fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
  }

  // Login only returns a userId, no user object — the rest of the
  // profile comes from the access token's claims instead.
  factory fromLoginToken({
    required String userId,
    required String accessToken,
    required String fallbackEmail,
  }) {
    final claims = JwtDecoder.decodePayload(accessToken);
    return UserModel(
      id: userId,
      email: claims['Email'] as String? ?? fallbackEmail,
      firstName: claims['FirstName'] as String? ?? '',
      lastName: claims['LastName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
  };
}
