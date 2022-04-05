import "package:cached_network_image/cached_network_image.dart";

class RadarImage {
  String url;
  String time;
  late CachedNetworkImageProvider image;

  RadarImage({required this.url, required this.time}) {
    image = CachedNetworkImageProvider(url);
  }
}