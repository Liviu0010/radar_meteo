import 'package:flutter/material.dart';
import 'package:radar_meteo/meteoromania/meteo_romania.dart';
import "package:radar_meteo/utils.dart";

class SelectionPage extends StatefulWidget {
  const SelectionPage({Key? key}) : super(key: key);

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  int start = 0;
  int end = 0;
  List<String> urls = List<String>.empty(growable: true);

  void initInterval() async {
    endDate = await MeteoRomania.latestImageTime();
    startDate = endDate.subtract(const Duration(hours: MeteoRomania.maximumHourDifference));
  }

  String niceLabel(DateTime dt) {
    String result = "";
    if(dt.day == DateTime.now().subtract(const Duration(days: 1)).day) {
      result = "Ieri ";
    }
    else {
      result = "Azi ";
    }

    result += "${Utils.representNumber(dt.hour)}:${Utils.representNumber(dt.minute)}";

    return result;
  }

  @override
  void initState() {
    super.initState();
    initInterval();
  }

  @override
  Widget build(BuildContext context) {
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
                  niceLabel(MeteoRomania.urlToDateTime(urls[start])),
                  niceLabel(MeteoRomania.urlToDateTime(urls[end]))
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
