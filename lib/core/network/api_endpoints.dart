class ApiEndpoints {
  // login
  static const login = "/public/login";

  // routes
  static const routes = "/driver/getDriverAssignedRoutes";

  // activate route
  static const activateRoute = "/driver/updateRouteActive";

  // add stop
  static const addStop = "/driver/createStopForDriver";

  // get stop
  static const getStops = "/driver/getStopsForDriver";

  // get stop details
  static const getStopDetails = "/driver/getStopDetailsForDriver";

  // get students by routeId
  static const getStudents = "/driver/getMyStudents";

  // add students to stop
  static const addStudentsToStop = "/driver/assignStudentToStop";
}
