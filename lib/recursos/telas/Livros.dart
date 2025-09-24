import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' as root_bundle;
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
      print('❌ Erro ao carregar JSON: $e');
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
        title: const Text('My Book List'),
        backgroundColor: Colors.blue,
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
                _buildFilterChip('Todos'),
                _buildFilterChip('Lido'),
                _buildFilterChip('Lendo'),
                _buildFilterChip('Quero ler'),
              ],
            ),
          ),

          // Contadores
          /**Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCounter('Mobile', '16'),
                _buildCounter('16', '24'),
                _buildCounter('18', '18'),
              ],
            ),
          ),*/

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
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final livro = getFiltroLivros()[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Detalhes(livro: livro),
                            ),
                          );
                        },
                        child: Livro_card(
                          titulo: livro['titulo'],
                          autor: livro['autor'],
                          status: livro['status'],
                          capa: null, // se tiver imagem, passa aqui
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
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: selectedFilter == label,
      onSelected: (bool selected) {
        setState(() {
          selectedFilter = selected ? label : 'Todos';
        });
      },
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selectedFilter == label ? Colors.white : Colors.black,
      ),
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
