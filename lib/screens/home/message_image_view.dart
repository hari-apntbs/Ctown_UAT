import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final image;
  const ImageView({Key? key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
            margin: const EdgeInsets.only(top: 20),
            child: Image.network(image)));
  }
}
