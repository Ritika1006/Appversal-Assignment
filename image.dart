import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> images;
  const ImageCarousel({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(height: 220, color: Colors.grey[200], child: Center(child: Text('No images')));
    }
    return CarouselSlider(
      items: images.map((url) => Container(
        width: double.infinity,
        child: Image.network(url, fit: BoxFit.cover),
      )).toList(),
      options: CarouselOptions(height: 220, viewportFraction: 1.0, enableInfiniteScroll: false),
    );
  }
}
