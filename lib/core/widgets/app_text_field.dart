import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lengoal/core/utils/haptics.dart';

class AppTextField extends StatefulWidget {
  const new({
    required this.controller,
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.suffixIcon,
    this.autofillHints,
    this.onChanged,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.inputFormatters,
  }) : assert(
         !(isPassword && suffixIcon != null),
         'isPassword renders its own visibility toggle — pass '
         'either isPassword or suffixIcon, not both.',
       );

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final bool isPassword;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.isPassword;

  static final RegExp _emailAllowedChars = RegExp('[a-zA-Z0-9@._+-]');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: Theme.of(context).textTheme.bodyMedium),
          const Gap(8),
        ],
        FormField<String>(
          initialValue: widget.controller.text,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: widget.controller,
                  obscureText: widget.isPassword && _obscured,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  readOnly: widget.readOnly,
                  enabled: widget.enabled,
                  onTap: widget.onTap,
                  inputFormatters:
                      widget.inputFormatters ??
                      (widget.keyboardType == TextInputType.emailAddress
                          ? [
                              FilteringTextInputFormatter.allow(
                                _emailAllowedChars,
                              ),
                            ]
                          : null),
                  onChanged: (value) {
                    field.didChange(value);
                    widget.onChanged?.call(value);
                  },
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    errorText: field.hasError ? '' : null,
                    errorStyle: const TextStyle(fontSize: 0, height: 0.01),
                    suffixIcon: widget.isPassword
                        ? _visibilityToggle(widget.enabled)
                        : widget.suffixIcon,
                  ),
                ),
                if (field.hasError) ...[
                  const Gap(10),
                  Text(
                    field.errorText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else if (widget.helperText != null) ...[
                  const Gap(6),
                  Text(
                    widget.helperText!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _visibilityToggle(bool enabled) {
    return IconButton(
      icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
      onPressed: enabled
          ? () {
              AppHaptics.selection();
              setState(() => _obscured = !_obscured);
            }
          : null,
    );
  }
}
