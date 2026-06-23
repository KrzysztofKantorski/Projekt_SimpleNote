import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:simple_note/repositories/auth_repository.dart';
import 'package:simple_note/viewmodels/auth_viewmodel.dart';

import 'auth_viewmodel_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockRepo;
  late AuthViewModel vm;

  setUp(() {
    mockRepo = MockAuthRepository();
    vm = AuthViewModel(repository: mockRepo);
  });

  tearDown(() => vm.dispose());

  // login

  group('login()', () {
    test('zwraca true i nie ustawia błędu przy sukcesie', () async {
      when(mockRepo.login(any, any)).thenAnswer((_) async {});

      final result = await vm.login('user', 'pass123');

      expect(result, isTrue);
      expect(vm.errorMessage, isNull);
      expect(vm.isLoading, isFalse);
    });

    test('zwraca false i ustawia errorMessage przy wyjątku', () async {
      when(mockRepo.login(any, any))
          .thenThrow(Exception('Nieprawidłowe dane logowania'));

      final result = await vm.login('user', 'zlehaslo');

      expect(result, isFalse);
      expect(vm.errorMessage, contains('Nieprawidłowe dane logowania'));
      expect(vm.isLoading, isFalse);
    });

    test('ustawia isLoading=true w trakcie operacji', () async {
      when(mockRepo.login(any, any)).thenAnswer((_) async {
        expect(vm.isLoading, isTrue);
      });

      await vm.login('user', 'pass');
    });

    test('clearError() czyści errorMessage', () async {
      when(mockRepo.login(any, any)).thenThrow(Exception('błąd'));
      await vm.login('x', 'y');
      expect(vm.errorMessage, isNotNull);

      vm.clearError();

      expect(vm.errorMessage, isNull);
    });
  });

  // register

  group('register()', () {
    test('zwraca true przy sukcesie', () async {
      when(mockRepo.register(any, any)).thenAnswer((_) async {});

      final result = await vm.register('newuser', 'Password1');

      expect(result, isTrue);
      expect(vm.errorMessage, isNull);
    });

    test('zwraca false i ustawia błąd przy wyjątku', () async {
      when(mockRepo.register(any, any))
          .thenThrow(Exception('Nazwa użytkownika jest zajęta'));

      final result = await vm.register('zajety', 'pass');

      expect(result, isFalse);
      expect(vm.errorMessage, contains('Nazwa użytkownika jest zajęta'));
    });
  });

  // logout

  group('logout()', () {
    test('zwraca true przy sukcesie', () async {
      when(mockRepo.logout()).thenAnswer((_) async {});

      final result = await vm.logout();

      expect(result, isTrue);
    });

    test('zwraca false i ustawia błąd przy wyjątku', () async {
      when(mockRepo.logout()).thenThrow(Exception('Błąd serwera'));

      final result = await vm.logout();

      expect(result, isFalse);
      expect(vm.errorMessage, isNotNull);
    });
  });

  // notifylisteners

  group('notifyListeners()', () {
    test('powiadamia słuchaczy po zmianie stanu', () async {
      when(mockRepo.login(any, any)).thenAnswer((_) async {});
      int callCount = 0;
      vm.addListener(() => callCount++);

      await vm.login('u', 'p');

      expect(callCount, greaterThanOrEqualTo(2));
    });
  });
}
