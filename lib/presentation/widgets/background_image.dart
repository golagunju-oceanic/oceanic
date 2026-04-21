import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          // colorFilter: ColorFilter.mode(
          //   const Color.fromARGB(255, 135, 129, 129).withOpacity(0.4),
          //   BlendMode.srcOver,
          // ),
          image: AssetImage('assets/images/bg_img.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
