import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:try_sod/newpage.dart';
import 'package:try_sod/newpage_provider.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => NewPageProvider()), // page provider
      ],
      child: MaterialApp(
        home: Scaffold(
          body: NewPage(), // เปลี่ยนเป็น page ที่ต้องการ
        ),
      ),
    );
  }
}
