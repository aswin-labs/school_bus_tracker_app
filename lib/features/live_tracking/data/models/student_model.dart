class StudentModel {
  int id;
  String fullName;
  String? regNo;
  User? user;

  StudentModel({
    required this.id,
    required this.fullName,
    this.regNo,
    this.user,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json["id"],
    fullName: json["full_name"],
    regNo: json["reg_no"],
    user: json["User"] == null ? null : User.fromJson(json["User"]),
  );
}

class User {
  String? name;
  String? phone;

  User({this.name, this.phone});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json["name"], phone: json["phone"]);
}
