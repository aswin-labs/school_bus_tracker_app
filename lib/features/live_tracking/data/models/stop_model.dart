import 'package:school_bus_tracker/features/home/data/models/route_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/stop_live_status_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/student_model.dart';

class StopModel {
  int id;
  double latitude;
  double longitude;
  String stopName;
  int? priority;
  List<StopLiveStatusModel>? stopLiveStatuses;
  List<StudentModel>? students;
  RouteModel? route;
  List<StopRouteModel>? stopPriority;

  StopModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.stopName,
    this.priority,
    this.stopLiveStatuses,
    this.students,
    this.route,
    this.stopPriority,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) => StopModel(
    id: json["id"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    stopName: json["stop_name"],
    priority: json["priority"],
    stopLiveStatuses: json["LiveLocations"] == null
        ? []
        : List<StopLiveStatusModel>.from(
            json["LiveLocations"]!.map((x) => StopLiveStatusModel.fromJson(x)),
          ),
    students: json["students"] == null
        ? []
        : List<StudentModel>.from(
            json["students"]!.map((x) => StudentModel.fromJson(x)),
          ),
    route: json["route"] == null ? null : RouteModel.fromJson(json["route"]),
    stopPriority: json["StopRoutes"] == null
        ? []
        : List<StopRouteModel>.from(
            json["StopRoutes"]!.map((x) => StopRouteModel.fromJson(x)),
          ),
  );
}

class StopRouteModel {
  int? priority;

  StopRouteModel({this.priority});

  factory StopRouteModel.fromJson(Map<String, dynamic> json) =>
      StopRouteModel(priority: json["priority"]);
}
