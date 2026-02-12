import 'package:school_bus_tracker/features/driver_routes/data/models/route_model.dart';
import 'package:school_bus_tracker/features/tracking/data/models/student_model.dart';

class StopModel {
  int? id;
  int? routeId;
  String stopName;
  int? priority;
  double latitude;
  double longitude;
  String? routeName;
  List<StudentModel>? students;
  RouteModel? route;

  StopModel({
    this.id,
    this.routeId,
    required this.stopName,
    this.priority,
    required this.latitude,
    required this.longitude,
    this.routeName,
    this.students,
    this.route,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) => StopModel(
    id: json["id"],
    routeId: json["route_id"],
    stopName: json["stop_name"],
    priority: json["priority"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    routeName: json["route_name"],
    students: json["students"] == null
        ? []
        : List<StudentModel>.from(
            json["students"]!.map((x) => StudentModel.fromJson(x)),
          ),
    route: json["route"] == null ? null : RouteModel.fromJson(json["route"]),
  );
}
