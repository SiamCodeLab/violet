import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/theme/theme_color.dart';

class SInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final bool isSuffixIcon;
  final TextInputType keyboardType;
  const SInputField({
    this.controller,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    this.isSuffixIcon = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    RxBool isObscureText = false.obs;
    bool isAndroid = Theme.of(context).platform == TargetPlatform.android;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(ThemeColor.borderColor)),
      ),
      child: Obx(() {
        return Row(
          children: [
            SizedBox(
              width: isAndroid ? 80 : 150,
              child: Text(
                labelText,
                style: TextStyle(
                  color: Color(ThemeColor.hintColor),
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: Color(ThemeColor.hintColor),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: isObscureText.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: hintText,
                  hintStyle: TextStyle(color: Color(ThemeColor.hintColor)),
                ),
              ),
            ),
            if (isSuffixIcon)
              GestureDetector(
                onTap: () {
                  isObscureText.value = !isObscureText.value;
                },
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
