import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:squad/features/plan/models/plan.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarUtils {
  static Future<bool> addToCalendar(Plan plan) async {
    if (plan.confirmedDate == null) {
      debugPrint('CalendarUtils: confirmedDate is null');
      return false;
    }

    try {
      // 1. If on Web, always use the Google Calendar URL (better than .ics download)
      if (kIsWeb) {
        return await _launchGoogleCalendarUrl(plan);
      }

      // 2. On Mobile, try the native calendar app first
      final Event event = Event(
        title: 'Squad: ${plan.title}',
        description: plan.description ?? 'Hangout planned with Squad',
        location: plan.confirmedVenue ?? plan.location ?? '',
        startDate: plan.confirmedDate!,
        endDate: plan.confirmedDate!.add(const Duration(hours: 3)),
        iosParams: const IOSParams(
          reminder: Duration(hours: 2),
        ),
      );

      final bool success = await Add2Calendar.addEvent2Cal(event);
      if (success) return true;

      // 3. Fallback for Mobile: If native plugin fails or returns false, try the URL
      debugPrint('CalendarUtils: Native plugin failed, trying URL fallback');
      return await _launchGoogleCalendarUrl(plan);
    } catch (e) {
      debugPrint('CalendarUtils Error: $e');
      // Final desperate attempt with URL if native crashed
      try {
        return await _launchGoogleCalendarUrl(plan);
      } catch (_) {
        return false;
      }
    }
  }

  static Future<bool> _launchGoogleCalendarUrl(Plan plan) async {
    final String title = Uri.encodeComponent('Squad: ${plan.title}');
    final String details = Uri.encodeComponent(plan.description ?? 'Hangout planned with Squad');
    final String location = Uri.encodeComponent(plan.confirmedVenue ?? plan.location ?? '');
    
    final startUtc = plan.confirmedDate!.toUtc();
    final endUtc = startUtc.add(const Duration(hours: 3));
    
    String _fmt(DateTime d) => d.toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first + 'Z';
    final String dates = '${_fmt(startUtc)}/${_fmt(endUtc)}';

    final String url = 'https://www.google.com/calendar/render?action=TEMPLATE&text=$title&details=$details&location=$location&dates=$dates';
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
