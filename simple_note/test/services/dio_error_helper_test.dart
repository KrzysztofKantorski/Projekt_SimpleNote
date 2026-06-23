import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_note/services/dio_error_helper.dart';

DioException _makeException(dynamic data, {int statusCode = 400}) {
  final response = Response(
    data: data,
    statusCode: statusCode,
    requestOptions: RequestOptions(path: '/test'),
  );
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    response: response,
  );
}

void main() {
  group('extractDioErrorMessage()', () {
    // brak danych

    test('zwraca komunikat o braku połączenia gdy data == null', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          data: null,
          statusCode: 503,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      final msg = extractDioErrorMessage(e);

      expect(msg, contains('503'));
    });

    // String

    test('zwraca String bezpośrednio gdy data jest String', () {
      final msg = extractDioErrorMessage(
        _makeException('Nieprawidłowe dane'),
      );

      expect(msg, equals('Nieprawidłowe dane'));
    });

    test('fallback gdy data jest pustym Stringiem', () {
      final msg = extractDioErrorMessage(_makeException('  '));

      expect(msg, isNotEmpty);
    });

    // List

    test('wyciąga description z listy map', () {
      final msg = extractDioErrorMessage(
        _makeException([
          {'description': 'Pole wymagane'}
        ]),
      );

      expect(msg, equals('Pole wymagane'));
    });

    test('łączy elementy listy Stringów', () {
      final msg = extractDioErrorMessage(
        _makeException(['Błąd 1', 'Błąd 2']),
      );

      expect(msg, contains('Błąd 1'));
      expect(msg, contains('Błąd 2'));
    });

    test('fallback gdy lista jest pusta', () {
      final msg = extractDioErrorMessage(_makeException([]));

      expect(msg, isNotEmpty);
    });

    // Map

    test('wyciąga pierwszy błąd z errors.Field[0] (ASP.NET)', () {
      final msg = extractDioErrorMessage(
        _makeException({
          'errors': {
            'Username': ['Nazwa użytkownika jest za krótka']
          }
        }),
      );

      expect(msg, equals('Nazwa użytkownika jest za krótka'));
    });

    test('wyciąga message z mapy', () {
      final msg = extractDioErrorMessage(
        _makeException({'message': 'Zasób nie istnieje'}),
      );

      expect(msg, equals('Zasób nie istnieje'));
    });

    test('wyciąga title gdy brak message', () {
      final msg = extractDioErrorMessage(
        _makeException({'title': 'Not Found'}),
      );

      expect(msg, equals('Not Found'));
    });

    test('fallback gdy mapa nie zawiera znanych kluczy', () {
      final msg = extractDioErrorMessage(
        _makeException({'unknown': 'value'}, statusCode: 500),
      );

      expect(msg, contains('500'));
    });
  });
}
