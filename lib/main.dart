import 'package:flutter/material.dart';
import 'package:keygen/database/database_connection.dart';
import 'package:keygen/view/home_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseConnection.instance.database;
  WindowManager.instance.setResizable(false);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static String title = 'keyGen';
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // useMaterial3: true,
        textTheme:  Theme.of(context).textTheme.apply(
          fontFamily: 'Akaya Kanadaka',
        )
      ),
      home: const MyHomePage(),
    );
  }
}
