import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:simple_note/models/note/note_model.dart';
import 'package:simple_note/models/note/update_note_model.dart';
import 'package:simple_note/repositories/note_repository.dart';
import 'package:simple_note/services/note_service.dart';

import 'note_repository_test.mocks.dart';

@GenerateMocks([NoteService])
void main() {
  late MockNoteService mockService;
  late NoteRepositoryImpl repo;

  NoteModel makeNote({int id = 1}) => NoteModel(
        id: id,
        title: 'T',
        content: 'C',
        subjectName: 'S',
        tagNames: [],
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

  setUp(() {
    mockService = MockNoteService();
    repo = NoteRepositoryImpl(noteService: mockService);
  });

  // getNotes

  group('getNotes()', () {
    test('deleguje do NoteService.getNotes i zwraca wynik', () async {
      final expected = [makeNote(id: 1), makeNote(id: 2)];
      when(mockService.getNotes()).thenAnswer((_) async => expected);

      final result = await repo.getNotes();

      expect(result, equals(expected));
      verify(mockService.getNotes()).called(1);
    });

    test('propaguje wyjątek z serwisu', () async {
      when(mockService.getNotes()).thenThrow(Exception('HTTP 500'));

      expect(() => repo.getNotes(), throwsException);
    });
  });

  // addNote

  group('addNote()', () {
    test('przekazuje wszystkie parametry do serwisu', () async {
      when(mockService.addNote(
        title: anyNamed('title'),
        content: anyNamed('content'),
        isPublic: anyNamed('isPublic'),
      )).thenAnswer((_) async => makeNote());

      await repo.addNote(title: 'Tytuł', content: 'Treść', isPublic: true);

      verify(mockService.addNote(
        title: 'Tytuł',
        content: 'Treść',
        isPublic: true,
      )).called(1);
    });

    test('propaguje wyjątek z serwisu', () async {
      when(mockService.addNote(
        title: anyNamed('title'),
        content: anyNamed('content'),
        isPublic: anyNamed('isPublic'),
      )).thenThrow(Exception('Błąd walidacji'));

      expect(
        () => repo.addNote(title: '', content: '', isPublic: false),
        throwsException,
      );
    });
  });

  // editNote

  group('editNote()', () {
    test('przekazuje id i request do serwisu', () async {
      final request = UpdateNoteRequest(
          title: 'Nowy', content: 'Nowa treść', isPublic: false);
      when(mockService.editNote(id: anyNamed('id'), request: anyNamed('request')))
          .thenAnswer((_) async => makeNote());

      await repo.editNote(id: 7, request: request);

      verify(mockService.editNote(id: 7, request: request)).called(1);
    });
  });
}
