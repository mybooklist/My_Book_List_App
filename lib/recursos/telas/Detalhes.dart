// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/material.dart';

class Detalhes extends StatelessWidget {
  final String titulo;
  final String autor;
  final String status;
  final String genero_literario;
  final String ano_publicacao;
  final String? resenha;
  final String? inicio_leitura;
  final String? fim_leitura;
  final String imagem;
  final int numero_paginas;
  final double? avaliacao; // Ex: 3.5 estrelas


  const Detalhes({
    super.key,
    required this.titulo,
    required this.autor,
    required this.status,
    required this.genero_literario,
    required this.ano_publicacao,
    this.resenha,
    this.inicio_leitura,
    this.fim_leitura,
    required this.imagem,
    required this.numero_paginas,
    required this.avaliacao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Book List"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.grid_view_outlined),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagem do livro
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imagem,
                height: 200,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Título e autor
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              autor,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),

            // Informações rápidas (páginas, avaliação, status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard("$numero_paginas", Icons.menu_book_outlined),
               _infoCard("${avaliacao?.toStringAsFixed(1) ?? "0.0"} ", Icons.star),
                _infoCard(status, Icons.check_circle_outline),
              ],
            ),
            const SizedBox(height: 16),

            // Gênero e ano
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard(genero_literario, Icons.category),
                _infoCard(ano_publicacao, Icons.calendar_today),
              ],
            ),
            const SizedBox(height: 16),

            // Resenha
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Sua Resenha sobre esse Livro",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resenha ?? "Sem resenha disponível.",
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // Datas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard("Início: ${inicio_leitura ?? "-"}", Icons.date_range),
                _infoCard("Fim: ${fim_leitura ?? "-"}", Icons.event_available),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
