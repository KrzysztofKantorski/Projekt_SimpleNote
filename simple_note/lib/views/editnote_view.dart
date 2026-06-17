import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/note_viewmodel.dart';

class NoteEditorView extends StatelessWidget {
  const NoteEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    // Słuchamy zmian w ViewModelu
    final noteViewModel = context.watch<NoteViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edytuj notatkę'),
        elevation: 0,
        actions: [
          IconButton(
            icon: noteViewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                  )
                : const Icon(Icons.check_rounded, color: Colors.blue, size: 28),
            tooltip: 'Zapisz zmiany',
            onPressed: noteViewModel.isLoading
                ? null
                : () async {
                    // Sprawdzamy walidację bezpośrednio z kontrolerów ViewModelu
                    if (noteViewModel.titleController.text.trim().isEmpty &&
                        noteViewModel.contentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notatka nie może być pusta!')),
                      );
                      return;
                    }

                    // Po prostu odpalamy metodę zapisu (ViewModel wie CO edytuje)
                    final bool isSuccess = await noteViewModel.updateNote();

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
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              TextField(
                controller: noteViewModel.titleController, // Z ViewModelu
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Tytuł notatki...',
                  border: InputBorder.none,
                ),
                maxLines: 1,
              ),
              const Divider(height: 20, thickness: 1),
              Expanded(
                child: TextField(
                  controller: noteViewModel.contentController, // Z ViewModelu
                  style: const TextStyle(fontSize: 18, height: 1.5),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Zacznij pisać...',
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