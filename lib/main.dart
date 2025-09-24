import 'package:flutter/material.dart';
import 'package:my_book_list/recursos/telas/Livros.dart';

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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Livros(), // Página inicial
      debugShowCheckedModeBanner: false,
    );
  }
}



  