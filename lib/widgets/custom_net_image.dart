import 'package:flutter/material.dart';

class CustomNetImage extends StatefulWidget {

  final String url;
  final String? tag;

  const CustomNetImage({super.key, required this.url, this.tag});

  @override
  _CustomNetImageState createState() => _CustomNetImageState();
}

class _CustomNetImageState extends State<CustomNetImage> {

  @override
  void dispose() {
    NetworkImage(widget.url).evict();
//    debugPrint("Уничтожено:${widget.url}");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.tag ?? widget.url,
      child: FadeInImage.assetNetwork(
        placeholder: "images/icon.png",
        image: widget.url,
      ),
    );
  }
}
