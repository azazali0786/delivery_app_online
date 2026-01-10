import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Returns an ISO8601 datetime string suitable for API timestamps
  static String formatDateTimeApi(DateTime date) {
    return date.toIso8601String();
  }

  static String formatCurrency(num amount) {
    final value = amount.toDouble();
    return '₹${value.toStringAsFixed(2)}';
  }

  static String formatQuantity(num quantity) {
    final value = quantity.toDouble();
    return '${value.toStringAsFixed(2)} L';
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  static String cleanWhatsAppNumber(String? raw) {
    if (raw == null) return '';
    String phone = raw.replaceAll(RegExp(r'[^0-9]'), '');
    // Remove leading zeros
    while (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    // If 10 digits assume India phone number and add country code 91
    if (phone.length == 10) {
      phone = '91$phone';
    }

    return phone;
  }

  static Future<void> openWhatsApp(
    String? rawPhoneNumber,
    String message,
  ) async {
    final phoneNumber = cleanWhatsAppNumber(rawPhoneNumber);

    if (phoneNumber.isEmpty) {
      throw Exception('Phone number missing');
    }

    final Uri launchUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    if (!await canLaunchUrl(launchUri)) {
      throw Exception('Cannot open WhatsApp');
    }

    await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openMap(
    String? locationLink,
    double? lat,
    double? lng,
  ) async {
    Uri? launchUri;

    if (locationLink != null && locationLink.isNotEmpty) {
      launchUri = Uri.parse(locationLink);
    } else if (lat != null && lng != null) {
      launchUri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    }

    if (launchUri != null && await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  static String getInitials(String name) {
    List<String> names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static DateTime parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
