var this_year = DateTime.now().year.toString();

class AppConfig {
  static String copyright_text =
      '@ nailgo.ae ' + this_year; //this shows in the splash screen
  static String app_name = 'Okaymart'; //this shows in the splash screen
  static String purchase_code = 'ec669dad-9136-439d-b8f4-80298e7e6f37';
  static String tempPurchaseCode =
      'ec669dad-9136-439d-b8f4-80298e7e6f37'; //enter your purchase code for the app from codecanyon

  //configure this
  static const bool HTTPS = true;
// https://nimnew.way2camera.com/
  //configure this

  // static const DOMAIN_PATH = 'www.parrotrip.com/okaymart'; //localhost
  static const DOMAIN_PATH = 'nailgo.ae'; //localhost

  //do not configure these below
  static const String API_ENDPATH = 'api/v2';
  static const String PUBLIC_FOLDER = 'public';
  static const String PROTOCOL = HTTPS ? 'https://' : 'http://';
  static const String RAW_BASE_URL = '$PROTOCOL$DOMAIN_PATH';
  static const String BASE_URL = '$RAW_BASE_URL/$API_ENDPATH';

  //configure this if you are using amazon s3 like services
  //give direct link to file like https://[[bucketname]].s3.ap-southeast-1.amazonaws.com/
  //otherwise do not change anything
  static const String BASE_PATH = '$RAW_BASE_URL/$PUBLIC_FOLDER/';
  static const String IMAGE_PATH = 'uploads/all/';
  static const String IMAGE_BASE_PATH = '$BASE_PATH' + IMAGE_PATH;
  //static const String BASE_PATH = "https://tosoviti.s3.ap-southeast-2.amazonaws.com/";
}
