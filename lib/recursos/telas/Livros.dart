// ignore_for_file: library_private_types_in_public_api, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' as root_bundle;
import 'package:my_book_list/App_colors.dart';
import 'package:my_book_list/recursos/telas/Detalhes.dart';
import 'package:my_book_list/recursos/components/Livro_card.dart';

class Livros extends StatefulWidget {
  const Livros({super.key});

  @override
  _LivrosState createState() => _LivrosState();
}

class _LivrosState extends State<Livros> {
  List<dynamic> livros = [];
  String selectedFilter = 'Todos';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLivrosFromJson();
  }

  Future<void> loadLivrosFromJson() async {
    try {
      final jsonData = await root_bundle.rootBundle
          .loadString('lib/recursos/json/livros.json');

      final Map<String, dynamic> jsonMap = json.decode(jsonData);
      final List<dynamic> jsonList = jsonMap['livros'];

      setState(() {
        livros = jsonList;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar JSON: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> getFiltroLivros() {
    if (selectedFilter == 'Todos') {
      return livros;
    }
    return livros.where((livro) => livro['status'] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Book List', style: TextStyle(color: AppColors.textLight)),
        backgroundColor: AppColors.accent,
        centerTitle: true,
        elevation: 0,
        
      ),
      body: Column(
        children: [
          // Filtros
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('Todos', Icons.article_rounded),
                _buildFilterChip('Lido', Icons.book_rounded),
                _buildFilterChip('Lendo', Icons.auto_stories_rounded),
                _buildFilterChip('Quero ler', Icons.bookmark_rounded),
              ],
            ),
          ),

          // Lista de livros em Grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    itemCount: getFiltroLivros().length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.55,
                    ),
                    itemBuilder: (context, index) {
                      final livro = getFiltroLivros()[index];
                      return GestureDetector(
                        onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Detalhes(
                                  titulo: livro['titulo'] ?? 'Sem título',
                                  autor: livro['autor'] ?? 'Autor desconhecido',
                                  status: livro['status'] ?? 'Sem status',
                                  genero_literario: livro['genero_literario'] ?? 'Sem gênero',
                                  ano_publicacao: livro['ano_publicacao'] ?? '----',
                                  resenha: livro['resenha'], // agora pode ser null
                                  inicio_leitura: livro['inicio_leitura'],
                                  fim_leitura: livro['fim_leitura'],
                                  imagem: livro['imagem'] ?? '',
                                  numero_paginas: livro['numero_paginas']?.toString() ?? 'Não informado',
                                  avaliacao: (livro['avaliacao'] is num)
                                      ? (livro['avaliacao'] as num).toDouble()
                                      : 0.0,
                                ),
                              ),
                            );
                          },

                        child: Livro_card(
                          titulo: livro['titulo'],
                          autor: livro['autor'],
                          status: livro['status'],
                          imagem: livro['imagem'],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Botão flutuante
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ação para adicionar livro
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
  return FilterChip(
    avatar: Icon(
      icon,
      size: 20,
      color: selectedFilter == label ? Colors.white : AppColors.accent,
    ),
    label: Text(
      label,
      style: TextStyle(
        color: selectedFilter == label ? Colors.white : Colors.black,
      ),
    ),
    selected: selectedFilter == label,
    onSelected: (bool selected) {
      setState(() {
        selectedFilter = selected ? label : 'Todos';
      });
    },
    backgroundColor: Colors.grey[200], // cor de fundo quando não selecionado
    selectedColor: AppColors.accent,   // cor de fundo quando selecionado
    checkmarkColor: Colors.transparent, // garante que não apareça check
    showCheckmark: false,               // remove o check
    elevation: 0,                       // remove sombra
    pressElevation: 0,                  // remove sombra ao pressionar
  );
}



  Widget _buildCounter(String title, String count) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
