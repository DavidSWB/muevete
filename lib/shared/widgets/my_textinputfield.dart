import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class MyTextinputfield extends StatefulWidget {
  const MyTextinputfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.labelText,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  State<MyTextinputfield> createState() => _MyTextinputfieldState();
}

class _MyTextinputfieldState extends State<MyTextinputfield> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText ? _isObscured : false,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        readOnly: widget.readOnly,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText ?? widget.hintText,
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: AppColors.textMuted, size: 20)
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  onPressed: () {
                    setState(() => _isObscured = !_isObscured);
                  },
                  tooltip: _isObscured
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  icon: Icon(
                    _isObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                )
              : null,
          filled: true,
          fillColor: widget.readOnly ? AppColors.softGrey : AppColors.surface,
        ),
      ),
    );
  }
}
