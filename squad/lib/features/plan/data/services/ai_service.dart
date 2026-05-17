import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:squad/features/plan/models/itinerary_item.dart';
import 'package:squad/features/plan/models/plan.dart';

/// Service responsible for generating AI suggestions using Gemini.
class AIService {
  final String apiKey;
  late final GenerativeModel _model;

  AIService(this.apiKey) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  /// Generates a list of 3-4 fun, India-focused itinerary stops based on plan details.
  Future<List<ItineraryItem>> generateItinerarySuggestions(Plan plan) async {
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      debugPrint('AIService: No API Key found, returning mock data');
      return _getMockSuggestions(plan);
    }

    final prompt = '''
    You are an expert travel and hangout planner for Indian friend circles.
    Based on the following plan details, suggest a realistic 3-4 step itinerary.
    
    Plan Title: ${plan.title}
    Plan Description: ${plan.description ?? 'None'}
    Location: ${plan.confirmedVenue ?? plan.location ?? 'Unknown'}
    Date: ${plan.confirmedDate ?? 'TBD'}
    
    Return the response ONLY as a JSON array of objects (no markdown, no backticks, no other text) with these fields:
    - title (string): Short name of the activity/place
    - description (string): 1-sentence catchy description
    - startTime (ISO8601 string): Suggested start time (ensure it matches the plan date if provided)
    - location (string): Specific place name
    
    The itinerary should be fun, social, and "India-first" (e.g., suggest local cafes, popular hangout spots, or activities like bowling/movies if appropriate).
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      String? jsonString = response.text;
      if (jsonString == null) return [];

      // Clean up markdown code blocks if present
      if (jsonString.contains('```')) {
        final parts = jsonString.split('```').where((s) => s.trim().isNotEmpty).toList();
        jsonString = parts.firstWhere(
          (s) => s.trim().startsWith('[') || s.trim().startsWith('{') || s.trim().startsWith('json'),
          orElse: () => jsonString!,
        );
        if (jsonString.startsWith('json')) {
          jsonString = jsonString.substring(4).trim();
        }
      }

      final List<dynamic> data = jsonDecode(jsonString.trim());
      return data.map((item) {
        return ItineraryItem(
          itemId: '', // Will be assigned by Firestore
          title: item['title'] ?? 'Plan Step',
          description: item['description'] ?? '',
          time: DateTime.tryParse(item['startTime'] ?? '') ?? (plan.confirmedDate ?? DateTime.now()),
          location: item['location'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('AIService Error: $e');
      return _getMockSuggestions(plan);
    }
  }

  /// Fallback mock data when API call fails or key is missing.
  List<ItineraryItem> _getMockSuggestions(Plan plan) {
    final baseDate = plan.confirmedDate ?? DateTime.now();
    return [
      ItineraryItem(
        itemId: 'mock1',
        title: 'Meeting Point & Chai ☕',
        description: 'Gather the squad and start with some refreshing Irani Chai.',
        time: baseDate.add(const Duration(hours: 0)),
        location: 'Local Chai Adda',
      ),
      ItineraryItem(
        itemId: 'mock2',
        title: 'Main Hangout 🎯',
        description: 'Head to the main venue for games, fun, and photos.',
        time: baseDate.add(const Duration(hours: 1, minutes: 30)),
        location: plan.confirmedVenue ?? plan.location ?? 'Main Venue',
      ),
      ItineraryItem(
        itemId: 'mock3',
        title: 'Snacks & Street Food 🍔',
        description: 'End the perfect day sharing food and planning the next meet.',
        time: baseDate.add(const Duration(hours: 4)),
        location: 'Famous Street Food Lane',
      ),
    ];
  }
}
