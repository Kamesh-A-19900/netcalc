import 'package:flutter/material.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final bool reverseLayout;

  const SectionWidget({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.reverseLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Widget textColumn = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 15),
          Text(description, style: TextStyle(fontSize: 16, color: Colors.white70)),
        ],
      ),
    );

    Widget imageColumn = Expanded(
      child: Image.asset(imageUrl, height: 250, fit: BoxFit.contain),
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 50),
      color: Colors.blueGrey[900],
      child: screenWidth > 900
          ? Row(
              children: reverseLayout
                  ? [imageColumn, SizedBox(width: 30), textColumn]
                  : [textColumn, SizedBox(width: 30), imageColumn],
            )
          : Column(
              children: [
                imageColumn,
                SizedBox(height: 30),
                textColumn,
              ],
            ),
    );
  }
}
