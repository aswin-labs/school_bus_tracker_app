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

  // get all students by routeId
  static const getStudentsByRouteId = "/driver/getStudentsByRouteId";

  // get student details by id
  static const getStudentDetailsById = "/driver/getStudentDetailsById";

  // get transport invoices by student id
  static const getTransportInvoiceByStudentId =
      "/driver/getTransportInvoiceByStudentId";

  // get students by routeId (unassigned stops)
  static const getStudentsWithUnassignedStopsByRouteId =
      "/driver/getStudentsWithUnassignedStopsByRouteId";

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

  // delete stop by id
  static const deleteStop = "/driver/deleteStopById";

  // ---------------------PROFILE / SETTINGS-----------------------
  // get transport staff profile and school details
  static const getMyProfileAndSchoolDetails =
      "/driver/getMyProfileAndSchoolDetails";

  // update transport staff profile details
  static const updateOwnProfileForDriver =
      "/driver/updateOwnProfileForDriver";

  // update transport staff profile picture (dp)
  static const updateDp = "/driver/updateDp";
}
