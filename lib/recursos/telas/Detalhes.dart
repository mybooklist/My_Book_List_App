// ignore_for_file: file_names, non_constant_identifier_names, unnecessary_string_interpolations

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_book_list/app_colors.dart';
import 'package:my_book_list/recursos/telas/adicionar_livro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Detalhes extends StatefulWidget {
  final Map<dynamic, dynamic> livro;

  const Detalhes({
    super.key,
    required this.livro,
  });

  @override
  State<Detalhes> createState() => _DetalhesState();
}

class _DetalhesState extends State<Detalhes> {
  // Converte o livro para Map<String, dynamic> para evitar erros de tipo
  Map<String, dynamic> get livro {
    final Map<String, dynamic> converted = {};
    widget.livro.forEach((key, value) {
      converted[key.toString()] = value;
    });
    return converted;
  }

  // Helper methods para acessar os campos com segurança
  String get titulo => livro['titulo']?.toString() ?? 'Sem título';
  String get autor => livro['autor']?.toString() ?? 'Autor desconhecido';
  String get status => livro['status']?.toString() ?? 'Sem status';
  String get genero_literario => livro['genero_literario']?.toString() ?? 'Sem gênero';
  String get ano_publicacao => livro['ano_publicacao']?.toString() ?? '----';
  String? get resumo => livro['resumo']?.toString();
  String? get inicio_leitura => livro['inicio_leitura']?.toString();
  String? get fim_leitura => livro['fim_leitura']?.toString();
  String get imagem => livro['imagem']?.toString() ?? '';
  String get numero_paginas => livro['numero_paginas']?.toString() ?? 'Não informado';
  String? get avaliacao => livro['avaliacao']?.toString();

  // mapa constante
  static const Map<String, String> _genreIcons = {
    'literatura estrangeira': 'lib/recursos/images/globe.png',
    'suspense e mistério': 'lib/recursos/images/thriller.png',
    'crime e investigação': 'lib/recursos/images/investigation.png',
    'ficção e história': 'lib/recursos/images/writing.png',
    'fantasia e aventura': 'lib/recursos/images/witch-hat.png',
    'romance': 'lib/recursos/images/like.png',
    'terror': 'lib/recursos/images/bat.png',
  };

  // Método para excluir livro do Shared Preferences
  Future<void> _excluirLivro() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? livrosJson = prefs.getString('livros');
      
      if (livrosJson != null) {
        List<dynamic> livrosList = json.decode(livrosJson);
        
        // Remove o livro da lista
        livrosList.removeWhere((livro) => livro['id'] == this.livro['id']);
        
        // Salva a lista atualizada
        await prefs.setString('livros', json.encode(livrosList));
        
        print('Livro excluído com sucesso!');
        
        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Livro excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Retorna para a tela anterior com ação de exclusão
        if (mounted) {
          Navigator.pop(context, {
            'acao': 'excluir', 
            'livroId': this.livro['id']?.toString() ?? ''
          });
        }
      }
    } catch (e) {
      print('Erro ao excluir livro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir livro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método para atualizar livro no Shared Preferences
  Future<void> _atualizarLivro(Map<dynamic, dynamic> livroEditado) async {
    try {
      // Converte para Map<String, dynamic>
      final Map<String, dynamic> livroConvertido = {};
      livroEditado.forEach((key, value) {
        livroConvertido[key.toString()] = value;
      });

      final prefs = await SharedPreferences.getInstance();
      final String? livrosJson = prefs.getString('livros');
      
      if (livrosJson != null) {
        List<dynamic> livrosList = json.decode(livrosJson);
        
        // Encontra o índice do livro e atualiza
        final int index = livrosList.indexWhere((livro) => 
          livro['id']?.toString() == this.livro['id']?.toString()
        );
        
        if (index != -1) {
          // Mantém o ID original e atualiza os outros campos
          livrosList[index] = {
            ...livrosList[index],
            ...livroConvertido,
          };
          
          // Salva a lista atualizada
          await prefs.setString('livros', json.encode(livrosList));
          
          print('Livro atualizado com sucesso!');
          
          // Mostra mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Livro atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao atualizar livro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar livro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // retorna um Widget (Image.asset); tamanho padrão ajustável
  Widget getGenreIcon(String genero_literario, {double size = 18}) {
    final path =
        _genreIcons[genero_literario.toLowerCase()] ?? 'assets/images/help.png';
    return Image.asset(
      path,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.help_outline, size: size),
    );
  }

  Widget _buildImagem(String path) {
    if (path.startsWith('lib/recursos/images')) {
      return Image.asset(
        path,
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
      );
    } else {
      return Image.file(
        File(path),
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
      );
    }
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
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir livro'),
        content: const Text(
          'Tem certeza que deseja excluir este livro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fecha o diálogo
              _excluirLivro(); // executa a exclusão
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _editarLivro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdicionarLivro(
          livroExistente: livro, // Já está convertido para Map<String, dynamic>
        ),
      ),
    ).then((livroEditado) {
      if (livroEditado != null) {
        // Atualiza o livro no Shared Preferences
        _atualizarLivro(livroEditado);
        
        // Retorna para a tela anterior com os dados atualizados
        //Navigator.pop(context, {
          //'acao': 'editar',
          //'livro': livroEditado,
        //});
      }
    });
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
                _editarLivro();
              } else if (value == 'excluir') {
                _confirmarExclusao();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'editar', child: Text('Editar')),
              const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
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
              child: _buildImagem(imagem),
            ),
            const SizedBox(height: 16),

            // Título e autor
            Text(
              titulo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              autor,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Informações rápidas (páginas, avaliação, status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard(
                  numero_paginas,
                  Icon(
                    Icons.menu_book_outlined,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                _infoCard(
                  avaliacao ?? "Sem avaliação",
                  Icon(
                    Icons.favorite_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                _infoCard(
                  status,
                  Icon(
                    _getStatusIcon(status),
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gênero e ano
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard(
                  genero_literario,
                  getGenreIcon(genero_literario, size: 18),
                ),
                _infoCard(
                  ano_publicacao,
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
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
                _infoCard(
                  "Início: ${inicio_leitura ?? "-"}",
                  Icon(
                    Icons.date_range,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                _infoCard(
                  "Fim: ${fim_leitura ?? "-"}",
                  Icon(
                    Icons.event_available,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}