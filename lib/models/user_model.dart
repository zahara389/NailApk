class UserModel {
  final int? id;
  final String name;
  final String email;
  final String username;
  final String? role;
  final String? photo;

  UserModel({this.id, required this.name, required this.email, required this.username, this.role, this.photo});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    username: json["username"],
    role: json["role"],
    photo: json["photo"],
  );
}