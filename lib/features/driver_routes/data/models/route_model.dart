class RouteModel {
    int id;
    String? routeName;
    int? vehicleId;
    String? type;
    bool? active;
    DateTime? activatedAt;
    int? totalStudents;

    RouteModel({
        required this.id,
        this.routeName,
        this.vehicleId,
        this.type,
        this.active,
        this.activatedAt,
        this.totalStudents,
    });

    factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json["id"],
        routeName: json["route_name"],
        vehicleId: json["vehicle_id"],
        type: json["type"],
        active: json["active"],
        activatedAt: json["activated_at"] == null ? null : DateTime.parse(json["activated_at"]),
        totalStudents: json["total_students"],
    );
}
