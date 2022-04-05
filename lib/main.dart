import 'package:flutter/material.dart';
import 'package:radar_meteo/pages/radar_page.dart';
import 'package:radar_meteo/pages/selection_page.dart';
import "package:radar_meteo/pages/splash_page.dart";


void main() {
  runApp(MaterialApp(
      initialRoute: "/splash_page",
    routes: {
        "/splash_page": (ctx) => const SplashPage(),
        "/selection_page": (ctx) => const SelectionPage(),
        "/radar_page": (ctx) => const RadarPage(),
    },
  ));
}