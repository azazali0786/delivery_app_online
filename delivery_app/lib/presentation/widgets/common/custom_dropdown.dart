import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const CustomDropdown({
    Key? key,
    required this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// SMALLER LABEL
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,          // from 14 → 12
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6), // from 8 → 6

        /// SMALLER DROPDOWN
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,

          style: const TextStyle(
            fontSize: 13,          // dropdown text smaller
            color: AppColors.textPrimary,
          ),

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12),

            filled: true,
            fillColor: Colors.white,

            /// Smaller radius
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), // from 12 → 8
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),

            /// Smaller padding (reduces height)
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,      // from 16 → 12
              vertical: 10,        // from 16 → 10
            ),
          ),

          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,              // from 24 → 18
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
        ),
      ],
    );
  }
}
