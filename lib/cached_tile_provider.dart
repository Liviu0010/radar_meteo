import "package:cached_network_image/cached_network_image.dart";
import 'package:flutter/src/painting/image_provider.dart';
import 'package:flutter_map/flutter_map.dart';

class CachedTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options)
    );
  }
  
}