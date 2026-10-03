class StudentModel {
  int id;
  String fullName;
  String? regNo;
  int? rollNumber;
  int? classId;
  String? image;
  String? dateOfBirth;
  String? gender;
  String? address;
  String? admissionDate;
  String? status;
  User? user;
  ClassGradeModel? classGrade;

  StudentModel({
    required this.id,
    required this.fullName,
    this.regNo,
    this.rollNumber,
    this.classId,
    this.image,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.admissionDate,
    this.status,
    this.user,
    this.classGrade,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json["id"] ?? 0,
    fullName: json["full_name"] ?? "",
    regNo: json["reg_no"]?.toString(),
    rollNumber: json["roll_number"] != null
        ? int.tryParse(json["roll_number"].toString())
        : null,
    classId: json["class_id"] != null
        ? int.tryParse(json["class_id"].toString())
        : null,
    image: json["image"] ??
        json["student_image"] ??
        json["profile_image"] ??
        json["photo"] ??
        json["dp"],
    dateOfBirth: json["date_of_birth"],
    gender: json["gender"],
    address: json["address"],
    admissionDate: json["admission_date"],
    status: json["status"],
    user: json["User"] == null ? null : User.fromJson(json["User"]),
    classGrade: json["Class"] == null
        ? null
        : ClassGradeModel.fromJson(json["Class"]),
  );
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? dp;
  GuardianModel? guardian;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.dp,
    this.guardian,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    dp: json["dp"],
    guardian: json["Guardian"] == null
        ? null
        : GuardianModel.fromJson(json["Guardian"]),
  );
}

class GuardianModel {
  String? guardianJob;
  String? guardianRelation;
  String? guardian2Name;
  String? guardian2Contact;
  String? guardian2Job;
  String? guardian2Relation;
  String? fatherName;
  String? motherName;
  String? houseName;
  String? street;
  String? city;
  String? landmark;
  String? district;
  String? state;
  String? country;
  String? post;
  String? pincode;

  GuardianModel({
    this.guardianJob,
    this.guardianRelation,
    this.guardian2Name,
    this.guardian2Contact,
    this.guardian2Job,
    this.guardian2Relation,
    this.fatherName,
    this.motherName,
    this.houseName,
    this.street,
    this.city,
    this.landmark,
    this.district,
    this.state,
    this.country,
    this.post,
    this.pincode,
  });

  factory GuardianModel.fromJson(Map<String, dynamic> json) => GuardianModel(
    guardianJob: json["guardian_job"],
    guardianRelation: json["guardian_relation"],
    guardian2Name: json["guardian2_name"],
    guardian2Contact: json["guardian2_contact"],
    guardian2Job: json["guardian2_job"],
    guardian2Relation: json["guardian2_relation"],
    fatherName: json["father_name"],
    motherName: json["mother_name"],
    houseName: json["house_name"],
    street: json["street"],
    city: json["city"],
    landmark: json["landmark"],
    district: json["district"],
    state: json["state"],
    country: json["country"],
    post: json["post"],
    pincode: json["pincode"],
  );
}

class ClassGradeModel {
  int? id;
  int? year;
  String? division;
  String? classname;

  ClassGradeModel({
    this.id,
    this.year,
    this.division,
    this.classname,
  });

  factory ClassGradeModel.fromJson(Map<String, dynamic> json) =>
      ClassGradeModel(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        year: json["year"] != null ? int.tryParse(json["year"].toString()) : null,
        division: json["division"],
        classname: json["classname"],
      );
}

class PaginatedStudentsResponse {
  final bool success;
  final int totalContent;
  final int totalPages;
  final int currentPage;
  final List<StudentModel> students;

  PaginatedStudentsResponse({
    this.success = false,
    this.totalContent = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.students = const [],
  });

  factory PaginatedStudentsResponse.fromJson(
    Map<String, dynamic> json, {
    String? preferredKey,
  }) {
    dynamic rawList;
    if (preferredKey != null && json[preferredKey] != null) {
      rawList = json[preferredKey];
    } else {
      rawList = json['students'] ?? json['data'];
    }

    final List<StudentModel> studentList = [];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          studentList.add(StudentModel.fromJson(item));
        }
      }
    }

    return PaginatedStudentsResponse(
      success: json['success'] == true,
      totalContent: json['totalcontent'] is int
          ? json['totalcontent']
          : int.tryParse(
                  json['totalcontent']?.toString() ??
                  json['totalContent']?.toString() ??
                  json['total_content']?.toString() ??
                  '${studentList.length}',
                ) ??
                studentList.length,
      totalPages: json['totalPages'] is int
          ? json['totalPages']
          : int.tryParse(
                  json['totalPages']?.toString() ??
                  json['total_pages']?.toString() ??
                  '1',
                ) ??
                1,
      currentPage: json['currentPage'] is int
          ? json['currentPage']
          : int.tryParse(
                  json['currentPage']?.toString() ??
                  json['current_page']?.toString() ??
                  '1',
                ) ??
                1,
      students: studentList,
    );
  }
}

