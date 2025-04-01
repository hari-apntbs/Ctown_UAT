import 'package:flutter/material.dart';

class GiphySplashScreen extends StatefulWidget {
  // const GiphySplashScreen({Key? key}) : super(key: key);

  @override
  _GiphySplashScreenState createState() => _GiphySplashScreenState();
}

class _GiphySplashScreenState extends State<GiphySplashScreen> {
  // GifController controller = GifController(vsync: this);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: ClipRRect(
          child: Center(
            child: Image.asset(
              "assets/images/logo.png",
              height: 300.0,
              width: 300.0,
            ),
          ),
        ));
  }
}
