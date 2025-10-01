// ignore_for_file: file_names, non_constant_identifier_names, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:my_book_list/App_colors.dart';

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

  // mapa constante (agora é compile-time constant, permite manter o construtor const)
  static const Map<String, String> _genreIcons = {
    'literatura estrangeira': 'lib/recursos/images/globe.png',
    'suspense e mistério': 'lib/recursos/images/thriller.png',
    'crime e investigação': 'lib/recursos/images/investigation.png',
    'ficção e história': 'lib/recursos/images/writing.png',
    'fantasia e aventura': 'lib/recursos/images/witch-hat.png',
    'romance': 'lib/recursos/images/like.png',
    'terror': 'lib/recursos/images/bat.png',
  };

  // retorna um Widget (Image.asset); tamanho padrão ajustável
  Widget getGenreIcon(String genero_literario, {double size = 18}) {
    final path = _genreIcons[genero_literario.toLowerCase()] ?? 'assets/images/help.png';
    return Image.asset(
      path,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.help_outline, size: size),
    );
  }

  // função para pegar os icones de cada status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'lido':
        return Icons.book_rounded;
      case 'lendo':
        return Icons.auto_stories_rounded;
      case 'quero ler':
        return Icons.bookmark_rounded;
      default:
        return Icons.help_outline;
    }
  }

  // agora aceita Widget para suportar Icon(...) ou Image.asset(...)
  Widget _infoCard(String text, Widget icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textSecondary),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

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
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Informações rápidas (páginas, avaliação, status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard("$numero_paginas", Icon(Icons.menu_book_outlined, size: 18, color: Colors.grey[700])),
                _infoCard("${avaliacao?.toStringAsFixed(1) ?? "0.0"}", Icon(Icons.star, size: 18, color: Colors.grey[700])),
                _infoCard(status, Icon(_getStatusIcon(status), size: 18, color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 16),

            // Gênero e ano
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard(genero_literario, getGenreIcon(genero_literario, size: 18)),
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
                  fontSize: 16,
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
}
