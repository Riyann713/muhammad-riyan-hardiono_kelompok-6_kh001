class User {
  final int id;
  final String name;
  final String email;
  final String city;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: int.parse(json['id'].toString()),
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        // mendukung format flat {"city": ..} maupun nested {"address": {"city": ..}}
        city: json['city'] ?? (json['address']?['city'] ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'city': city,
      };
}
