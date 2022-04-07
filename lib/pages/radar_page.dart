import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import 'package:radar_meteo/meteoromania/meteo_romania.dart';
import 'package:radar_meteo/meteoromania/radar_image.dart';
import "package:scrollable_positioned_list/scrollable_positioned_list.dart";
import "dart:async";
import 'package:cached_network_image/cached_network_image.dart';
import "package:radar_meteo/cached_tile_provider.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart";
import "package:radar_meteo/utils.dart";

class RadarPage extends StatefulWidget {
  const RadarPage({Key? key}) : super(key: key);

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  List<RadarImage> imageList = List<RadarImage>.empty(growable: true);
  int imageIndex = 0;
  ItemScrollController scrollController = ItemScrollController();
  Timer? playTimer;
  bool playing = false;
  bool urlErrors = false;

  void getImageList() {
    var argMap = ModalRoute.of(context)?.settings.arguments as Map;
    List<String> urls = argMap["urls"];

    if(imageList.isEmpty) {
      imageList = MeteoRomania.getRadarImagesFromList(urls, errorCallback: (radarImage) async {
        //sometimes the radar images seem to be posted 1 minute earlier or later
        //attempting to fix that
        DefaultCacheManager().removeFile(radarImage.url);
        urlErrors = true;
        if(!radarImage.minuteSubtracted) {
          radarImage.url = MeteoRomania.subtractMinutesFromUrlTime(radarImage.url);
          radarImage.initializeImageProvider();
          radarImage.minuteSubtracted = true;
        }
        else if(!radarImage.minuteAdded) {
          radarImage.url = MeteoRomania.subtractMinutesFromUrlTime(radarImage.url, minutesToSubtract: -2);
          radarImage.initializeImageProvider();
          radarImage.minuteAdded = true;
        }
        radarImage.time = Utils.representDateTime(MeteoRomania.urlToDateTime(radarImage.url));
        setState(() {});
      });
    }

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getImageList();
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(playTimer != null && playTimer!.isActive) {
            playTimer!.cancel();
          }

          Navigator.pop(context, {
            "urlErrors": urlErrors
          });
        },
        mini: true,
        child: const Icon(Icons.arrow_back),

      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    imageIndex = imageIndex == 0 ? 0 : imageIndex - 1;
                    scrollController.scrollTo(index: imageIndex == 0 ? 0 : imageIndex-1, duration: const Duration(milliseconds: 200));
                  });
                },
                icon: const Icon(Icons.fast_rewind)
            ),
            IconButton(
                onPressed: () {
                  if(!playing) {
                    setState(() {
                      playing = true;
                    });
                    playTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                      setState(() {
                        imageIndex = imageIndex == imageList.length - 1 ? 0 : imageIndex + 1;
                        scrollController.scrollTo(
                            index: imageIndex == 0 ? 0 : imageIndex-1,
                            duration: const Duration(milliseconds: 200));
                      });
                    });
                  }
                  else {
                    setState(() {
                      playing = false;
                      playTimer?.cancel();
                    });
                  }
                },
                icon: playing? const Icon(Icons.pause) : const Icon(Icons.play_arrow)
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    imageIndex = imageIndex == imageList.length - 1 ? imageIndex : imageIndex + 1;
                    scrollController.scrollTo(index: imageIndex == 0 ? 0 : imageIndex-1, duration: const Duration(milliseconds: 200));
                  });
                },
                icon: const Icon(Icons.fast_forward)
            )
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, {
            "urlErrors": urlErrors
          });
          return false;
        },
        child: SafeArea(
          child: Column(
            children: [
              Flexible(
                flex: 9,
                child: FlutterMap(
                  options: MapOptions(
                      center: LatLng(45, 25),
                      zoom: 6.0,
                      minZoom: 6,
                      nePanBoundary: LatLng(50, 30),
                      swPanBoundary: LatLng(40, 20),
                      slideOnBoundaries: true,
                      interactiveFlags: InteractiveFlag.drag | InteractiveFlag.flingAnimation | InteractiveFlag.pinchMove | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      tileProvider: CachedTileProvider(),
                      attributionBuilder: (_) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const <Widget>[
                            Text("© OpenStreetMap contributors"),
                            Image(image: AssetImage("assets/logo-anm.png"),width: 170,)
                          ],
                        );
                      },
                    ),
                    OverlayImageLayerOptions(overlayImages: [
                      OverlayImage(
                          imageProvider: imageList.isNotEmpty ? imageList[imageIndex].image : const CachedNetworkImageProvider(""),
                          bounds: LatLngBounds(
                              LatLng(42.00767893522453, 17.972678603012373),
                              LatLng(49.162878895590495, 31.476678571902717)),
                          opacity: 0.55,
                          gaplessPlayback: true
                      )
                    ])
                  ],
                ),
              ),
              Flexible(
                  flex: 3,
                  child: Scrollbar(
                    child: ScrollablePositionedList.builder(
                      minCacheExtent: 40,
                      itemCount: imageList.length,
                      itemScrollController: scrollController,
                      itemBuilder: (buildContext, index) {
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                imageList.isEmpty ? "" : imageList[index].time,
                              ),
                            ],
                          ),
                          tileColor: index == imageIndex ? Colors.blue : Colors.transparent,
                          onTap: () {
                            setState(() {
                              imageIndex = index;
                            });
                          },
                        );
                      },

                    ),
                  )),
              //may add more children
            ],
          ),
        ),
      ),
    );
  }
}
