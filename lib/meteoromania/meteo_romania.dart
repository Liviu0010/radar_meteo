import "package:http/http.dart";
import "dart:convert";
import "package:radar_meteo/meteoromania/radar_image.dart";
import "package:radar_meteo/utils.dart";

class MeteoRomania {
  static const String _infoApi = "https://www.meteoromania.ro/wp-content/plugins/meteo/json/imagini-radar.php";
  static const int maximumHourDifference = 38;  //how many hours back the radar images are available

  static Future<Map> latestImagesJson() async {
    var response = await get(Uri.parse(_infoApi));

    return jsonDecode(response.body)["poze"];
  }

  static Future<List<RadarImage>> getRadarImages() async {
    var images = List<RadarImage>.empty(growable: true);
    Map receivedImages = await latestImagesJson();
    receivedImages.values.toList().reversed.forEach((element) {
      images.add(RadarImage(url: element["poza"], time: element["timp"]));
    });

    return images;
  }

  static List<RadarImage> getRadarImagesFromList(List<String> urls, {Function(RadarImage)? errorCallback}) {
    var images = List<RadarImage>.empty(growable: true);
    urls.forEach((element) {
      images.add(RadarImage(url: element, time: Utils.representDateTime(MeteoRomania.urlToDateTime(element)),
                              onError: (radarImage) {
                                errorCallback?.call(radarImage);
                              }));
    });

    return images;
  }

  ///Gets the "timp" field of the latest image from the JSON.
   static Future<DateTime> latestImageTime() async {
    Map imageList = await latestImagesJson();
    Map last = imageList.values.elementAt(0);
    return _stringToDateTime(last["timp"]);
   }

   /// Turns the "timp" field of the JSON response into a DateTime object
  static DateTime _stringToDateTime(String dtString) {
    String date = dtString.split(" ")[0];
    String time = dtString.split(" ")[2];
    int day = int.parse(date.split("-")[0]);
    int month = int.parse(date.split("-")[1]);
    int year = int.parse(date.split("-")[2]);
    int hour = int.parse(time.split(":")[0]);
    int minute = int.parse(time.split(":")[1]);

    return DateTime(year, month, day, hour, minute);
  }

  static String _dateTimeToUrl(DateTime dt) {
    String base = "https://www.meteoromania.ro/radar/mos.live.";
    String image = "";

    dt = dt.toUtc();

    image += Utils.representNumber(dt.year) + Utils.representNumber(dt.month) + Utils.representNumber(dt.day) + ".";
    image += Utils.representNumber(dt.hour) + Utils.representNumber(dt.minute) + ".0_mercator.png";

    return base+image;
  }

  static String subtractMinutesFromUrlTime(String imageUrl, {int minutesToSubtract = 1}) {
    DateTime dt = urlToDateTime(imageUrl);
    return _dateTimeToUrl(dt.subtract(Duration(minutes: minutesToSubtract)));
  }

  ///Turns the URL string to a radar image file into a DateTime object of LocalTime.
  static DateTime urlToDateTime(String url) {
    int start = url.indexOf("/mos.live.") + 10;
    String dateTime = url.substring(start, start+13);
    String date = dateTime.split(".")[0];
    String time = dateTime.split(".")[1];
    int year = int.parse(date.substring(0, 4));
    int month = int.parse(date.substring(4, 6));
    int day = int.parse(date.substring(6,8));
    int hour = int.parse(time.substring(0, 2));
    int minute = int.parse(time.substring(2, 4));

    return DateTime.utc(year, month, day, hour, minute).toLocal();
  }

  static List<String> getUrlsInInterval(DateTime start, DateTime end) {
    var list = List<String>.empty(growable: true);

    for(DateTime i = start; i.isBefore(end); i = i.add(const Duration(minutes: 10))) {
      list.add(_dateTimeToUrl(i));
    }

    list.add(_dateTimeToUrl(end));

    return list;
  }
}
