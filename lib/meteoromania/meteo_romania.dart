import "package:http/http.dart";
import "dart:convert";
import "package:radar_meteo/meteoromania/radar_image.dart";

class MeteoRomania {
  static const String _infoApi = "https://www.meteoromania.ro/wp-content/plugins/meteo/json/imagini-radar.php";


  static Future<List<RadarImage>> getRadarImages() async {
    var images = List<RadarImage>.empty(growable: true);
    var response = await get(Uri.parse(_infoApi));
    Map receivedImages = jsonDecode(response.body)["poze"];

    print(receivedImages);

    receivedImages.values.toList().reversed.forEach((element) {
      images.add(RadarImage(url: element["poza"], time: element["timp"]));
    });

    return images;
  }

  static DateTime _stringToDateTime(String dtString) {
    String date = dtString.split(" ")[0];
    String time = dtString.split(" ")[1];
    int day = int.parse(date.split("-")[0]);
    int month = int.parse(date.split("-")[1]);
    int year = int.parse(date.split("-")[2]);
    int hour = int.parse(time.split(":")[0]);
    int minute = int.parse(time.split(":")[1]);

    return DateTime(year, month, day, hour, minute);
  }
}
