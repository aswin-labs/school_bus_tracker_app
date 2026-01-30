class RouteModel {
  int? id;
  String? routeName;
  Vehicle? vehicle;
  DateTime? createdAt;
  bool? trash;
  String? type;
  bool? isLock;
  List<dynamic>? students;

  RouteModel({
    this.id,
    this.routeName,
    this.vehicle,
    this.createdAt,
    this.trash,
    this.type,
    this.isLock,
    this.students,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
    id: json["id"],
    routeName: json["route_name"],
    vehicle: json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    trash: json["trash"],
    type: json["type"],
    isLock: json["isLock"],
    students: json["students"] == null
        ? []
        : List<dynamic>.from(json["students"]!.map((x) => x)),
  );
}

class Vehicle {
  int? id;
  String? type;
  String? model;
  String? vehicleNumber;
  dynamic photo;
  DateTime? createdAt;
  bool? trash;
  dynamic checkInLatitude;
  dynamic checkInLongitude;

  Vehicle({
    this.id,
    this.type,
    this.model,
    this.vehicleNumber,
    this.photo,
    this.createdAt,
    this.trash,
    this.checkInLatitude,
    this.checkInLongitude,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json["id"],
    type: json["type"],
    model: json["model"],
    vehicleNumber: json["vehicle_number"],
    photo: json["photo"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    trash: json["trash"],
    checkInLatitude: json["check_in_latitude"],
    checkInLongitude: json["check_in_longitude"],
  );
}
