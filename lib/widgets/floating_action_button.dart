import 'package:flutter/material.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  FloatingActionButtonWidget({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      elevation: 3,
      child: Icon(
        icon,
        color: const Color(0xFF093879),
      ),
    );
  }
}
