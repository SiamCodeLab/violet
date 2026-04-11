import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/theme/theme_color.dart';

/// A styled input field used across the application for form inputs.
///
/// Supports plain text fields and password fields with toggle visibility.
/// When [isSuffixIcon] is true, the field is treated as a password field
/// and text is obscured by default.
class SInputField extends StatelessWidget {
  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Label displayed on the left side of the field.
  final String labelText;

  /// Placeholder text shown when the field is empty.
  final String hintText;

  /// When true, renders a visibility toggle icon and obscures text by default.
  final bool isSuffixIcon;

  /// Explicitly forces text to be obscured regardless of [isSuffixIcon].
  final bool obscureText;

  /// The type of keyboard to display for this field.
  final TextInputType keyboardType;

  /// Called when the user submits the field via the keyboard action button.
  final ValueChanged<String>? onSubmitted;

  const SInputField({
    this.controller,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    this.isSuffixIcon = false,
    this.obscureText = false,
    this.onSubmitted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Password fields start obscured; toggled by the visibility icon.
    final RxBool isObscureText = (isSuffixIcon || obscureText).obs;

    final bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final bool isIos = Theme.of(context).platform == TargetPlatform.iOS;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(ThemeColor.borderColor)),
      ),
      child: Obx(() {
        return Row(
          children: [
            // Field label — width adapts to platform
            SizedBox(
              width: isAndroid || isIos ? 80 : 150,
              child: Text(
                labelText,
                style: TextStyle(
                  color: Color(ThemeColor.hintColor),
                  fontSize: 16,
                ),
              ),
            ),

            // Vertical divider separating label from input
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: Color(ThemeColor.hintColor),
            ),

            // Main text input
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: isObscureText.value,
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: hintText,
                  hintStyle: TextStyle(color: Color(ThemeColor.hintColor)),
                ),
              ),
            ),

            // Visibility toggle — only rendered for password fields
            if (isSuffixIcon)
              GestureDetector(
                onTap: () => isObscureText.value = !isObscureText.value,
                child: Icon(
                  isObscureText.value ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
              ),
          ],
        );
      }),
    );
  }
}