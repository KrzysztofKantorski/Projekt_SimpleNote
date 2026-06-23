import 'package:dio/dio.dart';

/// Logika wyciągania komunikatu błędu z odpowiedzi Dio.
String extractDioErrorMessage(DioException e) {
  final data = e.response?.data;
  final statusCode = e.response?.statusCode;

  if (data == null) return 'Błąd komunikacji z serwerem (Kod: $statusCode)';
  if (data is String) {
    return data.trim().isNotEmpty ? data : 'Wystąpił błąd (Kod: $statusCode)';
  }

  if (data is List) {
    if (data.isNotEmpty) {
      final first = data.first;
      if (first is Map && first.containsKey('description')) {
        return first['description'].toString();
      }
      if (first is String) {
        return data.map((e) => e.toString()).join('\n');
      }
    }
    return 'Błąd serwera (Kod: $statusCode)';
  }

  if (data is Map) {
    if (data['errors'] is Map) {
      final errors = data['errors'] as Map;
      if (errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    if (data['errors'] is List) {
      final errors = data['errors'] as List;
      if (errors.isNotEmpty && errors.first is String) {
        return errors.join('\n');
      }
    }
    if (data['message'] != null) return data['message'].toString();
    if (data['title'] != null) return data['title'].toString();
  }

  return 'Wystąpił nieznany błąd serwera (Kod: $statusCode)';
}
