/// ================================================================
/// SwiftSnap — SMTP & Email Service Configuration Reference
/// ================================================================
///
/// EMAIL IS HANDLED SERVER-SIDE (LARAVEL).
/// This file documents what values your backend .env must have,
/// and provides Flutter-side constants for display purposes only
/// (e.g. showing the support email in the UI).
///
/// ─── CHOOSING AN EMAIL PROVIDER ──────────────────────────────────
///
///   Option A: Mailgun (recommended for transactional)
///     - Sign up at: https://www.mailgun.com/
///     - Add & verify your domain (swiftsnap.app)
///     - Get SMTP credentials from Mailgun dashboard
///     Laravel .env:
///       MAIL_MAILER=mailgun
///       MAILGUN_DOMAIN=swiftsnap.app
///       MAILGUN_SECRET=key-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
///       MAILGUN_ENDPOINT=api.mailgun.net
///
///   Option B: SendGrid
///     - Sign up at: https://sendgrid.com/
///     - Create API key: Settings → API Keys → Create API Key
///     Laravel .env:
///       MAIL_MAILER=smtp
///       MAIL_HOST=smtp.sendgrid.net
///       MAIL_PORT=587
///       MAIL_USERNAME=apikey
///       MAIL_PASSWORD=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
///       MAIL_ENCRYPTION=tls
///
///   Option C: Amazon SES (cheapest at scale)
///     - Go to: https://aws.amazon.com/ses/
///     - Verify your domain swiftsnap.app
///     - Create SMTP credentials in SES console
///     Laravel .env:
///       MAIL_MAILER=ses
///       AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
///       AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
///       AWS_DEFAULT_REGION=us-east-1
///
///   Option D: Standard SMTP (Gmail / Office365 etc.)
///     - Use only for testing — not recommended for production (rate limits)
///     Laravel .env:
///       MAIL_MAILER=smtp
///       MAIL_HOST=smtp.gmail.com
///       MAIL_PORT=587
///       MAIL_USERNAME=your-email@gmail.com
///       MAIL_PASSWORD=your-app-password       # Gmail App Password, NOT account password
///       MAIL_ENCRYPTION=tls
///
/// ─── REQUIRED .ENV VALUES (ALL PROVIDERS) ─────────────────────────
///
///   MAIL_FROM_ADDRESS=noreply@swiftsnap.app
///   MAIL_FROM_NAME=SwiftSnap
///   MAIL_REPLY_TO=support@swiftsnap.app
///
/// ─── DNS RECORDS TO ADD AT YOUR DOMAIN REGISTRAR ──────────────────
///
///   SPF:  Add TXT record:  "v=spf1 include:mailgun.org ~all"
///         (replace mailgun.org with your provider's SPF include)
///
///   DKIM: Your email provider generates this — copy from their dashboard
///         and add as a TXT record on your domain.
///
///   DMARC: Add TXT record on _dmarc.swiftsnap.app:
///         "v=DMARC1; p=quarantine; rua=mailto:dmarc@swiftsnap.app"
///
/// ─── EMAIL TYPES USED IN VIBECHAT ─────────────────────────────────
///
///   1. Email Verification OTP     — on registration
///   2. Password Reset             — forgot password flow
///   3. Login Alert (new device)   — security notification
///   4. Warning Notification       — admin action
///   5. Suspension Notice          — admin action
///   6. Welcome Email              — after first login
///   7. Newsletter / Campaign      — from Email Campaigns admin screen
///   8. Creator Application        — status update
///
///   All 8 templates are defined in: documents/Email-Templates.json
///
/// ─── OTP / SMS (FOR PHONE VERIFICATION) ──────────────────────────
///
///   Vonage (formerly Nexmo) — recommended:
///     Sign up: https://www.vonage.com/communications-apis/
///     Laravel .env:
///       VONAGE_KEY=your_api_key
///       VONAGE_SECRET=your_api_secret
///       VONAGE_SMS_FROM=SwiftSnap
///
///   Twilio — alternative:
///     Sign up: https://www.twilio.com/
///     Laravel .env:
///       TWILIO_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
///       TWILIO_TOKEN=your_auth_token
///       TWILIO_FROM=+1XXXXXXXXXX
///
///   OTP settings in .env:
///     OTP_EXPIRY_MINUTES=10
///     OTP_MAX_ATTEMPTS=5
///     OTP_CODE_LENGTH=6
///
/// ─────────────────────────────────────────────────────────────────

class SmtpConfig {
  SmtpConfig._(); // prevent instantiation

  // Flutter UI display values — NOT secrets, safe to hardcode
  static const String supportEmail = 'support@swiftsnap.app';
  static const String noReplyEmail = 'noreply@swiftsnap.app';
  static const String appDomain = 'swiftsnap.app';

  // OTP length displayed in the UI (must match OTP_CODE_LENGTH in .env)
  static const int otpLength = 6;

  // OTP resend cooldown in seconds (shown in register/forgot-password UI)
  static const int otpResendCooldownSeconds = 58;
}
