// ignore_for_file: file_names, non_constant_identifier_names, unnecessary_string_interpolations

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
  final String numero_paginas;
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
              child: Image.asset(
                imagem,
                height: 280,
                width: 200,
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
                _infoCard("$numero_paginas", Icon(Icons.menu_book_outlined, size: 18, color: Colors.grey[700])),
                _infoCard("${avaliacao?.toStringAsFixed(1) ?? "0.0"} ", Icon(Icons.star, size: 18, color: Colors.grey[700])),
                _infoCard(status, Icon(_getStatusIcon(status), size: 18, color: Colors.grey[700])),

              ],
            ),
            const SizedBox(height: 16),

            // Gênero e ano
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //_infoCard(genero_literario, _getGenreIcon(genero_literario)),
                _infoCard(genero_literario, getGenreIcon(genero_literario)),
                _infoCard(ano_publicacao, Icon(Icons.calendar_today, size: 18, color: Colors.grey[700])),
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
              resenha ?? "Você ainda não adicionou uma resenha sobre esse livro.",
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // Datas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard("Início: ${inicio_leitura ?? "-"}", Icon(Icons.date_range, size: 18, color: Colors.grey[700])),
                _infoCard("Fim: ${fim_leitura ?? "-"}", Icon(Icons.event_available, size: 18, color: Colors.grey[700])),
              ],
            ),
          ],
        ),
      ),
    );
  }

    //função para pegar os icones de cada status
    IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'lido':
        return Icons.book_rounded;  
      case 'lendo':
        return Icons.auto_stories_rounded; 
      case 'quero ler':
        return Icons.bookmark_rounded; 
      default:
        return Icons.help_outline; // caso não reconheça
      }
    }

    //função para pegar os ícones de cada genero

static const Map<String, String> genreIcons = {
  'literatura estrangeira': 'lib/recursos/images/books.png',
  'suspense e mistério': 'lib/recursos/images/thriller.png',
  'crime e investigação': 'lib/recursos/images/crime-scene.png',
  'ficção e história': 'lib/recursos/images/parchment.png',
  'fantasia e aventura': 'lib/recursos/images/hat.png',
  'romance': 'lib/recursos/images/love.png',
  'terror': 'lib/recursos/images/ghost.png',
};

Widget getGenreIcon(String genero_literario) {
  String path = genreIcons[genero_literario.toLowerCase()] ?? 'assets/images/help.png';

  return Image.asset(
    path,
    width: 24,
    height: 24,
  );
}



  Widget _infoCard(String text, Widget icon) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade400),
    ),
    child: Row(
      children: [
        icon, // agora pode ser tanto Icon quanto Image.asset
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
