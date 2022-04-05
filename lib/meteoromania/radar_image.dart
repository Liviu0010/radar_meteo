import "package:cached_network_image/cached_network_image.dart";

class RadarImage {
  String url;
  String time;
  late CachedNetworkImageProvider image;
  Function(RadarImage)? onError;
  ///Used for fixing the URL when the image is posted too late
  bool minuteSubtracted = false;
  ///Used for fixing the URL when the image is posted too late
  bool minuteAdded = false;

  RadarImage({required this.url, required this.time, this.onError}) {
    initializeImageProvider();
  }

  initializeImageProvider() {
    //sometimes the radar images seem to be posted 1 minute earlier or later
    //attempting to fix that
    image = CachedNetworkImageProvider(url, errorListener: () {
      onError?.call(this);
    });
  }
}