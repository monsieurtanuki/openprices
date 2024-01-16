import 'package:flutter/material.dart';

String? formatDate(final DateTime? dateTime) =>
    dateTime?.toString().substring(0, 10);

const double smallSpace = 8.0;
const double largeSpace = 16.0;

/// Buttons & TextFields
const Radius circularRadius = Radius.circular(40.0);
//ignore: non_constant_identifier_names
const BorderRadius circularBorderRadius = BorderRadius.all(circularRadius);

InputDecoration getDecoration({
  required final String hintText,
  required final Icon prefixIcon,
  final Widget? suffixIcon,
}) =>
    InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: largeSpace,
        vertical: smallSpace,
      ),
      prefixIcon: prefixIcon,
      filled: true,
      hintText: hintText,
      hintMaxLines: 2,
      border: const OutlineInputBorder(
        borderRadius: circularBorderRadius,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: circularBorderRadius,
        borderSide: BorderSide(
          color: Colors.transparent,
          width: 5.0,
        ),
      ),
      suffixIcon: suffixIcon,
      errorMaxLines: 2,
    );
