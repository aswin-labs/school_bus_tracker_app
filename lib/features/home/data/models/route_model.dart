class RouteModel {
  int id;
  String? routeName;
  int? vehicleId;
  String? type;
  bool? active;
  DateTime? activatedAt;
  int? totalStudents;
  bool? isLock;
  int? pickupId;
  int? totalStops;

  RouteModel({
    required this.id,
    this.routeName,
    this.vehicleId,
    this.type,
    this.active,
    this.activatedAt,
    this.totalStudents,
    this.isLock,
    this.pickupId,
    this.totalStops,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
    id: json["id"],
    routeName: json["route_name"],
    vehicleId: json["vehicle_id"],
    type: json["type"],
    active: json["active"],
    activatedAt: json["activated_at"] == null
        ? null
        : DateTime.parse(json["activated_at"]),
    totalStudents: json["total_students"],
    isLock: json["isLock"],
    pickupId: json["pickId"],
    totalStops: json["total_stops"],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
