/// Runtime configuration. Cloudinary values are filled in once the account +
/// unsigned upload preset exist (see README / setup walkthrough).
class AppConfig {
  // --- Cloudinary (unsigned uploads for images & videos; no card required) ---
  // Replace these two with your Cloudinary dashboard values.
  static const String cloudinaryCloudName = 'mlwevo1q';
  static const String cloudinaryUploadPreset = 'GidiHomes';

  static bool get cloudinaryConfigured =>
      cloudinaryCloudName != 'YOUR_CLOUD_NAME' &&
      cloudinaryUploadPreset != 'YOUR_UNSIGNED_PRESET';

  // --- Admin / moderation ---
  // Users signing in with one of these emails get the moderation + verification
  // review tools. Must match the email check in firestore.rules.
  static const List<String> adminEmails = ['covenantp4@gmail.com'];

  static bool isAdminEmail(String? email) =>
      email != null && adminEmails.contains(email.toLowerCase());
}
