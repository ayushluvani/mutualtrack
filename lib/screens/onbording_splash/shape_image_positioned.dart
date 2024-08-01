import 'package:flutter/cupertino.dart';

class ShapeImagePositioned extends StatelessWidget {
  const ShapeImagePositioned({Key? key, this.top = -50}) : super(key: key);
  final double top;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 50,
      top: 100,
      child: Container(
        width: MediaQuery.of(context).size.width - 100,
        height: 300,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/onbording_screen_img/mutualtrackicon.png'), fit: BoxFit.cover),
        ),
      ),
    );
  }
}
