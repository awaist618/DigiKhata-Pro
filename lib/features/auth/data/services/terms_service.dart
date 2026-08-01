import 'package:shared_preferences/shared_preferences.dart';
import '../models/terms_section.dart';

class TermsService {
  static const String _acceptedKey = 'accepted_terms';
  static const String _versionKey = 'terms_version';
  static const String currentVersion = '1.0';

  Future<bool> hasAcceptedCurrentTerms() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_acceptedKey) ?? false;
    final version = prefs.getString(_versionKey);
    return accepted && version == currentVersion;
  }

  Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_acceptedKey, true);
    await prefs.setString(_versionKey, currentVersion);
  }

  List<TermsSection> getTermsSections() {
    return const [
      TermsSection(
        title: '1. Acceptance of Terms',
        content: 'By creating an account or using DigiKhata Pro, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the application.',
      ),
      TermsSection(
        title: '2. Eligibility',
        content: 'You must be at least 18 years of age or the age of legal majority in your jurisdiction to use this application.',
      ),
      TermsSection(
        title: '3. Account Registration',
        content: 'You are responsible for providing accurate information during registration and keeping your account details up to date.',
      ),
      TermsSection(
        title: '4. Account Security',
        content: 'You are responsible for maintaining the confidentiality of your password, PIN, and biometric access. Any activity under your account is your responsibility.',
      ),
      TermsSection(
        title: '5. Business Information',
        content: 'Users maintain ownership of all business records entered. DigiKhata Pro provides the platform to manage this data but does not own your business entries.',
      ),
      TermsSection(
        title: '6. Data Collection',
        content: 'We collect information including Name, Business Name, Phone, Email, Transactions, Device Information, Crash Reports, and Analytics to improve our service.',
      ),
      TermsSection(
        title: '7. Privacy',
        content: 'Your personal data is protected and stored using encrypted storage. We do not sell user data to third parties.',
      ),
      TermsSection(
        title: '8. Financial Disclaimer',
        content: 'DigiKhata Pro is a bookkeeping tool only. It does not provide financial, tax, or investment advice. Consult a professional for such needs.',
      ),
      TermsSection(
        title: '9. User Responsibilities',
        content: 'You agree not to engage in illegal activities, provide fake information, attempt hacking, or reverse engineer the application.',
      ),
      TermsSection(
        title: '10. Cloud Backup',
        content: 'Your data is automatically synchronized with Firebase Cloud Firestore for secure backup and offline support.',
      ),
      TermsSection(
        title: '11. Notifications',
        content: 'The app may send notifications for payment reminders, due balances, security alerts, and system updates.',
      ),
      TermsSection(
        title: '12. Biometric Authentication',
        content: 'Biometric data (Fingerprint/Face ID) is handled by your device hardware. DigiKhata Pro never stores or has access to your actual biometric data.',
      ),
      TermsSection(
        title: '13. Data Security',
        content: 'We employ industry-standard encryption, HTTPS, and secure APIs to protect your data and session management.',
      ),
      TermsSection(
        title: '14. Prohibited Activities',
        content: 'Fraud, abuse, spam, malware distribution, and unauthorized access are strictly prohibited and will lead to account termination.',
      ),
      TermsSection(
        title: '15. Account Suspension',
        content: 'We reserve the right to suspend or terminate accounts that violate these terms or engage in suspicious bookkeeping activities.',
      ),
      TermsSection(
        title: '16. Intellectual Property',
        content: 'All app content, designs, and logos belong to Zenvyro Labs x Awais. Unauthorized use is prohibited.',
      ),
      TermsSection(
        title: '17. Limitation of Liability',
        content: 'Zenvyro Labs x Awais is not responsible for incorrect records entered by the user or any resulting financial discrepancies.',
      ),
      TermsSection(
        title: '18. Changes to Terms',
        content: 'We may update these terms from time to time. Users will be notified of significant changes via the app.',
      ),
      TermsSection(
        title: '19. Contact Information',
        content: 'For support, contact us at support@zenvyrolabs.com or visit our website.',
      ),
      TermsSection(
        title: '20. Agreement',
        content: 'By clicking "I Have Read & Agree", you confirm that you have read, understood, and accepted these Terms and Conditions.',
      ),
    ];
  }
}
