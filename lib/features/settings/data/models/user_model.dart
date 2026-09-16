class UserModel {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? dp;
  final String? role;

  UserModel({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.dp,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"] is int
        ? json["id"]
        : int.tryParse(json["id"]?.toString() ?? '') ?? 0,
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    dp: json["dp"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "dp": dp,
    "role": role,
  };
}
