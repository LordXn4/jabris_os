import 'package:flutter/material.dart';
class OdasCore extends StatelessWidget {
  const OdasCore({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.cyanAccent.withValues(alpha: 0.15),
        border: Border.all(
          color: Colors.cyanAccent,
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.cyanAccent,
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.memory,
          color: Colors.cyanAccent,
          size: 80,
        ),
      ),
    );
  }
}
