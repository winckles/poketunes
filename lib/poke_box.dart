import 'package:flutter/material.dart';

class PokeBox extends StatelessWidget {
  final Widget child;
  final double padHor;
  final double padVer;
  PokeBox({this.child, this.padHor, this.padVer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padHor, vertical: padVer),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 2,
                  color: Color(0xff2A75BB),
                ),
                color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
