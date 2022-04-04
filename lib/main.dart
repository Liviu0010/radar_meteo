import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import 'package:radar_meteo/meteoromania/meteo_romania.dart';
import 'package:radar_meteo/meteoromania/radar_image.dart';
import "package:scrollable_positioned_list/scrollable_positioned_list.dart";
import "dart:async";

void main() {
  runApp(const MaterialApp(home: Radar()));
}

class Radar extends StatefulWidget {
  const Radar({Key? key}) : super(key: key);

  @override
  State<Radar> createState() => _RadarState();
}

class _RadarState extends State<Radar> {
  List<RadarImage> imageList = List<RadarImage>.empty(growable: true);
  int imageIndex = 0;
  ItemScrollController scrollController = ItemScrollController();
  Timer? playTimer;
  bool playing = false;

  void getImageList() async {
    imageList = await MeteoRomania.getRadarImages();
    imageList.forEach((element) {print(element.time);});

    setState(() {
      imageIndex = imageList.length-1;
    });
  }

  @override
  void initState() {
    super.initState();
    getImageList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
                  if(playTimer == null) {
                    setState(() {
                      playing = true;
                    });
                      playTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
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
                      playTimer = null;
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
      body: SafeArea(
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
    );
  }
}
