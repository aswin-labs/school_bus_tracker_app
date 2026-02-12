class StudentModel {
  int id;
  String name;
  String regNo;
  String? guardianName;
  String? stopName;

  StudentModel({
    required this.id,
    required this.name,
    required this.regNo,
    this.guardianName,
    this.stopName,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json["id"],
    name: json["full_name"],
    regNo: json["reg_no"],
    stopName: json["stop_name"],
    guardianName: json["guardian_name"],
  );
}
