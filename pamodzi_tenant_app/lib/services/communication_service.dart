import 'package:url_launcher/url_launcher.dart';

/// Service to handle communication with landlord (email, phone, SMS)
class CommunicationService {
  /// Send email to landlord
  Future<bool> sendEmail({
    required String recipientEmail,
    String? subject,
    String? body,
  }) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: recipientEmail,
        query: _encodeQueryParameters(<String, String>{
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        }),
      );

      if (await canLaunchUrl(emailUri)) {
        return await launchUrl(emailUri);
      } else {
        print('Could not launch email client');
        return false;
      }
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  /// Make a phone call
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(phoneUri)) {
        return await launchUrl(phoneUri);
      } else {
        print('Could not launch phone dialer');
        return false;
      }
    } catch (e) {
      print('Error making phone call: $e');
      return false;
    }
  }

  /// Send SMS
  Future<bool> sendSMS({
    required String phoneNumber,
    String? message,
  }) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        query: message != null ? 'body=$message' : null,
      );

      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      } else {
        print('Could not launch SMS app');
        return false;
      }
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  /// Open WhatsApp chat
  Future<bool> openWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    try {
      // Remove any non-digit characters from phone number
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
      
      final Uri whatsappUri = Uri.parse(
        'https://wa.me/$cleanNumber${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
      );

      if (await canLaunchUrl(whatsappUri)) {
        return await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print('Could not launch WhatsApp');
        return false;
      }
    } catch (e) {
      print('Error opening WhatsApp: $e');
      return false;
    }
  }

  /// Helper to encode query parameters
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
