import 'dart:convert';
import 'package:http/http.dart' as http;
import '../localization/app_language.dart';
import '../models/resume_data.dart';

enum ApiErrorType { emptyResponse, rateLimited, serverError, network }

class ApiException implements Exception {
  final ApiErrorType type;
  ApiException(this.type);
}

class ApiService {
  /// عنوان الـ Cloudflare Worker اللي بيحمي مفتاح الـ API.
  static const String _workerUrl = 'https://seerati-worker.sa196.workers.dev';

  static Future<ResumeData> tailorResume({
    required String jobPosting,
    required String currentCv,
    required AppLanguage language,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(_workerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'job': jobPosting,
          'cv': currentCv,
          'language': language == AppLanguage.ar ? 'ar' : 'en',
        }),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final resumeJson = data['result'];
        if (resumeJson == null || resumeJson is! Map<String, dynamic>) {
          throw ApiException(ApiErrorType.emptyResponse);
        }
        return ResumeData.fromJson(resumeJson);
      } else if (response.statusCode == 429) {
        throw ApiException(ApiErrorType.rateLimited);
      } else {
        throw ApiException(ApiErrorType.serverError);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(ApiErrorType.network);
    }
  }
}