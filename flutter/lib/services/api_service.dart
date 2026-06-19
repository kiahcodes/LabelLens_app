import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _baseUrl = 'https://labellens-app.onrender.com';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  Future<Map<String, dynamic>> scan({
    required String ocrText,
    required String productType,
    required Map<String, dynamic> userProfile,
    required String userId,
  }) async {
    final response = await _dio.post('/scan', data: {
      'ocr_text': ocrText,
      'product_type': productType,
      'user_profile': userProfile,
      'user_id': userId,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getScanHistory(String userId) async {
    final response = await _dio.get('/scan-history/$userId');
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<Map<String, dynamic>> getScan(String scanId) async {
    final response = await _dio.get('/scan/$scanId');
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteAccount(String accessToken) async {
    await _dio.delete(
      '/account',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
  }

  Future<Map<String, dynamic>> chatbot({
    required String message,
    required String scanContext,
    required Map<String, dynamic> userProfile,
    required List<Map<String, dynamic>> conversationHistory,
    String targetLanguage = 'en',
  }) async {
    final response = await _dio.post('/chatbot', data: {
      'message': message,
      'scan_context': scanContext,
      'user_profile': userProfile,
      'conversation_history': conversationHistory,
      'target_language': targetLanguage,
    });
    return response.data as Map<String, dynamic>;
  }
}
