import "package:flutter/material.dart";
import "dart:async";

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, "/selection_page");
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/clouds.png"), fit: BoxFit.fill)
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 100,),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.blue[400],
                  child: const Image(
                    image: AssetImage("assets/logo-anm.png"),
                  ),
                ),
              ),
              const SizedBox(height: 180, width: 0),
              const Center(
                child: Text(
                  "Radar Meteo",
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ],
          ),
        )
      )
    );
  }
}
