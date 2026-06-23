import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/note_viewmodel.dart';
import '../components/other_widgets/image_picker.dart';

class NoteEditorView extends StatefulWidget {
  const NoteEditorView({super.key});

  @override
  State<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<NoteEditorView> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _subjectController;
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    final note = context.read<NoteViewModel>().editingNote;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _subjectController = TextEditingController(text: note?.subjectName ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _pickImageAndRecognizeText() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SnOcrBottomSheet(
        noteViewModel: ctx.read<NoteViewModel>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteViewModel = context.watch<NoteViewModel>();

    final scanned = noteViewModel.scannedText;
    if (scanned != null && scanned.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final current = _contentController.text;
        _contentController.text =
            current.isEmpty ? scanned : '$current\n$scanned';
        context.read<NoteViewModel>().clearEditor();
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Edytuj notatkę',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (noteViewModel.editingNote != null)
    IconButton(
      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
      tooltip: 'Usuń notatkę',
      onPressed: noteViewModel.isLoading
          ? null
          : () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Usuń notatkę'),
                  content: const Text('Czy na pewno chcesz bezpowrotnie usunąć tę notatkę?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Anuluj', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Usuń', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                final router = GoRouter.of(context);
                final messenger = ScaffoldMessenger.of(context);
                
                final bool success = await context
                    .read<NoteViewModel>()
                    .deleteNote(noteViewModel.editingNote!.id);

                if (success) {
                  router.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Notatka została usunięta.')),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Błąd: ${noteViewModel.errorMessage ?? "Nie udało się usunąć"}'),
                    ),
                  );
                }
              }
            },
          ),
          // IKONA OCZKA
          IconButton(
            icon: Icon(
              _isPublic ? Icons.visibility : Icons.visibility_off,
              color: _isPublic ? Colors.blue : Colors.grey,
            ),
            tooltip: _isPublic ? 'Notatka publiczna' : 'Notatka prywatna',
            onPressed: () {
              setState(() => _isPublic = !_isPublic);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isPublic
                      ? 'Ustawiono notatkę jako PUBLICZNĄ'
                      : 'Ustawiono notatkę jako PRYWATNĄ'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          // IKONA APARATU (Google ML Kit)
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
            tooltip: 'Skanuj tekst ze zdjęcia',
            onPressed: _pickImageAndRecognizeText,
          ),

          // PRZYCISK ZAPISU ZMIAN
          IconButton(
            icon: noteViewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.check_rounded, color: Colors.black, size: 28),
            tooltip: 'Zapisz zmiany',
            onPressed: noteViewModel.isLoading
                ? null
                : () async {
                    final title = _titleController.text.trim();
                    final content = _contentController.text.trim();
                    final subject = _subjectController.text.trim();

                    if (title.isEmpty && content.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Notatka nie może być pusta!')),
                      );
                      return;
                    }
                    final bool isSuccess = await noteViewModel.updateNote(
                      title: title,
                      content: content,
                      isPublic: _isPublic,
                      subject: subject.isEmpty ? null : subject,
                    );

                    if (isSuccess && context.mounted) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Zmiany zostały zapisane!')),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                              'Błąd: ${noteViewModel.errorMessage ?? "Nieznany błąd"}'),
                        ),
                      );
                    }
                  },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  // Pole dla TYTUŁU
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tytuł notatki',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    maxLines: 1,
                  ),
                  TextField(
                    controller: _subjectController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Przedmiot',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      border: InputBorder.none,
                      icon: Icon(Icons.label_outline_rounded, color: Colors.grey, size: 20),
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 1,
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child:
                  Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            ),
            // Pole dla TREŚCI
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 8.0),
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(
                      fontSize: 18, height: 1.6, color: Colors.black87),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Zacznij pisać tutaj',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}