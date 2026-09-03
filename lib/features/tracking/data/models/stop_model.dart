import 'package:school_bus_tracker/features/driver_routes/data/models/route_model.dart';
import 'package:school_bus_tracker/features/tracking/data/models/stop_live_status_model.dart';
import 'package:school_bus_tracker/features/tracking/data/models/student_model.dart';

class StopModel {
  int? id;
  int? routeId;
  String stopName;
  int? priority;
  double latitude;
  double longitude;
  String? routeName;
  String? routeType;
  bool? arrived;
  DateTime? arrivedTime;
  List<StudentModel>? students;
  RouteModel? route;
  List<StopLiveStatusModel>? stopLiveStatuses;

  StopModel({
    this.id,
    this.routeId,
    required this.stopName,
    this.priority,
    this.routeType,
    required this.latitude,
    required this.longitude,
    this.routeName,
    this.arrived,
    this.arrivedTime,
    this.students,
    this.route,
    this.stopLiveStatuses,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) => StopModel(
    id: json["id"],
    routeId: json["route_id"],
    stopName: json["stop_name"],
    priority: json["priority"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    routeName: json["route_name"],
    routeType: json["route_type"],
    arrived: json['arrived'],
    arrivedTime: json["arrived_time"] == null
        ? null
        : DateTime.parse(json["arrived_time"]),
    students: json["students"] == null
        ? []
        : List<StudentModel>.from(
            json["students"]!.map((x) => StudentModel.fromJson(x)),
          ),
    route: json["route"] == null ? null : RouteModel.fromJson(json["route"]),
    stopLiveStatuses: json["LiveLocations"] == null
        ? []
        : List<StopLiveStatusModel>.from(
            json["LiveLocations"]!.map((x) => StopLiveStatusModel.fromJson(x)),
          ),
  );
}
