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
  bool _isPublic = false;

  Future<void> _pickImageAndRecognizeText() async {
      showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SnOcrBottomSheet(
        noteViewModel: context.read<NoteViewModel>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteViewModel = context.watch<NoteViewModel>();

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
          // 1. IKONA OCZKA
          IconButton(
            icon: Icon(
              _isPublic ? Icons.visibility : Icons.visibility_off,
              color: _isPublic ? Colors.blue : Colors.grey,
            ),
            tooltip: _isPublic ? 'Notatka publiczna' : 'Notatka prywatna',
            onPressed: () {
              setState(() {
                _isPublic = !_isPublic;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isPublic 
                      ? 'Ustawiono notatkę jako PUBLICZNĄ' 
                      : 'Ustawiono notatkę jako PRYWATNĄ'
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          // 2. IKONA APARATU (Google ML Kit Text Recognition)
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
            tooltip: 'Skanuj tekst ze zdjęcia',
            onPressed: _pickImageAndRecognizeText,
          ),

          // 3. PRZYCISK ZAPISU ZMIAN
          IconButton(
            icon: noteViewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.check_rounded, color: Colors.black, size: 28),
            tooltip: 'Zapisz zmiany',
            onPressed: noteViewModel.isLoading
                ? null
                : () async {
                    if (noteViewModel.titleController.text.trim().isEmpty &&
                        noteViewModel.contentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notatka nie może być pusta!')),
                      );
                      return;
                    }
                    final bool isSuccess = await noteViewModel.updateNote(
                    isPublic: _isPublic,
                    );

                    if (isSuccess && context.mounted) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🚀 Zmiany zostały zapisane!')),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('❌ Błąd: ${noteViewModel.errorMessage ?? "Nieznany błąd"}'),
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  // Pole dla TYTUŁU
                  TextField(
                    controller: noteViewModel.titleController,
                    style: const TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tytuł notatki...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            ),
            // Pole dla TREŚCI
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: TextField(
                  controller: noteViewModel.contentController,
                  style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Zacznij pisać...',
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