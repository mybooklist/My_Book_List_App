// ignore_for_file: library_private_types_in_public_api, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' as root_bundle;
import 'package:my_book_list/app_colors.dart';
import 'package:my_book_list/recursos/telas/Detalhes.dart';
import 'package:my_book_list/recursos/components/Livro_card.dart';
import 'package:my_book_list/recursos/telas/adicionar_livro.dart';

class Livros extends StatefulWidget {
  const Livros({super.key});

  @override
  _LivrosState createState() => _LivrosState();
}

class _LivrosState extends State<Livros> {
  List<dynamic> livros = [];
  String selectedFilter = 'Todos';
  bool isLoading = true;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadLivrosFromJson();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        _loadMoreLivros();
      }
    });
  }

  void _loadMoreLivros() {
    if (livrosVisiveis.length >= livros.length) return;

    setState(() => isLoadingMore = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      final start = currentPage * pageSize;
      final end = start + pageSize;
      final novosLivros = livros.sublist(
        start,
        end > livros.length ? livros.length : end,
      );

      setState(() {
        livrosVisiveis.addAll(novosLivros);
        currentPage++;
        isLoadingMore = false;
      });
    });
  }

  final ScrollController _scrollController = ScrollController();
  List<dynamic> livrosVisiveis = [];
  int pageSize = 4;
  int currentPage = 0;
  bool isLoadingMore = false;

  Future<void> loadLivrosFromJson() async {
    try {
      final jsonData = await root_bundle.rootBundle.loadString(
        'lib/recursos/json/livros.json',
      );

      final Map<String, dynamic> jsonMap = json.decode(jsonData);
      final List<dynamic> jsonList = jsonMap['livros'];

      setState(() {
        livros = jsonList;
        livrosVisiveis = livros.take(pageSize).toList();
        currentPage = 1;
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
    List<dynamic> filtrados = selectedFilter == 'Todos'
        ? livros
        : livros.where((livro) => livro['status'] == selectedFilter).toList();

    if (searchQuery.isNotEmpty) {
      filtrados = filtrados.where((livro) {
        final titulo = livro['titulo']?.toLowerCase() ?? '';
        final autor = livro['autor']?.toLowerCase() ?? '';
        return titulo.contains(searchQuery) || autor.contains(searchQuery);
      }).toList();
    }

    return filtrados;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'lib/recursos/images/my-book-list.png', // substitua pelo seu caminho
            height: 30,
            width: 30,
          ),
        ),
        title: const Text(
          'My Book List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por título ou autor...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.accent, // cor quando selecionado
                    width: 2.0,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      final livrosFiltrados = getFiltroLivros()
                          .where((livro) => livrosVisiveis.contains(livro))
                          .toList();

                      return GridView.builder(
                        controller: _scrollController,
                        itemCount:
                            livrosFiltrados.length + (isLoadingMore ? 1 : 0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.55,
                            ),
                        itemBuilder: (context, index) {
                          if (index < livrosFiltrados.length) {
                            final livro = livrosFiltrados[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Detalhes(
                                      titulo: livro['titulo'] ?? 'Sem título',
                                      autor:
                                          livro['autor'] ??
                                          'Autor desconhecido',
                                      status: livro['status'] ?? 'Sem status',
                                      genero_literario:
                                          livro['genero_literario'] ??
                                          'Sem gênero',
                                      ano_publicacao:
                                          livro['ano_publicacao'] ?? '----',
                                      resumo: livro['resumo'],
                                      inicio_leitura: livro['inicio_leitura'],
                                      fim_leitura: livro['fim_leitura'],
                                      imagem: livro['imagem'] ?? '',
                                      numero_paginas:
                                          livro['numero_paginas']?.toString() ??
                                          'Não informado',
                                      avaliacao:
                                          livro['avaliacao']?.toString() ??
                                          'Sem avaliação',
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
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      // Botão adicionar
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final novoLivro = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdicionarLivro()),
          );

          if (novoLivro != null) {
            setState(() {
              livros.insert(0, novoLivro);
              livrosVisiveis.insert(0, novoLivro);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Livro adicionado com sucesso!')),
            );
          }
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
      selectedColor: AppColors.accent, // cor de fundo quando selecionado
      checkmarkColor: Colors.transparent, // garante que não apareça check
      showCheckmark: false, // remove o check
      elevation: 0, // remove sombra
      pressElevation: 0, // remove sombra ao pressionar
    );
  }

  Widget _buildCounter(String title, String count) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
