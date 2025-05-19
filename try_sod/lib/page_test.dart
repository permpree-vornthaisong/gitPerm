import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:try_sod/printer_component.dart';
import 'package:try_sod/printer_provider.dart';

class page_test extends StatefulWidget {
  const page_test({super.key});

  @override
  State<page_test> createState() => _page_testState();
}

class _page_testState extends State<page_test> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // เรียก initialize เพื่อสแกนหาเครื่องพิมพ์
      await Provider.of<PrinterProvider>(context, listen: false)
          .initialize(context);

      // โหลดชื่อเครื่องพิมพ์จากฐานข้อมูล
      await Provider.of<PrinterProvider>(context, listen: false)
          .loadDeviceNameFromDb();

      // เชื่อมต่อกับเครื่องพิมพ์ที่เลือก (ถ้ามี)
      await Provider.of<PrinterProvider>(context, listen: false)
          .connectToSelectedDevice(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Container()),
        printer_component(),
        InkWell(
          onTap: () async {
            await Provider.of<PrinterProvider>(context, listen: false)
                .printTestPage();
          },
          child: Container(
            margin: EdgeInsets.all(10),
            height: 50,
            width: 200,
            color: Colors.greenAccent,
            child: Center(
              child: Text("print"),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }
}
