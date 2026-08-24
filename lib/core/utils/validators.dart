/// Centralized form field validators for the Lost & Found application.
///
/// Usage inside a [TextFormField]:
/// ```dart
/// validator: Validators.email,
/// ```
class Validators {
  Validators._();

  // ── Email ──────────────────────────────────────────────────────────────────

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address.';
    }
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  // ── Password ───────────────────────────────────────────────────────────────

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != original) {
      return 'Passwords do not match.';
    }
    return null;
  }

  // ── Name ───────────────────────────────────────────────────────────────────

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    if (value.trim().length < 3) {
      return 'Full name must be at least 3 characters.';
    }
    return null;
  }

  // ── Item fields ────────────────────────────────────────────────────────────

  static String? itemTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an item title.';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters.';
    }
    if (value.trim().length > 100) {
      return 'Title must not exceed 100 characters.';
    }
    return null;
  }

  static String? itemDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a description.';
    }
    if (value.trim().length < 10) {
      return 'Please provide a more detailed description (at least 10 characters).';
    }
    return null;
  }

  static String? category(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a category.';
    }
    return null;
  }

  static String? location(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the location.';
    }
    return null;
  }

  // ── Claims ─────────────────────────────────────────────────────────────────

  static String? proofDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe your proof of ownership.';
    }
    if (value.trim().length < 15) {
      return 'Please provide more detail (at least 15 characters).';
    }
    return null;
  }

  // ── General ────────────────────────────────────────────────────────────────

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }
}
