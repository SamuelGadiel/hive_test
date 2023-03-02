class User {
  final String username;
  final String password;

  User(this.username, this.password);
}

class UserModel extends User {
  final String username;
  final String password;

  UserModel(this.username, this.password) : super(username, password);

  static Map<String, dynamic> toJson(User user) {
    return {
      'username': user.username,
      'password': user.password,
    };
  }

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(json['username'], json['password']);
  }
}
