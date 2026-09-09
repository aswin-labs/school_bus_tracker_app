class ApiEndpoints {
  // -----------------------AUTH-----------------------------------
  // login
  static const login = "/public/login";

  // Refresh token
  static const refreshToken = "/public/refresh-token";

  // ---------------------ROUTES-----------------------------------

  // routes
  static const routes = "/driver/getDriverAssignedRoutes";

  // activate route
  static const activateRoute = "/driver/updateRouteActive";

  // complete route
  static const inActivateRoute = "/driver/routeInactive";

  // ---------------------STOPS------------------------------------

    // get stops by routeId
  static const getStops = "/driver/getStopsForDriver";

  // get single stop details
  static const getStopDetails = "/driver/getStopDetailsForDriver";

  // rearrange stop priorities
  static const rearrangeStops = "/driver/bulkchangeStopPrioritybyRouteId";

  // add single stop
  static const addStop = "/driver/createStopForDriver";

  // update stop details
  static const updateStop = "/driver/updateStopForDriver";

  // add bulk stops
  static const addBulkStops = "/driver/bulkStopCreation";



  // get students by routeId
  static const getStudents = "/driver/getMyStudents";
  static const getStudentsWithUnassignedStopsByRouteId = "/driver/getMyStudents";

  // add students to stop
  static const addStudentsToStop = "/driver/assignStudentToStop";

  // update stop and student
  static const updateStopAndStudent = "/driver/updateStopAndStudent";

  // update live location
  static const updateLiveLocation = "/driver/updateLiveLocation";

  // edit student stop status
  static const editStudentsStopStatus = "/driver/editStudentsStopStatus";

  // get unassigned stops in pair route
  static const getUnassignedStopsInPairRoute =
      "/driver/getUnAssignedStopsInPairRouteByRouteId";

  // assign stop ids from pair route
  static const assignStopIdsFromPairRoute =
      "/driver/assignedStopIdsFromPairRoute";

  // delete student from stop
  static const deleteStudentFromStop = "/driver/deleteStudentFromStop";
}
