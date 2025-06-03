import 'package:flutter/material.dart';

class PrinterModel {
  final String name;
  final String description;
  final String? requirements;
  final IconData icon;
  final bool advanced;

  PrinterModel({
    required this.name,
    required this.description,
    this.requirements,
    required this.icon,
    this.advanced = false,
  });
}
