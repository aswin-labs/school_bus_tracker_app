import 'package:school_bus_tracker/features/live_tracking/data/models/student_model.dart';

class StopLiveStatusModel {
    String? latitude;
    String? longitude;
    int? routeId;
    int? stopId;
    DateTime? createdAt;
    List<StudentsStopStatus>? studentsStopStatuses;

    StopLiveStatusModel({
        this.latitude,
        this.longitude,
        this.routeId,
        this.stopId,
        this.createdAt,
        this.studentsStopStatuses,
    });

    factory StopLiveStatusModel.fromJson(Map<String, dynamic> json) => StopLiveStatusModel(
        latitude: json["latitude"],
        longitude: json["longitude"],
        routeId: json["route_id"],
        stopId: json["stop_id"],
        createdAt: json["createdAt"] == null ? null : DateTime.tryParse(json["createdAt"]),
        studentsStopStatuses: json["StudentsStopStatuses"] == null ? [] : List<StudentsStopStatus>.from(json["StudentsStopStatuses"]!.map((x) => StudentsStopStatus.fromJson(x))),
    );
}

class StudentsStopStatus {
    int? id;
    int? studentId;
    String? status;
    StudentModel? student;

    StudentsStopStatus({
        this.id,
        this.studentId,
        this.status,
        this.student,
    });

    factory StudentsStopStatus.fromJson(Map<String, dynamic> json) => StudentsStopStatus(
        id: json["id"],
        studentId: json["student_id"],
        status: json["status"],
        student: json["Student"] == null ? null : StudentModel.fromJson(json["Student"]),
    );
}
