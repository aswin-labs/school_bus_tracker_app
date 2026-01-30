import 'package:school_bus_tracker/features/driver_routes/data/models/route_model.dart';

class StopModel {
  int? id;
  int routeId;
  String stopName;
  int? priority;
  double latitude;
  double longitude;
  bool? trash;
  RouteModel? driverRoute;

  StopModel({
    this.id,
    required this.routeId,
    required this.stopName,
    this.priority,
    required this.latitude,
    required this.longitude,
    this.trash,
    this.driverRoute,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) => StopModel(
    id: json["id"],
    routeId: json["route_id"],
    stopName: json["stop_name"],
    priority: json["priority"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    trash: json["trash"],
    driverRoute: json["route"] == null
        ? null
        : RouteModel.fromJson(json["route"]),
  );
}
