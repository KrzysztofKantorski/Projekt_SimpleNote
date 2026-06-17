import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/note_viewmodel.dart';

class AddNoteView extends StatefulWidget {
  const AddNoteView({super.key});

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteViewModel = context.watch<NoteViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Test API - Nowa notatka'),
        elevation: 0,
        actions: [
          // Przycisk zapisu połączony bezpośrednio z API
          IconButton(
            icon: noteViewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                  )
                : const Icon(Icons.check_rounded, color: Colors.green, size: 28),
            tooltip: 'Zapisz do API',
            onPressed: noteViewModel.isLoading 
                ? null 
                : () async {
                    final title = _titleController.text.trim();
                    final content = noteViewModel.contentController.text.trim();

                    // 1. Walidacja lokalna przed strzałem do API
                    if (title.isEmpty && content.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nie można zapisać pustej notatki!')),
                      );
                      return;
                    }

                    // 2. Wywołanie metody sieciowej z ViewModelu
                    final bool isSuccess = await noteViewModel.addNewNote(
                      title: title,
                      content: content,
                    );

                    // 3. Jeśli API zwróciło sukces (true), czyścimy stan i wracamy
                    if (isSuccess) {
                      noteViewModel.contentController.clear();
                      if (context.mounted) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🚀 Sukces! Notatka dodana do bazy API.')),
                        );
                      }
                    } else {
                      // 4. Jeśli API zwróciło błąd (false), pokazujemy co poszło nie tak (np. błąd z FluentValidation)
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
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // Pole dla TYTUŁU
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Tytuł notatki...',
                  border: InputBorder.none,
                ),
                maxLines: 1,
              ),
              const Divider(height: 20, thickness: 1),
              
              // Pole dla TREŚCI
              Expanded(
                child: TextField(
                  controller: noteViewModel.contentController,
                  style: const TextStyle(fontSize: 18, height: 1.5),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Treść wysyłana do API...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}