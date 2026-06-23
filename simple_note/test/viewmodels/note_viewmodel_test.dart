import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:simple_note/models/note/note_model.dart';
import 'package:simple_note/models/note/update_note_model.dart';
import 'package:simple_note/repositories/note_repository.dart';
import 'package:simple_note/services/text_recognition_service.dart';
import 'package:simple_note/viewmodels/note_viewmodel.dart';

import 'note_viewmodel_test.mocks.dart';

@GenerateMocks([NoteRepository, TextRecognitionService])
void main() {
  late MockNoteRepository mockRepo;
  late MockTextRecognitionService mockOcr;
  late NoteViewModel vm;

  NoteModel makeNote({int id = 1, String title = 'Tytuł', String content = 'Treść'}) {
    return NoteModel(
      id: id,
      title: title,
      content: content,
      tagNames: [],
      createdAt: DateTime(2024, 1, 1),
    );
  }

  setUp(() {
    mockRepo = MockNoteRepository();
    mockOcr = MockTextRecognitionService();
    vm = NoteViewModel(repository: mockRepo, recognitionService: mockOcr);
  });

  tearDown(() => vm.dispose());

  // fetchUsersNotes

  group('fetchUsersNotes()', () {
    test('ładuje notatki i czyści błąd przy sukcesie', () async {
      final notes = [makeNote(id: 1), makeNote(id: 2)];
      when(mockRepo.getNotes()).thenAnswer((_) async => notes);

      await vm.fetchUsersNotes();

      expect(vm.notes, equals(notes));
      expect(vm.errorMessage, isNull);
      expect(vm.isLoading, isFalse);
    });

    test('ustawia errorMessage przy wyjątku', () async {
      when(mockRepo.getNotes()).thenThrow(Exception('Brak połączenia'));

      await vm.fetchUsersNotes();

      expect(vm.notes, isEmpty);
      expect(vm.errorMessage, contains('Brak połączenia'));
    });

    test('isLoading jest true w trakcie ładowania', () async {
      when(mockRepo.getNotes()).thenAnswer((_) async {
        expect(vm.isLoading, isTrue);
        return [];
      });

      await vm.fetchUsersNotes();
      expect(vm.isLoading, isFalse);
    });
  });

  // addNewNote

  group('addNewNote()', () {
    test('zwraca true i odświeża listę przy sukcesie', () async {
      when(mockRepo.addNote(
        title: anyNamed('title'),
        content: anyNamed('content'),
        isPublic: anyNamed('isPublic'),
      )).thenAnswer((_) async {});
      when(mockRepo.getNotes()).thenAnswer((_) async => [makeNote()]);

      final result = await vm.addNewNote(
          title: 'Nowa', content: 'Treść', isPublic: false);

      expect(result, isTrue);
      expect(vm.notes, isNotEmpty);
    });

    test('zwraca false i ustawia błąd przy wyjątku', () async {
      when(mockRepo.addNote(
        title: anyNamed('title'),
        content: anyNamed('content'),
        isPublic: anyNamed('isPublic'),
      )).thenThrow(Exception('Błąd serwera'));

      final result = await vm.addNewNote(
          title: 'x', content: 'y', isPublic: true);

      expect(result, isFalse);
      expect(vm.errorMessage, isNotNull);
    });

    test('przekazuje prawidłowe parametry do repozytorium', () async {
      when(mockRepo.addNote(
        title: anyNamed('title'),
        content: anyNamed('content'),
        isPublic: anyNamed('isPublic'),
      )).thenAnswer((_) async {});
      when(mockRepo.getNotes()).thenAnswer((_) async => []);

      await vm.addNewNote(title: 'Mój tytuł', content: 'Moja treść', isPublic: true);

      verify(mockRepo.addNote(
        title: 'Mój tytuł',
        content: 'Moja treść',
        isPublic: true,
      )).called(1);
    });
  });

  // updateNote

  group('updateNote()', () {
    test('zwraca false gdy brak editingNote', () async {
      final result = await vm.updateNote(
          title: 'x', content: 'y', isPublic: false);

      expect(result, isFalse);
      verifyNever(mockRepo.editNote(
          id: anyNamed('id'), request: anyNamed('request')));
    });

    test('zwraca true i czyści editor po sukcesie', () async {
      vm.selectNoteForEditing(makeNote(id: 7));

      when(mockRepo.editNote(
        id: anyNamed('id'),
        request: anyNamed('request'),
      )).thenAnswer((_) async {});
      when(mockRepo.getNotes()).thenAnswer((_) async => []);

      final result = await vm.updateNote(
          title: 'Zmieniony', content: 'Nowa treść', isPublic: false);

      expect(result, isTrue);
      expect(vm.editingNote, isNull);
    });

    test('przekazuje poprawne id do repozytorium', () async {
      vm.selectNoteForEditing(makeNote(id: 42));

      when(mockRepo.editNote(
        id: anyNamed('id'),
        request: anyNamed('request'),
      )).thenAnswer((_) async {});
      when(mockRepo.getNotes()).thenAnswer((_) async => []);

      await vm.updateNote(title: 't', content: 'c', isPublic: false);

      final captured = verify(mockRepo.editNote(
        id: captureAnyNamed('id'),
        request: captureAnyNamed('request'),
      )).captured;

      expect(captured[0], equals(42));
      expect(captured[1], isA<UpdateNoteRequest>());
    });
  });

  // selectNoteForEditing / clearEditor

  group('selectNoteForEditing() / clearEditor()', () {
    test('selectNoteForEditing ustawia editingNote', () {
      final note = makeNote(id: 3);
      vm.selectNoteForEditing(note);

      expect(vm.editingNote, equals(note));
    });

    test('clearEditor czyści editingNote i scannedText', () {
      vm.selectNoteForEditing(makeNote());
      vm.clearEditor();

      expect(vm.editingNote, isNull);
      expect(vm.scannedText, isNull);
    });
  });
}