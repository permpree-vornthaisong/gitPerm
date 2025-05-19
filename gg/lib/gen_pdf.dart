import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:barcode/barcode.dart' as BAR;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

// ฟังก์ชันสร้าง PDF พร้อมข้อความภาษาไทยและจัดตำแหน่ง
Future<Uint8List> gen_pdf() async {
  // โหลดฟอนต์ Sarabun-ExtraBoldItalic.ttf จาก assets
  final fontData =
      await rootBundle.load('assets/font/Sarabun-ExtraBoldItalic.ttf');
  final fontBytes = fontData.buffer.asUint8List();

  // สร้างอ็อบเจกต์ฟอนต์สำหรับใช้ใน PDF
  final thaiFont = PdfTrueTypeFont(fontBytes, 22, style: PdfFontStyle.italic);

  // สร้าง PDF document ใหม่
  final pdf = PdfDocument();
  pdf.pageSettings.size = const Size(600, 400);
  pdf.pageSettings.margins.all = 0.0;

  double y = 0;
  String dataBuff = "";

  // เพิ่มหน้าใหม่ใน PDF
  final page = pdf.pages.add();

  // วาดข้อความเส้นคั่น
  dataBuff = "--------------------------------------------------------- ";
  int len = await lengthDataThai(dataBuff);
  y += 20;
  page.graphics.drawString(
    dataBuff,
    thaiFont,
    brush: PdfBrushes.black,
    bounds: Rect.fromLTWH(0, y, 500, 100),
  );

  // วาดข้อความ "สวัสดี ไทยแลน จัดกลาง" จัดกึ่งกลาง
  dataBuff = "สวัสดี ไทยแลน จัดกลาง ";
  len = await lengthDataThai(dataBuff);
  y += 100;
  page.graphics.drawString(
    dataBuff,
    thaiFont,
    brush: PdfBrushes.black,
    bounds: Rect.fromLTWH((375 / 2) - len * 5.76, y, 375, 100),
  );

  // วาดข้อความ "สวัสดี ไทยแลน จัดข้าง" ชิดขวา
  dataBuff = "สวัสดี ไทยแลน จัดข้าง ";
  len = await lengthDataThai(dataBuff);
  y += 35;
  page.graphics.drawString(
    dataBuff,
    thaiFont,
    brush: PdfBrushes.black,
    bounds: Rect.fromLTWH(375 - len * 12, y, 375, 100),
  );

  // บันทึก PDF เป็น Uint8List แล้วคืนค่า
  final pdfBytes = Uint8List.fromList(await pdf.save());
  pdf.dispose();
  return pdfBytes;
}

// ฟังก์ชันสร้าง Barcode เป็นรูปภาพ Uint8List
Future<Uint8List> buildBarcode(
  BAR.Barcode bc,
  String data,
  String type, {
  double? fontHeight,
}) async {
  final svg = bc.toSvg(
    data,
    width: type == "QRCODE" ? 120 : 200,
    height: type == "QRCODE" ? 120 : 80,
    fontHeight: fontHeight,
  );
  final imageData = await svgToUint8List(
    svg,
    type == "QRCODE" ? 120 : 200,
    type == "QRCODE" ? 120 : 80,
  );
  if (imageData != null) {
    return imageData;
  } else {
    throw Exception('Failed to convert SVG to Uint8List');
  }
}

// ฟังก์ชันแปลง SVG เป็น Uint8List (PNG)
Future<Uint8List?> svgToUint8List(String rawSvg, int width, int height) async {
  try {
    final svgLoader = SvgStringLoader(rawSvg);
    final pictureInfo = await vg.loadPicture(svgLoader, null);
    final ui.Image image = await pictureInfo.picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    pictureInfo.picture.dispose();
    return byteData?.buffer.asUint8List();
  } catch (e) {
    print("Error converting SVG to Uint8List: $e");
    return null;
  }
}

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
