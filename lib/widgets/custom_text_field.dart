// lib/widgets/custom_text_field.dart

import 'package:flutter/material.dart'; // Importing necessary Flutter material design components.

// `CustomTextField` is a `StatelessWidget`.
// This widget encapsulates a `TextField` with common styling and properties.
// Creating reusable widgets like this is a core principle of good Flutter design.
// It promotes consistency, reduces code duplication, and makes refactoring easier.

class CustomTextField extends StatelessWidget {
  final TextEditingController
      controller; // `controller`: A `TextEditingController` is used to control the text being edited.
  final String
      labelText; // `labelText`: The label text displayed above or inside the input field.
  final TextInputType
      keyboardType; // `keyboardType`: Specifies the type of keyboard to use (e.g., text, number, email).
  final String? Function(String?)?
      validator; // `validator`: A function that validates the input. It takes the current text
  // and returns a String (error message) if the input is invalid, or null if valid.
  final bool
      obscureText; // `obscureText`: A boolean - text being edited should be obscured (e.g., pwd). default=false.

  const CustomTextField({
    // Constructor for `CustomTextField`. All parameters are required.
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text, // Default keyboard type is `text`.
    this.validator,
    this.obscureText =
        false, // Default value is false, meaning text is visible.
  });

  @override
  Widget build(BuildContext context) {
    // The `build` method describes the UI.
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical:
              8.0), // Adds vertical padding around each text field for better spacing.
      child: TextFormField(
        // Assigns the controller to the `TextFormField`.
        // `TextFormField` is a `TextField` wrapped in a `FormField`.
        // It's typically used in a `Form` widget to provide validation and saving features.
        controller: controller,
        keyboardType: keyboardType, // Sets the keyboard type.
        obscureText:
            obscureText, // Passes the `obscureText` property to `TextFormField`.

        decoration: InputDecoration(
          // `decoration` defines the visual appearance of the input field.
          labelText:
              labelText, // `labelText` displays a label for the input field.
          border: const OutlineInputBorder(
            // `border` adds a visible border around the input field.
            borderSide: BorderSide(
              // By default, the `borderSide` is a thin, light gray line.
              color: Colors.green, // Sets a static green color for the border.
              width: 1.0, // Sets the width of the border.
            ),
          ),

          enabledBorder: const OutlineInputBorder(
            // `enabledBorder` is the border when the field is not focused.
            borderSide: BorderSide(
              // We set it to be the same as the default `border` to ensure it's always visible.
              color: Colors
                  .green, // Ensures the border is green when the field is not active.
              width: 1.0,
            ),
          ),

          focusedBorder: const OutlineInputBorder(
            // `focusedBorder` is the border when the field is focused.
            borderSide: BorderSide(
              color: Colors
                  .green, // Ensures the border remains green when focused.
              width: 2.0, // A slightly thicker line to indicate focus.
            ),
          ),

          contentPadding: const EdgeInsets.all(
              12.0), // `contentPadding` adjusts the internal spacing of the text field.
        ),

        validator: validator, // Assigns the validator function.
      ), // When the `Form` containing this `TextFormField` is validated, this function will be called.
    );
  }
}
