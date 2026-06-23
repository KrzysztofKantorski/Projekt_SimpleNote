import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/note_viewmodel.dart';

class SnOcrBottomSheet extends StatelessWidget {
  final NoteViewModel noteViewModel;

  const SnOcrBottomSheet({
    super.key,
    required this.noteViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'Skanuj tekst z obrazu',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined, color: Colors.black87),
            title: const Text(
              'Zrób zdjęcie (Aparat)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context); // Zamykamy BottomSheet
              noteViewModel.scanTextFromImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined, color: Colors.black87),
            title: const Text(
              'Wybierz z galerii',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context); // Zamykamy BottomSheet
              noteViewModel.scanTextFromImage(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}