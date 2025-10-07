import 'package:flutter/material.dart';
import 'package:my_book_list/recursos/telas/livros.dart';
// ignore: unused_import
import 'package:my_book_list/app_colors.dart';


void main() {
  runApp(MyBookListApp());
}


class MyBookListApp extends StatelessWidget {
  const MyBookListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Book List',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Livros(), // Página inicial
      debugShowCheckedModeBanner: false,
    );
  }
}



  