import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:simple_note/models/comment/comment_model.dart';
import 'package:simple_note/repositories/comment_repository.dart';
import 'package:simple_note/viewmodels/comment_viewmodel.dart';

import 'comment_viewmodel_test.mocks.dart';

@GenerateMocks([CommentRepository])
void main() {
  late MockCommentRepository mockRepo;
  late CommentViewModel vm;

  CommentModel makeComment({int id = 1, String content = 'Treść komentarza'}) {
    return CommentModel(
      id: id,
      content: content,
      authorName: 'Jan',
      createdAt: DateTime(2024, 1, 1),
      replies: [],
    );
  }

  setUp(() {
    mockRepo = MockCommentRepository();
    vm = CommentViewModel(repository: mockRepo);
  });

  tearDown(() => vm.dispose());

  // fetchComment

  group('fetchComments()', () {
    test('ładuje komentarze przy sukcesie', () async {
      final comments = [makeComment(id: 1), makeComment(id: 2)];
      when(mockRepo.getComments(1)).thenAnswer((_) async => comments);

      await vm.fetchComments(1);

      expect(vm.comments, equals(comments));
      expect(vm.errorMessage, isNull);
      expect(vm.isLoading, isFalse);
    });

    test('ustawia błąd przy wyjątku', () async {
      when(mockRepo.getComments(any)).thenThrow(Exception('Błąd pobierania'));

      await vm.fetchComments(99);

      expect(vm.comments, isEmpty);
      expect(vm.errorMessage, contains('Błąd pobierania'));
    });
  });

  // addComment

  group('addComment()', () {
    test('zwraca false dla pustego tekstu bez wywołania repozytorium', () async {
      final result = await vm.addComment(1, '   ');

      expect(result, isFalse);
      verifyNever(mockRepo.addComment(
          noteId: anyNamed('noteId'), content: anyNamed('content')));
    });

    test('zwraca true i odświeża komentarze przy sukcesie', () async {
      when(mockRepo.addComment(
        noteId: anyNamed('noteId'),
        content: anyNamed('content'),
      )).thenAnswer((_) async {});
      when(mockRepo.getComments(any)).thenAnswer((_) async => [makeComment()]);

      final result = await vm.addComment(1, 'Nowy komentarz');

      expect(result, isTrue);
      expect(vm.comments, isNotEmpty);
    });

    test('przekazuje trim() treści do repozytorium', () async {
      when(mockRepo.addComment(
        noteId: anyNamed('noteId'),
        content: anyNamed('content'),
      )).thenAnswer((_) async {});
      when(mockRepo.getComments(any)).thenAnswer((_) async => []);

      await vm.addComment(5, '  tekst z spacjami  ');

      verify(mockRepo.addComment(
        noteId: 5,
        content: 'tekst z spacjami',
      )).called(1);
    });

    test('zwraca false i ustawia błąd przy wyjątku', () async {
      when(mockRepo.addComment(
        noteId: anyNamed('noteId'),
        content: anyNamed('content'),
      )).thenThrow(Exception('Niedozwolona operacja'));

      final result = await vm.addComment(1, 'komentarz');

      expect(result, isFalse);
      expect(vm.errorMessage, contains('Niedozwolona operacja'));
    });
  });

  // deleteComment

  group('deleteComment()', () {
    test('zwraca true i odświeża listę przy sukcesie', () async {
      when(mockRepo.deleteComment(any, any)).thenAnswer((_) async {});
      when(mockRepo.getComments(any)).thenAnswer((_) async => []);

      final result = await vm.deleteComment(10, 1);

      expect(result, isTrue);
    });

    test('zwraca false i ustawia błąd przy wyjątku', () async {
      when(mockRepo.deleteComment(any, any))
          .thenThrow(Exception('Brak uprawnień'));

      final result = await vm.deleteComment(10, 1);

      expect(result, isFalse);
      expect(vm.errorMessage, contains('Brak uprawnień'));
    });
  });

  // clearComments

  group('clearComments()', () {
    test('zeruje listę komentarzy i błąd', () async {
      when(mockRepo.getComments(any))
          .thenAnswer((_) async => [makeComment()]);
      await vm.fetchComments(1);
      expect(vm.comments, isNotEmpty);

      vm.clearComments();

      expect(vm.comments, isEmpty);
      expect(vm.errorMessage, isNull);
      expect(vm.isLoading, isFalse);
    });
  });
}