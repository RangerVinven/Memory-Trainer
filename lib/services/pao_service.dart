import 'package:flutter/foundation.dart';
import '../models/pao_card.dart';
import '../models/pao_number.dart';
import '../models/pao_digit.dart';
import 'api_client.dart';

class PaoService {
  final _api = ApiClient().dio;

  // --- Cards ---
  Future<List<PaoCard>> getCards() async {
    try {
      final response = await _api.get('/api/v1/pao_cards');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PaoCard.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error loading cards: $e');
      return [];
    }
  }

  Future<bool> updateCards(List<PaoCard> cards) async {
    final Map<String, dynamic> payload = {};
    for (var card in cards) {
      payload[card.id.toString()] = card.toJson();
    }

    try {
      final response = await _api.patch(
        '/api/v1/pao_cards/bulk_update',
        data: {'pao_cards': payload},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating cards: $e');
      return false;
    }
  }

  // --- Numbers (00-99) ---
  Future<List<PaoNumber>> getNumbers() async {
    try {
      final response = await _api.get('/api/v1/pao_numbers');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PaoNumber.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error loading numbers: $e');
      return [];
    }
  }

  Future<bool> updateNumbers(List<PaoNumber> numbers) async {
    final Map<String, dynamic> payload = {};
    for (var num in numbers) {
      payload[num.id.toString()] = num.toJson();
    }

    try {
      final response = await _api.patch(
        '/api/v1/pao_numbers/bulk_update',
        data: {'pao_numbers': payload},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating numbers: $e');
      return false;
    }
  }

  // --- Digits (0-9) ---
  Future<List<PaoDigit>> getDigits() async {
    try {
      final response = await _api.get('/api/v1/pao_numbers/digits');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PaoDigit.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error loading digits: $e');
      return [];
    }
  }

  Future<bool> updateDigits(List<PaoDigit> digits) async {
    final Map<String, dynamic> payload = {};
    for (var digit in digits) {
      payload[digit.id.toString()] = digit.toJson();
    }

    try {
      final response = await _api.patch(
        '/api/v1/pao_numbers/bulk_update_digits',
        data: {'pao_digits': payload},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating digits: $e');
      return false;
    }
  }
}
