import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// LABEL (Smaller)
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,          // Smaller
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6), // Reduced space

        /// TEXT FIELD
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,
          inputFormatters: inputFormatters,

          style: const TextStyle(
            fontSize: 13,          // Smaller input text
            height: 1.2,
          ),

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12),

            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: prefixIcon,
                  )
                : null,

            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: suffixIcon,
                  )
                : null,

            filled: true,
            fillColor: enabled ? Colors.white : AppColors.surfaceLight,

            /// Smaller borders
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), // Smaller radius
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),

            /// Smaller padding (reduces height)
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10, // Reduced from 16 → 10
            ),
          ),
        ),
      ],
    );
  }
}
