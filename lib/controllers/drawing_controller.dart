import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DrawingController extends ChangeNotifier {
  final ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey paintKey = GlobalKey();

  Color selectedColor = Colors.white;
  double strokeWidth = 3.0;
  List<DrawnLine> lines = [];
  DrawnLine? currentLine;
  String? resultImageUrl;
  String? selectedImageUrl;
  bool isLoading = false;

  void startLine(Offset position) {
    if (isLoading) return;
    currentLine = DrawnLine([position], selectedColor, strokeWidth);
    notifyListeners();
  }

  void updateLine(Offset position) {
    if (isLoading || currentLine == null) return;
    currentLine?.points.add(position);
    notifyListeners();
  }

  void endLine() {
    if (isLoading || currentLine == null) return;
    lines.add(currentLine!);
    currentLine = null;
    notifyListeners();
  }

  void undoLastLine() {
    if (lines.isNotEmpty) {
      lines.removeLast();
      notifyListeners();
    }
  }

  Future<void> sendDrawing() async {
    isLoading = true;
    notifyListeners();

    try {
      final screenshot = await screenshotController.capture();
      if (screenshot != null) {
        String base64Image = base64Encode(screenshot);
        final jsonPayload = {"base64Url": "data:image/png;base64,$base64Image"};

        final response = await Dio().post(
          'https://canvas-back-2p2p.onrender.com/api/image/gen-prompt/',
          data: jsonPayload,
          options: Options(headers: {"Content-Type": "application/json"}),
        );

        final generatedPrompt = response.data['prompt'];
        resultImageUrl =
            "https://image.pollinations.ai/prompt/$generatedPrompt?nologo=true&enhance=true";
      }
    } catch (e) {
      print("Error sending drawing: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<File?> saveGeneratedDrawingUsingAi() async {
    try {
      // Generate the drawing using AI.
      isLoading = true;
      notifyListeners();

      final screenshot = await screenshotController.capture();
      if (screenshot != null) {
        String base64Image = base64Encode(screenshot);
        final jsonPayload = {"base64Url": "data:image/png;base64,$base64Image"};

        final response = await Dio().post(
          'https://canvas-back-2p2p.onrender.com/api/image/gen-prompt/',
          data: jsonPayload,
          options: Options(headers: {"Content-Type": "application/json"}),
        );

        final generatedPrompt = response.data['prompt'];
        final imageUrl =
            "https://image.pollinations.ai/prompt/$generatedPrompt?nologo=true&enhance=true";

        // Download the image and save it to a local file
        final http.Response responseImage = await http.get(Uri.parse(imageUrl));
        if (responseImage.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final filePath = "${tempDir.path}/generated_drawing.png";
          final file = File(filePath);
          await file.writeAsBytes(responseImage.bodyBytes);
          return file;
        } else {
          return null;
        }
      }
    } catch (e) {
      print("Error saving generated drawing: $e");
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawnLine(this.points, this.color, this.strokeWidth);
}
