import 'package:flutter/material.dart';

class SInputField extends StatelessWidget {
  bool isSuffixIcon;
  SInputField({
    this.isSuffixIcon = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Text('Username', style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            ),
          ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.grey,
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter your username',
                hintStyle: TextStyle(
                  color: Colors.grey,
                )
              ),
            ),
          ),
          if (isSuffixIcon)
            Icon(
              Icons.remove_red_eye,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }
}