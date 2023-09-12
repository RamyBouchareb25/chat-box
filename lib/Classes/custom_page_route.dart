import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  CustomPageRoute({required this.child, required this.axis})
      : super(pageBuilder: (context, animation, secondaryAnimation) => child);
  final Widget child;
  final AxisDirection axis;
  Offset _offset(AxisDirection axis) {
    switch (axis) {
      case AxisDirection.up:
        return const Offset(0, -1);
      case AxisDirection.down:
        return const Offset(0, 1);
      case AxisDirection.left:
        return const Offset(-1, 0);
      case AxisDirection.right:
        return const Offset(1, 0);
    }
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      SlideTransition(
          position: Tween<Offset>(
            begin: _offset(axis),
            end: Offset.zero,
          ).animate(animation),
          child: child);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
}
