class Endpoints {
  // Main URL
  // static const String MAIN_URL = "https://demo.techbizafrica.com/mcp/mobile/android/hawkers/index.php"; // demo server]
  // static const String MAIN_URL = "https://demo.techbizafrica.com/mcp/mobile/android/";
  static const String MAIN_URL = "https://eportal.mombasa.go.ke/mobile/android/"; // prod server

  // Versioning URL
  static const String VERSION_URL = "${MAIN_URL}staff/vcs_staff.php";

  // GOOGLE URL
  static const String GOOGLE_URL = "https://google.com";

  // Login URL
  static const String LOGIN_URL = "${MAIN_URL}staff/loginV2.php";

  // Password Reset URL
  // static const String PRESET_URL = "${MAIN_URL}presetV2.php";
  static const String PRESET_URL = "${MAIN_URL}staff/password_reset.php";  /* Send email only*/

  // Password Change URL
  static const String PRNEWPASS_URL = "${MAIN_URL}staff/newpassV2.php";

  // Hawkers  URL
  static const String HAWKER_URL = "${MAIN_URL}hawkers/index.php";

  // Check Status
  static const String CHECKSTATUS_URL = "${MAIN_URL}staff/parking/check_status.php";

  // Check Traffic Offence Status
  static const String CHECK_TRAFFIC_OFFENCE_STATUS_URL = "${MAIN_URL}staff/trafficOffence/check_status.php";

  // Traffic Offence Types
  static const String TRAFFIC_OFFENCE_TYPES = "${MAIN_URL}staff/trafficOffence/offence_types.php";

  // Clamp Vehicle
  static const String CLAMPVEHICLE_URL = "${MAIN_URL}staff/parking/clamp_vehicle.php";

  // Clamp Traffic Offence Vehicle
  static const String CLAMP_TRAFFIC_OFFENCE_VEHICLE_URL = "${MAIN_URL}staff/trafficOffence/clamp_vehicle.php";

  // Parking Categories URL
  static const String PARKINGCAT_URL = "${MAIN_URL}parking/fetch_categories.php";

  // Check PSV Status
  static const String CHECKPSVSTATUS_URL = "${MAIN_URL}staff/psv/check_status.php";

  // Fraudulent URL
  static const String FRAUDULENT_URL = "${MAIN_URL}staff/psv/fraudulent_url.php";

  // Send SMS URL
  static const String SENDSMS_URL = "${MAIN_URL}parking/sendText.php";

  // Check Cess Status
  static const String CHECKCESSSTATUS_URL = "${MAIN_URL}staff/cess/check_vehicle.php";

  // Cess Penalize URL
  static const String CESSPENALIZE_URL = "${MAIN_URL}staff/cess/vehicle_penalize.php";

  // Cess Tasks URL
  static const String CESSTASKS_URL = "${MAIN_URL}staff/cess/fetch_tasks.php";

  // Fetch Cess Application View
  static const String CESSAPPVIEW_URL = "${MAIN_URL}staff/cess/application_view.php";

  // Approve Cess Application
  static const String CESSAPPROVE_URL = "${MAIN_URL}staff/cess/approve_application.php";

  // Data Security Key
  static const String SEC_KEY = "SGFzc2FuYWx5TW9tYmFzYUNvdW50eWVTZXJ2aWNlc0FuZHJvaWQ=";

  /*************************** CHECK PERMISSIONS **************************************/
  static const String PERMISSION_URL = "${MAIN_URL}staff/checkAppPermission.php";

  /**************************  OFFLOADING SECTION ***********************************/
  static const String OFFLOADING_URL = "${MAIN_URL}cess/V2/";


/**************************  PARKING SECTION ***********************************/
  static const String PARKING_URL = "${MAIN_URL}staff/parking/check_status.php";

  static String PARKING_ZONES = "${MAIN_URL}/parking/fetchZones.php";
  static String VEHICLE_CATEGORIES = "${MAIN_URL}/parking/fetch_categories.php";


  /// clamp vehicle
  static String CLAMP_VEHICLE = "${MAIN_URL}/staff/parking/clamp_vehicle.php";

}
