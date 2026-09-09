class StudentModel {
  int id;
  String fullName;
  String? regNo;
  User? user;
  ClassGradeModel? classGrade;

  StudentModel({
    required this.id,
    required this.fullName,
    this.regNo,
    this.user,
    this.classGrade,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json["id"],
    fullName: json["full_name"],
    regNo: json["reg_no"],
    user: json["User"] == null ? null : User.fromJson(json["User"]),
    classGrade: json["Class"] == null
        ? null
        : ClassGradeModel.fromJson(json["Class"]),
  );
}

class User {
  String? name;
  String? phone;

  User({this.name, this.phone});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json["name"], phone: json["phone"]);
}

class ClassGradeModel {
  String? classname;

  ClassGradeModel({this.classname});

  factory ClassGradeModel.fromJson(Map<String, dynamic> json) =>
      ClassGradeModel(classname: json["classname"]);
}
