import 'package:flutter/foundation.dart';
import 'api_client.dart';

class TrainingService {
  final _api = ApiClient().dio;

  Future<Map<String, dynamic>?> createSession({
    required String type,
    required int itemCount,
    required int batchSize,
  }) async {
    try {
      final response = await _api.post(
        '/api/v1/training_sessions',
        data: {
          'training_type': type,
          'item_count': itemCount,
          'batch_size': batchSize,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error creating session: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateSession({
    required int sessionId,
    int? durationSeconds,
    String? recallData,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (durationSeconds != null) data['duration_seconds'] = durationSeconds;
      if (recallData != null) data['recall_data'] = recallData;

      final response = await _api.patch(
        '/api/v1/training_sessions/$sessionId',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error updating session: $e');
      return null;
    }
  }
}
