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
  bool _isPublic = false;
late NoteViewModel _noteViewModel;

@override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteViewModel>().clearEditor();
    });
  }


@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _noteViewModel = Provider.of<NoteViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteViewModel.clearEditor();
    super.dispose();
  }

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
          'Nowa notatka',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // 1. IKONA OCZKA (Przełącznik IsPublic)
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

          // 3. PRZYCISK ZAPISU
          IconButton(
            icon: noteViewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.check_rounded, color: Colors.black, size: 28),
            tooltip: 'Zapisz notatkę',
            onPressed: noteViewModel.isLoading 
                ? null 
                : () async {
                    final title = _titleController.text.trim();
                    final content = noteViewModel.contentController.text.trim();

                    if (title.isEmpty && content.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nie można zapisać pustej notatki!')),
                      );
                      return;
                    }

                    final bool isSuccess = await noteViewModel.addNewNote(
                      title: title,
                      content: content,
                      isPublic: _isPublic,
                    );

                    if (isSuccess) {
                      noteViewModel.contentController.clear();
                      if (context.mounted) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🚀 Sukces! Notatka dodana do bazy.')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('❌ Błąd API: ${noteViewModel.errorMessage ?? "Nieznany błąd"}'),
                          ),
                        );
                      }
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
                    controller: _titleController,
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
                    hintText: 'Zacznij pisać tutaj...',
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