class User {
  final String id;
  final String username;
  final String password;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final DateTime lastActive;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    this.avatar,
    required this.createdAt,
    required this.lastActive,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      avatar: map['avatar'],
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: DateTime.parse(map['lastActive']),
      role: map['role'],
    );
  }
}
