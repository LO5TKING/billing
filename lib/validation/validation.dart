import 'package:flutter/material.dart';

class Validation {
  // Validate shop name
  static String? validateShopName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Shop name is required';
    }
    if (value.length < 3) {
      return 'Shop name must be at least 3 characters';
    }
    return null;
  }

  // Validate person name
  static String? validatePersonName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Person name is required';
    }
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return 'Person name should only contain letters';
    }
    return null;
  }

  // Validate mobile number
  static String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      // Email is optional, so return null if empty
      return null;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Validate confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Validate street
  static String? validateStreet(String? value) {
    // Street is optional
    return null;
  }

  // Validate area
  static String? validateArea(String? value) {
    // Area is optional
    return null;
  }

  // Validate city
  static String? validateCity(String? value) {
    // City is optional
    return null;
  }

  // Validate GST number
  static String? validateGSTNumber(String? value) {
    if (value == null || value.isEmpty) {
      // GST is optional
      return null;
    }
    // GST format: 22AAAAA0000A1Z5
    if (!RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$').hasMatch(value)) {
      return 'Enter a valid GST number';
    }
    return null;
  }

  // Form validation helper
  static bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }
}