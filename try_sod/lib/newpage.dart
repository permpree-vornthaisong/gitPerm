import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'newpage_provider.dart';
import 'pdf_helper.dart';
import 'package:printing/printing.dart'; // ต้องเพิ่มใน pubspec.yaml ด้วย

class NewPage extends StatefulWidget {
  const NewPage({super.key});

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
  final controller3 = TextEditingController();
  final controller4 = TextEditingController();
  final controller5 = TextEditingController();

  late Future<void> _initDbFuture;

  @override
  void initState() {
    super.initState();
    _initDbFuture =
        Provider.of<NewPageProvider>(context, listen: false).initDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Page')),
      body: FutureBuilder(
        future: _initDbFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: controller1,
                    decoration: const InputDecoration(labelText: 'Value 1'),
                  ),
                  TextField(
                    controller: controller2,
                    decoration: const InputDecoration(labelText: 'Value 2'),
                  ),
                  TextField(
                    controller: controller3,
                    decoration: const InputDecoration(labelText: 'Value 3'),
                  ),
                  TextField(
                    controller: controller4,
                    decoration: const InputDecoration(labelText: 'Value 4'),
                  ),
                  TextField(
                    controller: controller5,
                    decoration: const InputDecoration(labelText: 'Value 5'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final provider =
                          Provider.of<NewPageProvider>(context, listen: false);
                      await provider.addValue(controller1.text);
                      await provider.addValue(controller2.text);
                      await provider.addValue(controller3.text);
                      await provider.addValue(controller4.text);
                      await provider.addValue(controller5.text);
                      await provider.loadValues(); // โหลดค่าจาก SQLite ใหม่
                      controller1.clear();
                      controller2.clear();
                      controller3.clear();
                      controller4.clear();
                      controller5.clear();
                    },
                    child: const Text('Add All Values'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final provider =
                          Provider.of<NewPageProvider>(context, listen: false);
                      // ดึงค่าทั้งหมดจาก provider.items
                      final allValues =
                          provider.items.map((e) => e.value).toList();

                      // สร้าง PDF
                      final pdfBytes = await gen_pdf_with_image(allValues);

                      // แสดง dialog preview หรือสั่ง print เลย
                      await Printing.layoutPdf(
                          onLayout: (format) async => pdfBytes);
                    },
                    child: const Text('Print All'),
                  ),
                  const SizedBox(height: 20),
                  Consumer<NewPageProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: provider.items
                            .map((item) => Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            'uid: ${item.id} - ${item.value}')),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        await provider.deleteValue(item.id);
                                      },
                                    ),
                                  ],
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
