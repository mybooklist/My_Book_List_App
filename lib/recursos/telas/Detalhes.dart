// ignore_for_file: file_names, non_constant_identifier_names, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:my_book_list/app_colors.dart';
import 'package:my_book_list/recursos/telas/adicionar_livro.dart';

class Detalhes extends StatelessWidget {
  final String titulo;
  final String autor;
  final String status;
  final String genero_literario;
  final String ano_publicacao;
  final String? resumo;
  final String? inicio_leitura;
  final String? fim_leitura;
  final String imagem;
  final String numero_paginas;
  final String? avaliacao; 

  const Detalhes({
    super.key,
    required this.titulo,
    required this.autor,
    required this.status,
    required this.genero_literario,
    required this.ano_publicacao,
    this.resumo,
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
        border: Border.all(color: AppColors.cinza2),
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
          actions: [
    PopupMenuButton<String>(
      icon: const Icon(Icons.keyboard_control_rounded),
      onSelected: (value) {
        if (value == 'editar') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdicionarLivro(
                livroExistente: {
                  'titulo': titulo,
                  'autor': autor,
                  'status': status,
                  'genero_literario': genero_literario,
                  'ano_publicacao': ano_publicacao,
                  'resumo': resumo,
                  'inicio_leitura': inicio_leitura,
                  'fim_leitura': fim_leitura,
                  'imagem': imagem,
                  'numero_paginas': numero_paginas,
                  'avaliacao': avaliacao,
                },
              ),
            ),
          ).then((livroEditado) {
            if (livroEditado != null) {
              Navigator.pop(context, {
                'acao': 'editar',
                'livro': livroEditado,
              });
            }
          });
        } else if (value == 'excluir') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Excluir livro'),
              content: const Text('Tem certeza que deseja excluir este livro?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // fecha o diálogo
                    Navigator.pop(context, {'acao': 'excluir'}); // volta com ação
                  },
                  child: const Text('Excluir'),
                ),
              ],
            ),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'editar',
          child: Text('Editar'),
        ),
        const PopupMenuItem(
          value: 'excluir',
          child: Text('Excluir'),
        ),
      ],
    ),
    const SizedBox(width: 8),
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
                _infoCard("$numero_paginas", Icon(Icons.menu_book_outlined, size: 18, color: AppColors.textPrimary)),
                _infoCard(avaliacao ?? "Sem avaliação", Icon(Icons.favorite_rounded, size: 18, color: AppColors.textPrimary)),
                _infoCard(status, Icon(_getStatusIcon(status), size: 18, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),

            // Gênero e ano
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard(genero_literario, getGenreIcon(genero_literario, size: 18)),
                _infoCard(ano_publicacao, Icon(Icons.calendar_today, size: 18, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),

            // Resenha
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Seu resumo sobre esse Livro",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resumo ?? "Você ainda não adicionou um resumo sobre esse livro.",
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // Datas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard("Início: ${inicio_leitura ?? "-"}", Icon(Icons.date_range, size: 18, color: AppColors.textPrimary)),
                _infoCard("Fim: ${fim_leitura ?? "-"}", Icon(Icons.event_available, size: 18, color: AppColors.textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
