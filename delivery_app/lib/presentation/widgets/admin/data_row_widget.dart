// widgets/data_row_widget.dart
import 'package:flutter/material.dart';

class DataRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const DataRowWidget({
    Key? key,
    required this.label,
    required this.value,
    required this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}