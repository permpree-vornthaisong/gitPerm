import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gg/page_test.dart';
import 'package:gg/printter_provider.dart';

void main() async {
  // เรียกใช้การตั้งค่าเริ่มต้นของหน้าต่าง

  // await controlWindow.setPosition();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrinterProvider()), //page login
      ],
      child: MaterialApp(
        home: Scaffold(
          body: page_test(),
        ),
      ),
    );
  }
}
