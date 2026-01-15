import 'package:flutter/foundation.dart';
import '../models/memory_palace.dart';
import '../models/locus.dart';
import 'api_client.dart';

class MemoryPalaceService {
  final _api = ApiClient().dio;

  // --- Memory Palaces ---

  Future<List<MemoryPalace>> getPalaces() async {
    try {
      final response = await _api.get('/api/v1/memory_palaces');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MemoryPalace.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting palaces: $e');
      return [];
    }
  }

  Future<MemoryPalace?> getPalace(int id) async {
    try {
      final response = await _api.get('/api/v1/memory_palaces/$id');
      if (response.statusCode == 200) {
        return MemoryPalace.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting palace $id: $e');
      return null;
    }
  }

  Future<bool> createPalace(MemoryPalace palace) async {
    try {
      final response = await _api.post(
        '/api/v1/memory_palaces',
        data: {'memory_palace': palace.toJson()},
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating palace: $e');
      return false;
    }
  }

  Future<bool> updatePalace(MemoryPalace palace) async {
    try {
      final response = await _api.patch(
        '/api/v1/memory_palaces/${palace.id}',
        data: {'memory_palace': palace.toJson()},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating palace: $e');
      return false;
    }
  }

  Future<bool> deletePalace(int id) async {
    try {
      final response = await _api.delete('/api/v1/memory_palaces/$id');
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting palace: $e');
      return false;
    }
  }

  // --- Loci ---

  Future<bool> createLocus(int palaceId, Locus locus) async {
    try {
      final response = await _api.post(
        '/api/v1/memory_palaces/$palaceId/loci',
        data: {'locus': locus.toJson()},
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating locus: $e');
      return false;
    }
  }

  Future<bool> updateLocus(int palaceId, Locus locus) async {
    try {
      final response = await _api.patch(
        '/api/v1/memory_palaces/$palaceId/loci/${locus.id}',
        data: {'locus': locus.toJson()},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating locus: $e');
      return false;
    }
  }

  Future<bool> deleteLocus(int palaceId, int locusId) async {
    try {
      final response = await _api.delete(
        '/api/v1/memory_palaces/$palaceId/loci/$locusId',
      );
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting locus: $e');
      return false;
    }
  }

  Future<bool> reorderLocus(int palaceId, int locusId, int newPosition) async {
    try {
      final response = await _api.patch(
        '/api/v1/memory_palaces/$palaceId/loci/$locusId/sort',
        data: {'position': newPosition},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error reordering locus: $e');
      return false;
    }
  }
}
