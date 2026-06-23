import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:simple_note/models/auth/login_model.dart';
import 'package:simple_note/models/auth/logout_model.dart';
import 'package:simple_note/models/auth/register_model.dart';
import 'package:simple_note/repositories/auth_repository.dart';
import 'package:simple_note/services/auth_service.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockService;
  late AuthRepositoryImpl repo;

  setUp(() {
    mockService = MockAuthService();
    repo = AuthRepositoryImpl(authService: mockService);
  });

  // login

  group('login()', () {
    test('buduje LoginRequest i przekazuje go do serwisu', () async {
      when(mockService.login(any)).thenAnswer(
        (_) async => LoginResponse(message: 'ok', accessToken: 'tok123'),
      );

      await repo.login('adam', 'haslo123');

      final captured =
          verify(mockService.login(captureAny)).captured.single as LoginRequest;

      expect(captured.username, equals('adam'));
      expect(captured.password, equals('haslo123'));
    });

    test('propaguje wyjątek z serwisu', () {
      when(mockService.login(any)).thenThrow(Exception('401'));

      expect(() => repo.login('x', 'y'), throwsException);
    });
  });

  // register

  group('register()', () {
    test('buduje RegisterRequest i przekazuje go do serwisu', () async {
      when(mockService.register(any)).thenAnswer(
        (_) async => RegisterResponse(message: 'Zarejestrowano'),
      );

      await repo.register('newuser', 'Password1!');

      final captured = verify(mockService.register(captureAny)).captured.single
          as RegisterRequest;

      expect(captured.username, equals('newuser'));
      expect(captured.password, equals('Password1!'));
    });

    test('propaguje wyjątek z serwisu', () {
      when(mockService.register(any))
          .thenThrow(Exception('Nazwa zajęta'));

      expect(() => repo.register('zajety', 'pass'), throwsException);
    });
  });

  // logout

  group('logout()', () {
    test('wywołuje serwis dokładnie raz', () async {
      when(mockService.logout()).thenAnswer(
        (_) async => LogoutResponse(message: 'Wylogowano'),
      );

      await repo.logout();

      verify(mockService.logout()).called(1);
    });

    test('propaguje wyjątek z serwisu', () {
      when(mockService.logout()).thenThrow(Exception('Błąd wylogowania'));

      expect(() => repo.logout(), throwsException);
    });
  });
}