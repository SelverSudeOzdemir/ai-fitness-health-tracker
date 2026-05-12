import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  final int id;
  final String title;
  final String? description;
  final double price;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final String? category;
  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  Item({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.imageUrl,
    this.category,
    this.stockQuantity,
    this.userId,
    this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

@JsonSerializable()
class User {
  final int? id;
  final String username;
  final String email;
  final String? password;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final User user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

// Generic ApiResponse - manuel olarak yazacağız (JSON serialization yok)
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  // Manual fromJson
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      error: json['error'] as String?,
      message: json['message'] as String?,
    );
  }

  // Manual toJson
  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) {
    return {
      'success': success,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : null,
      'error': error,
      'message': message,
    };
  }
}
