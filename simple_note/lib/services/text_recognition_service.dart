import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class TextRecognitionService {
  final ImagePicker _imagePicker = ImagePicker();
  
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied || status.isLimited) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings(); // Otwiera systemowe ustawienia Twojej aplikacji
      return false;
    }

    return false;
  }

  Future<String?> recognizeTextFromImage({required ImageSource source}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return null;

      final inputImage = InputImage.fromFilePath(image.path);

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      return null;
    }
  }

  Future<String?> scanFromCamera() async {

    final hasPermission = await _requestCameraPermission();
    
    if (!hasPermission) {
      return null; 
    }

    return await recognizeTextFromImage(source: ImageSource.camera);
  }

  void dispose() {
    _textRecognizer.close();
  }
}