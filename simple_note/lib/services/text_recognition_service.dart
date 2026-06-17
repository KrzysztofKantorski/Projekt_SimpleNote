import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class TextRecognitionService {
  final ImagePicker _imagePicker = ImagePicker();
  
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Funkcja, która otwiera aparat/galerię, robi zdjęcie i wyciąga z niego tekst
  Future<String?> recognizeTextFromImage({required ImageSource source}) async {
    try {
      // 1. Wybierz/zrób zdjęcie
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return null; // Użytkownik anulował

      // 2. Przekształć plik na InputImage wymagany przez ML Kit
      final inputImage = InputImage.fromFilePath(image.path);

      // 3. Przetwórz obraz i wyciągnij tekst
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 4. Zwróć scalony tekst
      return recognizedText.text;
    } catch (e) {
      print("❌ Błąd rozpoznawania tekstu: $e");
      return null;
    }
  }
  Future<String?> scanFromCamera() async {
  return await recognizeTextFromImage(source: ImageSource.camera);
}
  // Zamknięcie zasobów (dobra praktyka)
  void dispose() {
    _textRecognizer.close();
  }
}