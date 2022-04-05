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

  void initLatestImageTime() async {
    latestImageTime = await MeteoRomania.latestImageTime();
    setState(() {});
  }

  DateTime guessLatestRadarImageTime() {
    DateTime now = DateTime.now().subtract(const Duration(minutes: 10));
    return DateTime(now.year, now.month, now.day, now.hour, (now.minute/10).floor()*10+1);
  }

  @override
  void initState() {
    super.initState();
    endDate = guessLatestRadarImageTime();
    startDate = endDate.subtract(const Duration(hours: MeteoRomania.maximumHourDifference));
  }

  @override
  Widget build(BuildContext context) {
    if(latestImageTime == null) {
      initLatestImageTime();
    }
    endDate = latestImageTime ?? guessLatestRadarImageTime();
    startDate = endDate.subtract(const Duration(hours: MeteoRomania.maximumHourDifference));
    urls = MeteoRomania.getUrlsInInterval(startDate, endDate);
    return Scaffold(
      body: Container(
        color: Colors.blue[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:  [
            const Center(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 50, horizontal: 0),
                  child: Text(
                    "Intervalul de timp pentru imaginile radar",
                    style: TextStyle(
                     fontSize: 20
                    ),
                  ),
                ),
              ),
            ),
            RangeSlider(
                min: 0,
                max: urls.isEmpty ? 0 : urls.length-1,
                divisions: urls.length,
                values: RangeValues(start.toDouble(), end.toDouble()),
                onChanged: (newValues) {
                  setState(() {
                    start = newValues.start.round();
                    end = newValues.end.round();
                  });
                },
                labels: RangeLabels(
                  Utils.dayFromToday(MeteoRomania.urlToDateTime(urls[start]), includeTime: true),
                  Utils.dayFromToday(MeteoRomania.urlToDateTime(urls[end]), includeTime: true)
                ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/radar_page", arguments: {
                    "urls": urls.sublist(start, end+1)
                  });
                },
                child: const Text("Afișează"))
          ]
        ),
      )
    );
  }
}
