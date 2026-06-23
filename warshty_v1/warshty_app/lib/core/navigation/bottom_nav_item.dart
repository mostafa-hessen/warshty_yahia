import 'package:flutter/material.dart';

class BottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String routePath;

  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.routePath,
  });
}
