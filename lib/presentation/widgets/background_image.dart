import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            theme == Brightness.dark
                ? 'assets/images/bg_img_dark.png'
                : 'assets/images/bg_img.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
