import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScreenshotInfo {
  final String timestamp;
  final String busNumber;
  final String location;
  final Map<String, double> distances;
  final String imageData;

  ScreenshotInfo({
    required this.timestamp,
    required this.busNumber,
    required this.location,
    required this.distances,
    required this.imageData,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'busNumber': busNumber,
      'location': location,
      'distances': distances,
      'imageData': imageData,
    };
  }
}

class ScreenshotService {
  /// Capture screenshot of a widget
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary;
      
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        return captureWidget(key);
      }
      
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing widget: $e');
      return null;
    }
  }

  /// Save screenshot with bus tracking information
  static Future<ScreenshotInfo?> saveTrackingScreenshot({
    required GlobalKey screenshotKey,
    required String busNumber,
    required String location,
    required Map<String, double> distances,
  }) async {
    try {
      final imageData = await captureWidget(screenshotKey);
      if (imageData == null) return null;

      final timestamp = DateTime.now().toIso8601String();
      final base64Image = 'data:image/png;base64,${html.window.btoa(
        String.fromCharCodes(imageData)
      )}';

      return ScreenshotInfo(
        timestamp: timestamp,
        busNumber: busNumber,
        location: location,
        distances: distances,
        imageData: base64Image,
      );
    } catch (e) {
      print('Error saving screenshot: $e');
      return null;
    }
  }

  /// Download screenshot as file
  static void downloadScreenshot(ScreenshotInfo info) {
    try {
      final anchor = html.AnchorElement()
        ..href = info.imageData
        ..download = 'bus_tracking_${info.busNumber}_${DateTime.now().millisecondsSinceEpoch}.png'
        ..click();
    } catch (e) {
      print('Error downloading screenshot: $e');
    }
  }

  /// Generate tracking report with screenshot
  static String generateTrackingReport(ScreenshotInfo info) {
    final timestamp = DateTime.parse(info.timestamp);
    final formattedTime = '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';

    return '''
Bus Tracking Report
==================

Bus Number: ${info.busNumber}
Location: ${info.location}
Timestamp: $formattedTime

Distance Information:
${info.distances.entries.map((e) => '- ${e.key}: ${e.value.toStringAsFixed(1)} km').join('\n')}

Screenshot captured and saved.
''';
  }

  /// Share tracking information
  static void shareTrackingInfo(ScreenshotInfo info) {
    final report = generateTrackingReport(info);
    
    if (html.window.navigator.share != null) {
      html.window.navigator.share({
        'title': 'Bus Tracking - ${info.busNumber}',
        'text': report,
      });
    } else {
      // Fallback: copy to clipboard
      html.window.navigator.clipboard?.writeText(report);
    }
  }

  /// Get screenshot metadata
  static Map<String, dynamic> getScreenshotMetadata() {
    return {
      'captureTime': DateTime.now().toIso8601String(),
      'device': 'Web Browser',
      'platform': html.window.navigator.platform,
      'userAgent': html.window.navigator.userAgent,
      'screenWidth': html.window.screen?.width,
      'screenHeight': html.window.screen?.height,
    };
  }
}
