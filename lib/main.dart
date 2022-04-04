import 'package:flutter/material.dart';
import 'package:radar_meteo/pages/radar_page.dart';
import 'package:radar_meteo/pages/selection_page.dart';


void main() {
  runApp(MaterialApp(
      initialRoute: "/selection_page",
    routes: {
        "/selection_page": (ctx) => const SelectionPage(),
        "/radar_page": (ctx) => const RadarPage(),
    },
  ));
}
