import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/note_viewmodel.dart';
import '../components/other_widgets/image_picker.dart';

class AddNoteView extends StatefulWidget {
  const AddNoteView({super.key});

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteViewModel>().clearEditor();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _subjectController.dispose();
    context.read<NoteViewModel>().clearEditor();
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
          'Nowa notatka',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // IKONA OCZKA (Przełącznik IsPublic)
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

          // IKONA APARATU (Google ML Kit Text Recognition)
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
            tooltip: 'Skanuj tekst ze zdjęcia',
            onPressed: _pickImageAndRecognizeText,
          ),

          // PRZYCISK ZAPISU
          IconButton(
            icon: noteViewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.check_rounded, color: Colors.black, size: 28),
            tooltip: 'Zapisz notatkę',
            onPressed: noteViewModel.isLoading
                ? null
                : () async {
                    final title = _titleController.text.trim();
                    final content = _contentController.text.trim();
                    final subject = _subjectController.text.trim();

                    if (title.isEmpty && content.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Nie można zapisać pustej notatki!')),
                      );
                      return;
                    }

                    final bool isSuccess = await noteViewModel.addNewNote(
                      title: title,
                      content: content,
                      isPublic: _isPublic,
                      subject: subject.isEmpty ? null : subject,
                    );

                    if (isSuccess) {
                      _contentController.clear();
                      _titleController.clear();
                      _subjectController.clear();
                      if (context.mounted) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text(' Sukces! Notatka dodana do bazy.')),
                        );
                      }
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                              'Błąd API: ${noteViewModel.errorMessage ?? "Nieznany błąd"}'),
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