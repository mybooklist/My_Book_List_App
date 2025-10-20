// ignore_for_file: library_private_types_in_public_api, avoid_print, unused_element, use_build_context_synchronously, await_only_futures

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' as root_bundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_book_list/app_colors.dart';
import 'package:my_book_list/recursos/telas/Detalhes.dart';
import 'package:my_book_list/recursos/components/Livro_card.dart';
import 'package:my_book_list/recursos/telas/adicionar_livro.dart';
import 'package:my_book_list/autenticacao.dart';


class Livros extends StatefulWidget {
  const Livros({super.key});

  @override
  _LivrosState createState() => _LivrosState();
}

class _LivrosState extends State<Livros> {
  final Autenticacao _autenticacao = Autenticacao();
  bool _estaLogado = false;

  List<dynamic> livros = [];
  String selectedFilter = 'Todos';
  bool isLoading = true;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _carregarTodosOsLivros();
    _checkAuthStatus();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        _loadMoreLivros();
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    final loggedIn = await _autenticacao.estaLogado();
    setState(() {
      _estaLogado = loggedIn;
    });
  }

  // Método para carregar todos os livros (JSON + Shared Preferences)
  Future<void> _carregarTodosOsLivros() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Carrega livros do JSON e do Shared Preferences simultaneamente
      final [livrosJson, livrosSalvos] = await Future.wait([
        _carregarLivrosDoJson(),
        _carregarLivros(),
      ]);

      // Combina os livros, evitando duplicatas por ID
      final todosLivros = <dynamic>[];
      final idsAdicionados = <String>{};

      // Primeiro adiciona os livros salvos (mais recentes)
      for (var livro in livrosSalvos) {
        final id = livro['id']?.toString();
        if (id != null && !idsAdicionados.contains(id)) {
          todosLivros.add(livro);
          idsAdicionados.add(id);
        }
      }

      // Depois adiciona os livros do JSON que não foram sobrescritos
      for (var livro in livrosJson) {
        final id = livro['id']?.toString();
        if (id != null && !idsAdicionados.contains(id)) {
          todosLivros.add(livro);
          idsAdicionados.add(id);
        }
      }

      setState(() {
        livros = todosLivros;
        livrosVisiveis = livros.take(pageSize).toList();
        currentPage = 1;
        isLoading = false;
      });

      print(
        '${livrosJson.length} livros do JSON + ${livrosSalvos.length} livros salvos = ${livros.length} livros totais',
      );
    } catch (e) {
      print('❌ Erro ao carregar livros: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Método para carregar livros do JSON
  Future<List<dynamic>> _carregarLivrosDoJson() async {
    try {
      final jsonData = await root_bundle.rootBundle.loadString(
        'lib/recursos/json/livros.json',
      );

      final Map<String, dynamic> jsonMap = json.decode(jsonData);
      final List<dynamic> jsonList = jsonMap['livros'];

      // Garante que todos os livros do JSON tenham IDs
      return jsonList.map((livro) {
        return {
          ...livro,
          'id':
              livro['id'] ??
              _gerarIdParaLivroJson(livro), // Gera ID baseado no conteúdo
          'fonte': 'json', // Marca como vindo do JSON
        };
      }).toList();
    } catch (e) {
      print('Erro ao carregar JSON: $e');
      return [];
    }
  }

  // Gera um ID estável para livros do JSON baseado no título e autor
  String _gerarIdParaLivroJson(Map<String, dynamic> livro) {
    final titulo = livro['titulo'] ?? '';
    final autor = livro['autor'] ?? '';
    return 'json_${titulo.hashCode}_${autor.hashCode}';
  }

  // Método para carregar livros do Shared Preferences
  Future<List<dynamic>> _carregarLivros() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? livrosJson = prefs.getString('livros');


      if (livrosJson != null && livrosJson.isNotEmpty) {
      final List<dynamic> livrosSalvos = json.decode(livrosJson);
      print('📖 Carregados ${livrosSalvos.length} livros do Shared Preferences');
      return livrosSalvos.map((livro) {
        return {
          ...livro,
          'fonte': 'usuario',
          'id': livro['id']?.toString() ?? 'usuario_${DateTime.now().millisecondsSinceEpoch}',
        };
      }).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao carregar do Shared Preferences: $e');
      return [];
    }
  }

  // Método para salvar TODOS os livros no Shared Preferences
  Future<void> _salvarTodosOsLivros() async {
    try {
      final prefs = await SharedPreferences.getInstance();

    // Filtra apenas livros de usuário para salvar
    final livrosUsuario = livros
        .where((livro) => livro['fonte'] == 'usuario')
        .toList();

      print('💾 Salvando ${livrosUsuario.length} livros de usuário...');

      await prefs.setString('livros', json.encode(livrosUsuario));
      print('✅ ${livrosUsuario.length} livros de usuário salvos no Shared Preferences');
      
    final verificar = await prefs.getString('livros');
    if (verificar != null) {
      final listaSalva = json.decode(verificar);
      print('📊 DEBUG: ${listaSalva.length} livros salvos na memória');
    }
    } catch (e) {
      print('Erro ao salvar livros: $e');
    }
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

  // Método para atualizar um livro na lista
  void _atualizarLivro(Map<String, dynamic> livroEditado) {
    final index = livros.indexWhere(
      (livro) => livro['id'] == livroEditado['id'],
    );
    if (index != -1) {
      setState(() {

        livros[index] = {
        ...livros[index], // Mantém campos existentes
        ...livroEditado,  // Aplica as atualizações
        'fonte': 'usuario', // Garante que continua como usuário
      };

        // Quando atualiza, marca como livro de usuário
        //livros[index] = {...livroEditado, 'fonte': 'usuario'};

        // Atualiza também na lista visível se estiver lá
      final visIndex = livrosVisiveis.indexWhere((livro) => livro['id'] == livroEditado['id']);
      if (visIndex != -1) {
        livrosVisiveis[visIndex] = {
          ...livrosVisiveis[visIndex],
          ...livroEditado,
          'fonte': 'usuario',
        };
      }
      });

      // Salva apenas livros de usuário no Shared Preferences
      _salvarTodosOsLivros();

      _mostrarNotificacao('Livro atualizado com sucesso!', Colors.green);
    }
  }

  // Método para excluir um livro da lista
  void _excluirLivro(String livroId) {
    setState(() {
      livros.removeWhere((livro) => livro['id'] == livroId);
      livrosVisiveis.removeWhere((livro) => livro['id'] == livroId);
    });

    // Salva apenas livros de usuário no Shared Preferences
    _salvarTodosOsLivros();

    _mostrarNotificacao('Livro excluído com sucesso!', Colors.green);
  }

  // Método para adicionar um novo livro
  void _adicionarLivro(Map<String, dynamic> novoLivro) {
    setState(() {
      final livroComId = {
      ...novoLivro,
      'id': 'usuario_${DateTime.now().millisecondsSinceEpoch}',
      'fonte': 'usuario',
    };
    
    livros.insert(0, livroComId);
    livrosVisiveis = getFiltroLivros().take(pageSize).toList();
    currentPage = 1;
    });

    // Salva as alterações no Shared Preferences
    _salvarTodosOsLivros();

    _mostrarNotificacao('Livro adicionado com sucesso!', Colors.green);
  }

  // Método para recarregar os livros (útil para debug)
  Future<void> _recarregarLivros() async {
    setState(() {
      isLoading = true;
    });
    await _carregarTodosOsLivros();
  }

  // Método para mostrar notificação no meio da tela
void _mostrarNotificacao(String mensagem, Color cor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        mensagem,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: cor,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.4,
        left: 50,
        right: 50,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

  // No _fazerLogin (versão sem método helper)
  Future<void> _fazerLogin() async {
  try {
    print('🎯 Clicou no botão de login');
    final emailUsuario = await _autenticacao.entrarComEmail();
    print('📧 Email retornado: $emailUsuario');
    
    if (emailUsuario != null && mounted) {
      print('✅ Vai atualizar o estado para logado');
      setState(() {
        _estaLogado = true;
      });
      _mostrarNotificacao('Login realizado com sucesso!', Colors.green);
    }
  } catch (e) {
    print('❌ Erro no login: $e');
    _mostrarNotificacao('Erro ao fazer login', Colors.red);
  }
}

// Método de logout
Future<void> _logout() async {
  try {
    await _autenticacao.sair();
    setState(() {
      _estaLogado = false;
    });
    _mostrarNotificacao('Logout realizado com sucesso!', Colors.blue);
  } catch (e) {
    print('❌ Erro no logout: $e');
    _mostrarNotificacao('Erro ao fazer logout', Colors.red);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 60,
            height: 60,
            child: Image.asset(
              'lib/recursos/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          'My Book List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _estaLogado ? Icons.logout : Icons.login,
              color: Colors.white,
            ),
            onPressed: _estaLogado ? _logout : _fazerLogin, // Métodos ajustados
            tooltip: _estaLogado ? 'Sair' : 'Entrar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos', Icons.article_rounded),
                  _buildFilterChip('Lido', Icons.book_rounded),
                  _buildFilterChip('Lendo', Icons.auto_stories_rounded),
                  _buildFilterChip('Quero ler', Icons.bookmark_rounded),
                ],
              ),
            ),
          ),

          // Busca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por título ou autor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.secondary,
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

          // Contador de livros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${getFiltroLivros().length} livro(s) encontrado(s)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (selectedFilter != 'Todos')
                  Text(
                    'Filtro: $selectedFilter',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista de livros em Grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      final livrosFiltrados = getFiltroLivros();

                      if (livrosFiltrados.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isNotEmpty
                                    ? 'Nenhum livro encontrado para "$searchQuery"'
                                    : selectedFilter != 'Todos'
                                    ? 'Nenhum livro com status "$selectedFilter"'
                                    : 'Nenhum livro cadastrado',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              if (livros.isEmpty)
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AdicionarLivro(),
                                      ),
                                    );
                                  },
                                  child: const Text('Adicionar primeiro livro'),
                                ),
                            ],
                          ),
                        );
                      }

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
                              onTap: () async {
                                final resultado = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Detalhes(
                                      livro: livro,
                                    ), // Agora passa o map completo
                                  ),
                                );

                                if (resultado != null) {
                                  if (resultado['acao'] == 'excluir') {
                                    _excluirLivro(resultado['livroId']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Livro excluído com sucesso!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else if (resultado['acao'] == 'editar') {
                                    _atualizarLivro(resultado['livro']);
                                    await _carregarTodosOsLivros();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Livro atualizado com sucesso!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Livro_card(
                                titulo: livro['titulo'] ?? 'Sem título',
                                autor: livro['autor'] ?? 'Autor desconhecido',
                                status: livro['status'] ?? 'Sem status',
                                imagem: livro['imagem'] ?? '',
                              ),
                            );
                          } else {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
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
      floatingActionButton: _estaLogado
          ? FloatingActionButton(
              onPressed: () async {
                final novoLivro = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdicionarLivro(),
                  ),
                );

                if (novoLivro != null) {
                  _adicionarLivro(novoLivro);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Livro adicionado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return FilterChip(
      avatar: Icon(
        icon,
        size: 20,
        color: selectedFilter == label ? Colors.white : AppColors.secondary,
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
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.secondary,
      checkmarkColor: Colors.transparent,
      showCheckmark: false,
      elevation: 0,
      pressElevation: 0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
