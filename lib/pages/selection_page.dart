import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:radar_meteo/meteoromania/meteo_romania.dart';
import "package:radar_meteo/utils.dart";

class SelectionPage extends StatefulWidget {
  const SelectionPage({Key? key}) : super(key: key);

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  late DateTime startDate;
  late DateTime? endDate;
  int start = 0;
  int end = 0;
  List<String> urls = List<String>.empty(growable: true);
  Future<List<String>>? listFuture;

  DateTime guessLatestRadarImageTime() {
    DateTime now = DateTime.now().subtract(const Duration(minutes: 10));
    return DateTime(now.year, now.month, now.day, now.hour,
        (now.minute / 10).floor() * 10 + 1);
  }

  @override
  Widget build(BuildContext context) {
    bool urlsWasEmpty = urls.isEmpty;
    listFuture ??= Future(() async {
      if (urls.isEmpty) {
        endDate = await MeteoRomania.latestImageTime();
        startDate = endDate!.subtract(const Duration(hours: MeteoRomania.maximumHourDifference));
        urls = await MeteoRomania.getUrlsInInterval(startDate, endDate!);
      }
      return urls;
    });

    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bgclouds.png"),
          fit: BoxFit.fill
        )
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 50, horizontal: 0),
                  child: Text(
                    "Intervalul de timp",
                    style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 0.5,
                      color: Colors.blueGrey[400]
                    ),
                  ),
                ),
              ),
            ),
            FutureBuilder(
                future: listFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if(snapshot.data == null) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Nu s-au putut descărca date ", style: TextStyle(fontSize: 16),),
                          Icon(Icons.error_outline)
                        ],
                      ) ;

                    }

                    urls = snapshot.data as List<String>;
                    start = urlsWasEmpty ? urls.length - 40 : start;
                    end = urlsWasEmpty ? urls.length - 1 : end;
                    return RangeSlider(
                        min: 0,
                        max: urls.isEmpty ? 0 : urls.length - 1,
                        divisions: urls.length,
                        values: RangeValues(start.toDouble(), end.toDouble()),
                        onChanged: (newValues) {
                          setState(() {
                            start = newValues.start.round();
                            end = newValues.end.round();
                          });
                        },
                        labels: RangeLabels(
                            Utils.dayFromToday(
                                MeteoRomania.urlToDateTime(urls[start]),
                                includeTime: true),
                            Utils.dayFromToday(
                                MeteoRomania.urlToDateTime(urls[end]),
                                includeTime: true)));
                  } else {
                    return const SpinKitThreeInOut(color: Colors.blue,);
                  }
                }),
            ElevatedButton(
                onPressed: () async {
                  if(urls.isEmpty) {
                    return;
                  }
                 var result = await Navigator.pushNamed(context, "/radar_page",
                                arguments: {"urls": urls.sublist(start, end + 1)}) as Map<String, dynamic>;
                 if(result["urlErrors"] as bool) {
                   listFuture = null;
                   urls.clear();
                   setState(() {});
                 }
                },
                child: const Text("Afișează")),
            TextButton(
                onPressed: () {
                  setState(() {
                    listFuture = null;
                    urls.clear();
                  });
                },
                child: Text("Reîmprospătează")
            )
          ]),
    ));
  }
}
