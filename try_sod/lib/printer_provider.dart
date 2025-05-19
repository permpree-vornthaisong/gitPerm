import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3_sdt/flutter_pos_printer_platform_image_3_sdt.dart';
import 'package:try_sod/pdf_to_image.dart';
import 'package:try_sod/sqlite.dart';

class PrinterProvider with ChangeNotifier {
  PrinterType defaultPrinterType = PrinterType.bluetooth;
  bool isBle = false;
  bool isConnected = false;
  final printerManager = PrinterManager.instance;
  final List<PrinterDevice> deviceList = [];
  StreamSubscription<PrinterDevice>? deviceScanSubscription;
  StreamSubscription<BTStatus>? bluetoothStatusSubscription;
  StreamSubscription<USBStatus>? usbStatusSubscription;
  USBStatus currentUsbStatus = USBStatus.none;
  List<int>? pendingTask;

  String selectedDeviceName = ""; // ไม่ fix ค่าเริ่มต้น
  final ipController = TextEditingController();
  final portController = TextEditingController();
  PrinterDevice? selectedDevice;

  // อัปเดตชื่ออุปกรณ์ที่เลือก
  void updateSelectedDeviceName(String name) {
    selectedDeviceName = name;
    saveDeviceNameToDb(name);
    notifyListeners();
  }

  // คืนชื่ออุปกรณ์ทั้งหมด
  List<String> getAllDeviceNames() {
    return deviceList.map((e) => e.deviceName ?? "").toList();
  }

  // คืนสถานะการเชื่อมต่อ
  bool get isDeviceConnected => isConnected;

  // เริ่มต้นและสแกนหาอุปกรณ์
  Future<void> initialize(BuildContext context) async {
    if (Platform.isWindows) defaultPrinterType = PrinterType.usb;
    await scanDevices();
    usbStatusSubscription = printerManager.stateUSB.listen((status) {
      currentUsbStatus = status;
      if (Platform.isAndroid &&
          status == USBStatus.connected &&
          pendingTask != null) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          printerManager.send(type: PrinterType.usb, bytes: pendingTask!);
          pendingTask = null;
        });
        notifyListeners();
      }
      notifyListeners();
    });
  }

  // สแกนหาอุปกรณ์
  Future<void> scanDevices() async {
    deviceList.clear();
    notifyListeners();
    deviceScanSubscription = printerManager
        .discovery(type: defaultPrinterType, isBle: isBle)
        .listen((device) {
      deviceList.add(PrinterDevice(
        deviceName: device.name,
        address: device.address,
        isBle: isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        type: defaultPrinterType,
      ));
      notifyListeners();
    }) as StreamSubscription<PrinterDevice>?;
  }

  // เลือกอุปกรณ์
  Future<void> selectDevice(PrinterDevice device) async {
    if (selectedDevice != null) {
      if ((device.address != selectedDevice!.address) ||
          (device.type == PrinterType.usb &&
              selectedDevice!.vendorId != device.vendorId)) {
        await printerManager.disconnect(type: selectedDevice!.type);
      }
    }
    selectedDevice = device;
    notifyListeners();
  }

  // เชื่อมต่อกับอุปกรณ์ที่เลือก
  Future<void> connectToSelectedDevice(BuildContext context) async {
    try {
      for (final device in deviceList) {
        if (device.deviceName == selectedDeviceName) {
          await selectDevice(device);
          await printerManager.connect(
            type: device.type,
            model: UsbPrinterInput(
              name: device.deviceName,
              productId: device.productId,
              vendorId: device.vendorId,
            ),
          );
          isConnected = true;
          log('Connected to printer successfully');
          break;
        }
      }
      notifyListeners();
    } catch (e) {
      isConnected = false;
      log('Error connecting to printer: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Error'),
          content:
              const Text('Failed to connect to the printer. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // ตัดการเชื่อมต่อ
  Future<void> disconnectDevice() async {
    if (selectedDevice != null) {
      await printerManager.disconnect(type: selectedDevice!.type);
      isConnected = false;
      selectedDevice = null;
      log('Disconnected from printer');
      notifyListeners();
    } else {
      log('No printer to disconnect');
    }
  }

  // สั่งพิมพ์
  void printData(List<int> bytes) async {
    if (selectedDevice == null) return;
    var device = selectedDevice!;
    switch (device.type) {
      case PrinterType.usb:
        await printerManager.connect(
            type: device.type,
            model: UsbPrinterInput(
                name: device.deviceName,
                productId: device.productId,
                vendorId: device.vendorId));
        pendingTask = null;
        break;
      default:
    }
    printerManager.send(type: device.type, bytes: bytes);
    notifyListeners();
  }

  // ตัวอย่างสั่งพิมพ์
  Future<void> printTestPage() async {
    printData(await pdf_to_img());
    notifyListeners();
  }

  // เตรียมข้อมูลอุปกรณ์จากฐานข้อมูล
  Future<void> loadDeviceNameFromDb() async {
    final handler = DatabaseHandler();
    await handler.openDatabase();
    await handler.createTable();
    List<Map<String, dynamic>> dataDb = await handler.get_printer();
    if (dataDb.isEmpty) {
      await handler.insert_printter(1, "name");
    } else {
      selectedDeviceName = dataDb[0]['name'];
      notifyListeners();
    }
  }

  // บันทึกชื่ออุปกรณ์
  Future<void> saveDeviceNameToDb(String name) async {
    final handler = DatabaseHandler();
    await handler.openDatabase();
    await handler.createTable();
    await handler.insert_printter(1, name);
    await loadDeviceNameFromDb();
  }

  @override
  void dispose() {
    deviceScanSubscription?.cancel();
    bluetoothStatusSubscription?.cancel();
    usbStatusSubscription?.cancel();
    portController.dispose();
    ipController.dispose();
    super.dispose();
  }
}

// คลาสข้อมูลอุปกรณ์เครื่องพิมพ์
class PrinterDevice {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;
  PrinterType type;
  bool? state;

  PrinterDevice({
    this.deviceName,
    this.address,
    this.port,
    this.state,
    this.vendorId,
    this.productId,
    this.type = PrinterType.bluetooth,
    this.isBle = false,
  });
}
