class AppConstants {
  AppConstants._();

  // Campus Branding
  static const String campusName = 'COMSATS University Islamabad, Wah Campus';
  static const String appName = 'COMSATS Lost & Found';

  // Integration Configuration Toggles
  /// Set this to `true` to restrict account registrations strictly to official COMSATS email domains.
  /// Keep it `false` during local development or staging/testing with general emails.
  static const bool enforceUniversityEmail = false;

  /// Allowed university email domains when [enforceUniversityEmail] is active.
  static const List<String> allowedEmailDomains = [
    '@cuiwah.edu.pk',
    '@student.comsats.edu.pk',
    '@comsats.edu.pk',
  ];
}
