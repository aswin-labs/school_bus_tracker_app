class ApiEndpoints {
  // login
  static const login = "/public/login";

  // Refresh token
  static const refreshToken = "/public/refresh-token";

  // routes
  static const routes = "/driver/getDriverAssignedRoutes";

  // activate route
  static const activateRoute = "/driver/updateRouteActive";

  // complete route
  static const completeRoute = "/driver/routeInactive";

  // add single stop
  static const addStop = "/driver/createStopForDriver";

  // add bulk stops
  static const addBulkStops = "/driver/bulkStopCreation";

  // get stop
  static const getStops = "/driver/getStopsForDriver";

  // get stop details
  static const getStopDetails = "/driver/getStopDetailsForDriver";

  // get students by routeId
  static const getStudents = "/driver/getMyStudents";

  // add students to stop
  static const addStudentsToStop = "/driver/assignStudentToStop";

  // update stop and student
  static const updateStopAndStudent = "/driver/updateStopAndStudent";

  // route inactive
  static const updateRouteInactive = "/driver/routeInactive";
}
