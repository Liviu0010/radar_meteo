import 'package:flutter/material.dart';
import 'package:radar_meteo/meteoromania/meteo_romania.dart';
import "package:radar_meteo/utils.dart";

class SelectionPage extends StatefulWidget {
  const SelectionPage({Key? key}) : super(key: key);

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  DateTime? latestImageTime;
  late DateTime startDate;
  late DateTime endDate;
  int start = 0;
  int end = 0;
  List<String> urls = List<String>.empty(growable: true);
  Future<List<String>>? listFuture;

  void initLatestImageTime() async {
    latestImageTime = await MeteoRomania.latestImageTime();
    setState(() {});
  }

  DateTime guessLatestRadarImageTime() {
    DateTime now = DateTime.now().subtract(const Duration(minutes: 10));
    return DateTime(now.year, now.month, now.day, now.hour,
        (now.minute / 10).floor() * 10 + 1);
  }

  @override
  void initState() {
    super.initState();
    endDate = guessLatestRadarImageTime();
    startDate = endDate
        .subtract(const Duration(hours: MeteoRomania.maximumHourDifference));
  }

  @override
  Widget build(BuildContext context) {
    bool urlsWasEmpty = urls.isEmpty;
    if (latestImageTime == null) {
      initLatestImageTime();
    }
    listFuture ??= Future(() async {
      if (urls.isEmpty) {
        urls = await MeteoRomania.getUrlsInInterval(startDate, endDate);
      }
      return urls;
    });

    return Scaffold(
        body: Container(
      color: Colors.blue[50],
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 50, horizontal: 0),
                  child: Text(
                    "Intervalul de timp pentru imaginile radar",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
            FutureBuilder(
                future: listFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
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
                    return Text("Obținere date...");
                  }
                }),
            ElevatedButton(
                onPressed: () async {
                 var result = await Navigator.pushNamed(context, "/radar_page",
                                arguments: {"urls": urls.sublist(start, end + 1)}) as Map<String, dynamic>;
                 if(result["urlErrors"] as bool) {
                   listFuture = null;
                   urls.clear();
                   setState(() {});
                 }
                },
                child: const Text("Afișează"))
          ]),
    ));
  }
}
