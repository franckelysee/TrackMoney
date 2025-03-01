import 'package:flutter/material.dart';

class CustomDropdownButtonFormField extends StatefulWidget {
  final List<String> items;
  final String? hint;
  final String? initialValue;
  final void Function(String?) onChanged;
  final String? errorText;
  final bool isRequired;

  const CustomDropdownButtonFormField({
    super.key,
    required this.items,
    this.hint,
    this.initialValue,
    required this.onChanged,
    this.errorText,
    this.isRequired = false,
  });

  @override
  State<CustomDropdownButtonFormField> createState() =>
      _CustomDropdownButtonFormFieldState();
}

class _CustomDropdownButtonFormFieldState
    extends State<CustomDropdownButtonFormField> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant CustomDropdownButtonFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        selectedValue = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: DropdownButtonFormField<String>(
        validator: (value) {
          if (widget.isRequired && (value == null || value.isEmpty)) {
            return widget.errorText ?? "Ce champ est obligatoire";
          }
          return null;
        },
        value: selectedValue,
        decoration: InputDecoration(
          hintText: widget.hint,
          filled: true, // Activer le fond
          fillColor: Theme.of(context).cardColor, // Couleur du fond
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        hint: Text(
          widget.hint ?? "Sélectionnez une option",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12),
        ),
        items: widget.items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
          widget.onChanged(value);
        },
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const CustomTextFormField(
      {super.key,
      this.labelText,
      this.hintText,
      this.prefixIcon,
      this.suffixIcon,
      this.isPassword = false,
      this.controller,
      this.validator,
      this.keyboardType = TextInputType.text,
      this.onFieldSubmitted,
      this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 12),
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon ?? suffixIcon,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
