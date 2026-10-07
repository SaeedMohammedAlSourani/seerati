import 'dart:convert';
import 'package:http/http.dart' as http;
import '../localization/app_language.dart';
import '../models/report_data.dart';

enum ReportErrorType { noData, badResponse, rateLimited, serverError, network }

class ReportApiException implements Exception {
  final ReportErrorType type;
  ReportApiException(this.type);
}

class ReportApiService {
  static const String _workerUrl = 'https://seerati-worker.sa196.workers.dev';

  static Future<ReportData> generateReport({
    required List<Map<String, String>> images, // [{mimeType, data(base64)}]
    required String excelText,
    required String notes,
    required AppLanguage language,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(_workerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mode': 'report',
          'images': images,
          'excelText': excelText,
          'notes': notes,
          'language': language == AppLanguage.ar ? 'ar' : 'en',
        }),
      )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reportJson = data['result'];
        if (reportJson == null || reportJson is! Map<String, dynamic>) {
          throw ReportApiException(ReportErrorType.badResponse);
        }
        return ReportData.fromJson(reportJson);
      } else if (response.statusCode == 429) {
        throw ReportApiException(ReportErrorType.rateLimited);
      } else if (response.statusCode == 400) {
        throw ReportApiException(ReportErrorType.noData);
      } else {
        throw ReportApiException(ReportErrorType.serverError);
      }
    } on ReportApiException {
      rethrow;
    } catch (e) {
      throw ReportApiException(ReportErrorType.network);
    }
  }
}