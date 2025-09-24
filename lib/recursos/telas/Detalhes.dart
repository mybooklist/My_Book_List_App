import 'package:flutter/material.dart';

class Detalhes extends StatelessWidget {
  final Map<String, dynamic> livro;
  
  // ignore: use_super_parameters
  const Detalhes({Key? key, required this.livro}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Livro'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              livro['titulo'] ?? 'Título não disponível',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Autor: ${livro['autor'] ?? 'Não disponível'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Status: ${livro['status'] ?? 'Não disponível'}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}