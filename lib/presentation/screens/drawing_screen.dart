import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minivid/controllers/drawing_controller.dart';
import 'package:minivid/utils/widget/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:ui' as ui;

class DrawingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawingController(),
      child: Consumer<DrawingController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: CustomAppBar(),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Screenshot(
                      controller: controller.screenshotController,
                      child: GestureDetector(
                        onPanStart: controller.isLoading
                            ? null
                            : (details) =>
                                controller.startLine(details.localPosition),
                        onPanUpdate: controller.isLoading
                            ? null
                            : (details) =>
                                controller.updateLine(details.localPosition),
                        onPanEnd: controller.isLoading
                            ? null
                            : (_) => controller.endLine(),
                        child: Stack(
                          children: [
                            CustomPaint(
                              key: controller.paintKey,
                              size: Size.infinite,
                              painter: DrawingPainter(
                                  controller.lines, controller.currentLine),
                            ),
                            if (controller.isLoading)
                              Center(
                                child: CircularProgressIndicator(
                                    color: Colors.blue),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (controller.resultImageUrl != null &&
                      !controller.isLoading)
                    Column(
                      children: [
                        Container(
                          height: 300,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              controller.resultImageUrl!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(controller.resultImageUrl);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add to Post'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              color: Colors.black,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.color_lens, color: Colors.white),
                      onPressed: () async {
                        final Color? pickedColor = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            content: BlockPicker(
                              pickerColor: controller.selectedColor,
                              onColorChanged: (color) =>
                                  Navigator.of(context).pop(color),
                            ),
                          ),
                        );
                        if (pickedColor != null) {
                          controller.selectedColor = pickedColor;
                          controller.notifyListeners();
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.undo, color: Colors.white),
                      onPressed: controller.undoLastLine,
                    ),
                    Expanded(
                      child: Slider(
                        value: controller.strokeWidth,
                        min: 1.0,
                        max: 10.0,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey,
                        onChanged: (value) {
                          controller.strokeWidth = value;
                          controller.notifyListeners();
                        },
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                            onPressed: controller.sendDrawing,
                            icon: Icon(LucideIcons.send, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;

  DrawingPainter(this.lines, this.currentLine);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var line in lines) {
      paint.color = line.color;
      paint.strokeWidth = line.strokeWidth;
      canvas.drawPoints(ui.PointMode.polygon, line.points, paint);
    }

    if (currentLine != null) {
      paint.color = currentLine!.color;
      paint.strokeWidth = currentLine!.strokeWidth;
      canvas.drawPoints(ui.PointMode.polygon, currentLine!.points, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
