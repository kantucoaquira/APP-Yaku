class User {
  final String token;
  final String role;

  User({required this.token, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'],
      role: json['role'],
    );
  }
}