// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['image_url'] as String?,
  category: json['category'] as String?,
  stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'price': instance.price,
  'image_url': instance.imageUrl,
  'category': instance.category,
  'stock_quantity': instance.stockQuantity,
  'user_id': instance.userId,
  'created_at': instance.createdAt,
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num?)?.toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  password: json['password'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'password': instance.password,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'created_at': instance.createdAt,
};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  token: json['token'] as String,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{'user': instance.user, 'token': instance.token};
