import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DraggableFab extends StatefulWidget {
  final String targetRoute;
  final Map<String, dynamic>? arguments;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool noNavigation;

  const DraggableFab({
    Key? key,
    required this.targetRoute,
    this.arguments,
    this.icon = Icons.add,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
    this.noNavigation = false
  }) : super(key: key);

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {},
      child: FloatingActionButton(
        heroTag: widget.targetRoute,
        backgroundColor: widget.backgroundColor,
        onPressed: () {
          if(!widget.noNavigation) {
            Get.offNamed(widget.targetRoute, arguments: widget.arguments);
          }
        },
        child: Icon(widget.icon, color: widget.iconColor),
      ),
    );
  }
}