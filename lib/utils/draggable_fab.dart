import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DraggableFab extends StatefulWidget {
  final String targetRoute;
  final Map<String, dynamic>? arguments;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const DraggableFab({
    Key? key,
    required this.targetRoute,
    this.arguments,
    this.icon = Icons.add,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  // Initial position of the FAB
  double _x = 20.0;
  double _y = 20.0;

  // Screen dimensions
  late double _screenWidth;
  late double _screenHeight;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: _x,
      bottom: _y,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // Update position based on drag
            _x = (_x + details.delta.dx).clamp(0, _screenWidth - 56);
            _y = (_y - details.delta.dy).clamp(0, _screenHeight - 56);
          });
        },
        child: FloatingActionButton(
          heroTag: widget.targetRoute, // Unique tag for each FAB
          backgroundColor: widget.backgroundColor,
          onPressed: () {
            // Navigate to the target route with optional arguments
            // Using offNamed instead of toNamed to replace the current screen in the navigation stack
            Get.offNamed(widget.targetRoute, arguments: widget.arguments);
          },
          child: Icon(widget.icon, color: widget.iconColor),
        ),
      ),
    );
  }
}