import 'package:flutter/material.dart';

class NavMenu {
  final String label;
  final IconData icon;
  final void Function() onTap;

  NavMenu({required this.label, required this.icon, required this.onTap});
}
