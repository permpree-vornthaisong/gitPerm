import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

// ฟังก์ชันนับความยาวตัวอักษรภาษาไทย (ไม่นับวรรณยุกต์/สระลอย)
Future<int> lengthDataThai(String data) async {
  int outL = data.length;
  const skipChars = [
    "่",
    "้",
    "๊",
    "๋",
    "ุ",
    "ู",
    "ั",
    "ิ",
    "ี",
    "ื",
    "ึ",
    "็"
  ];
  for (var ch in data.split('')) {
    if (skipChars.contains(ch)) outL--;
  }
  return outL;
}

Future<Uint8List> gen_pdf_with_image(List<String> values) async {
  // โหลดฟอนต์ Sarabun-ExtraBoldItalic.ttf จาก assets
  final fontData =
      await rootBundle.load('assets/font/Sarabun-ExtraBoldItalic.ttf');
  final fontBytes = fontData.buffer.asUint8List();
  final thaiFont = PdfTrueTypeFont(fontBytes, 22, style: PdfFontStyle.italic);

  // สร้าง PDF document ใหม่
  final pdf = PdfDocument();
  pdf.pageSettings.size = const Size(600, 400);
  pdf.pageSettings.margins.all = 0.0;

  final page = pdf.pages.add();
  double y = 0;
  const double lineHeight = 35.0; // Changed to double

  // วาดรูปโลโก้ (ถ้ามี)
  try {
    final imageData = await rootBundle.load('assets/img/logo-4.png');
    final imageBytes = imageData.buffer.asUint8List();
    final PdfBitmap logo = PdfBitmap(imageBytes);
    final logoX = (600 - 80) / 2;
    page.graphics.drawImage(logo, Rect.fromLTWH(logoX, y, 80, 80));
    y += 80 + 8;
  } catch (_) {
    // ไม่แสดงรูปถ้าโหลดไม่ได้
  }

  // วาดข้อความแต่ละบรรทัด
  final safeValues = values.isNotEmpty ? values : ['(ไม่มีข้อมูล)'];
  for (final v in safeValues) {
    int len = await lengthDataThai(v);
    final textWidth = len * 11.52;
    final x = (600 - textWidth) / 2;

    page.graphics.drawString(
      v,
      thaiFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(x, y, textWidth, lineHeight), // Removed cast
    );
    y += lineHeight;
  }

  final pdfBytes = Uint8List.fromList(await pdf.save());
  pdf.dispose();
  return pdfBytes;
}
