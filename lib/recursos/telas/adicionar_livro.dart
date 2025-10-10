// ignore_for_file: unused_field, non_constant_identifier_names, unused_element

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:my_book_list/app_colors.dart';

class AdicionarLivro extends StatefulWidget {
  final Map<String, dynamic>? livroExistente;

  const AdicionarLivro({super.key, this.livroExistente});

  @override
  State<AdicionarLivro> createState() => _AdicionarLivroState();
}

class _AdicionarLivroState extends State<AdicionarLivro> {
  final _formKey = GlobalKey<FormState>();

  String? _status;
  String? _genero_literario;
  String? _avaliacao;
  File? _imagemSelecionada;
  String _resumo = "";

  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _numero_paginasController = TextEditingController();
  final _ano_publicacaoController = TextEditingController();

  DateTime? _inicio_leitura;
  DateTime? _fim_leitura;

  @override
  void initState() {
    super.initState();

    // Define um valor padrão inicial
  //_status = 'Quero Ler'; 

    
    if (widget.livroExistente != null) {
      _tituloController.text = widget.livroExistente!['titulo'] ?? '';
      _autorController.text = widget.livroExistente!['autor'] ?? '';
      _numero_paginasController.text =
          widget.livroExistente!['numero_paginas'] ?? '';
      _ano_publicacaoController.text =
          widget.livroExistente!['ano_publicacao'] ?? '';

      // CORREÇÃO: Garantir que os valores existem nas listas
      final statusExistente = widget.livroExistente!['status'];
      _status = _statusOptions.contains(statusExistente)
          ? statusExistente
          : null;

      final generoExistente = widget.livroExistente!['genero_literario'];
      _genero_literario = _generos.contains(generoExistente)
          ? generoExistente
          : null;

      final avaliacaoExistente = widget.livroExistente!['avaliacao'];
      _avaliacao = _avaliacoes.contains(avaliacaoExistente)
          ? avaliacaoExistente
          : null;

      _resumo = widget.livroExistente!['resumo'] ?? '';

      if ((widget.livroExistente!['inicio_leitura'] ?? '').isNotEmpty) {
        final partes = widget.livroExistente!['inicio_leitura'].split('/');
        _inicio_leitura = DateTime(
          int.parse(partes[2]),
          int.parse(partes[1]),
          int.parse(partes[0]),
        );
      }
      if ((widget.livroExistente!['fim_leitura'] ?? '').isNotEmpty) {
        final partes = widget.livroExistente!['fim_leitura'].split('/');
        _fim_leitura = DateTime(
          int.parse(partes[2]),
          int.parse(partes[1]),
          int.parse(partes[0]),
        );
      }
      if ((widget.livroExistente!['imagem'] ?? '').isNotEmpty) {
        _imagemSelecionada = File(widget.livroExistente!['imagem']);
      }
    }
  }

  final List<String> _statusOptions = ['Lido', 'Lendo', 'Quero Ler'];
  final List<String> _generos = [
    'Romance',
    'Ficção e História',
    'Fantasia e Aventura',
    'Suspense e Mistério',
    'Terror',
    'Crime e Investigação',
    'Literatura Estrangeira',
  ];
  final List<String> _avaliacoes = [
    'Ótimo',
    'Muito bom',
    'Bom',
    'Regular',
    'Ruim',
  ];

  // Método para salvar livro no Shared Preferences
  Future<void> _salvarLivroNoSharedPreferences(
    Map<String, dynamic> livro,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Recupera a lista atual de livros
      final String? livrosJson = prefs.getString('livros');
      List<dynamic> livrosList = [];

      if (livrosJson != null && livrosJson.isNotEmpty) {
        livrosList = json.decode(livrosJson);
      }

      // Verifica se é edição ou novo livro
      if (widget.livroExistente != null) {
        // Modo edição - encontra o livro pelo ID e atualiza
        final String livroId = widget.livroExistente!['id'];
        final int index = livrosList.indexWhere(
          (livro) => livro['id'] == livroId,
        );

        if (index != -1) {
          livrosList[index] = {
            ...livrosList[index],
            ...livro, // Mantém o ID original e atualiza outros campos
          };
        }
      } else {
        // Modo adição - cria novo livro com ID único
        final novoLivroComId = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(), // ID único
          ...livro,
        };
        livrosList.add(novoLivroComId);
      }

      // Salva a lista atualizada no Shared Preferences
      await prefs.setString('livros', json.encode(livrosList));

      print('Livro salvo com sucesso! Total de livros: ${livrosList.length}');
    } catch (e) {
      print('Erro ao salvar livro: $e');
      throw Exception('Erro ao salvar livro: $e');
    }
  }

  // Método para carregar livros do Shared Preferences (útil para debug)
  Future<void> _carregarLivrosDoSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? livrosJson = prefs.getString('livros');

      if (livrosJson != null) {
        final List<dynamic> livrosList = json.decode(livrosJson);
        print('Livros carregados: ${livrosList.length}');
        for (var livro in livrosList) {
          print('Livro: ${livro['titulo']} - ID: ${livro['id']}');
        }
      } else {
        print('Nenhum livro salvo encontrado');
      }
    } catch (e) {
      print('Erro ao carregar livros: $e');
    }
  }

  Future<void> _selecionarData(bool inicio) async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime(2100),
    );
    if (dataSelecionada != null) {
      setState(() {
        if (inicio) {
          _inicio_leitura = dataSelecionada;
        } else {
          _fim_leitura = dataSelecionada;
        }
      });
    }
  }

  Future<void> _selecionarImagem() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
    if (imagem != null) {
      setState(() {
        _imagemSelecionada = File(imagem.path);
      });
    }
  }

  // Método para salvar o livro
  Future<void> _salvarLivro() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Mostrar loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        final Map<String, dynamic> livro = {
          'titulo': _tituloController.text,
          'autor': _autorController.text,
          'status': _status ?? 'Quero Ler',
          'genero_literario': _genero_literario ?? 'Sem gênero',
          'ano_publicacao': _ano_publicacaoController.text,
          'numero_paginas': _numero_paginasController.text,
          'avaliacao': _avaliacao ?? 'Sem avaliação',
          'inicio_leitura': _inicio_leitura != null
              ? '${_inicio_leitura!.day}/${_inicio_leitura!.month}/${_inicio_leitura!.year}'
              : '',
          'fim_leitura': _fim_leitura != null
              ? '${_fim_leitura!.day}/${_fim_leitura!.month}/${_fim_leitura!.year}'
              : '',
          'imagem': _imagemSelecionada?.path ?? '',
          'resumo': _resumo,
        };

        // Se for edição, mantém o ID original
        if (widget.livroExistente != null) {
          livro['id'] = widget.livroExistente!['id'];
        }

        // Salva no Shared Preferences
        await _salvarLivroNoSharedPreferences(livro);

        // Fecha o loading
        Navigator.pop(context);

        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.livroExistente != null
                  ? 'Livro atualizado com sucesso!'
                  : 'Livro adicionado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Para debug - carrega os livros salvos
        await _carregarLivrosDoSharedPreferences();

        // Retorna para a tela anterior
        Navigator.pop(context, livro);
      } catch (e) {
        // Fecha o loading
        Navigator.pop(context);

        // Mostra mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar livro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.livroExistente != null ? 'Editar Livro' : 'Adicionar Livro',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título do Livro'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o título' : null,
              ),
              TextFormField(
                controller: _autorController,
                decoration: const InputDecoration(labelText: 'Nome do Autor'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selecionarData(true),
                      child: Text(
                        _inicio_leitura == null
                            ? 'Início da Leitura'
                            : '${_inicio_leitura!.day}/${_inicio_leitura!.month}/${_inicio_leitura!.year}',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selecionarData(false),
                      child: Text(
                        _fim_leitura == null
                            ? 'Fim da Leitura'
                            : '${_fim_leitura!.day}/${_fim_leitura!.month}/${_fim_leitura!.year}',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Avaliação
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Avaliação'),
                value: _avaliacao,
                items: _avaliacoes
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) => setState(() => _avaliacao = v),
              ),
              Row(
                children: [
                  Expanded(
                    child: // Status da Leitura
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status da Leitura',
                      ),
                      value: _status,
                      items: _statusOptions
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _status = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _numero_paginasController,
                      decoration: const InputDecoration(labelText: 'Páginas'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: // Gênero Literário
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Gênero Literário',
                      ),
                      value: _genero_literario,
                      items: _generos
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _genero_literario = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _ano_publicacaoController,
                      decoration: const InputDecoration(labelText: 'Ano'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _selecionarImagem,
                icon: const Icon(
                  Icons.image_outlined,
                  color: AppColors.textPrimary,
                ),
                label: const Text(
                  'Selecionar imagem de capa (PNG, JPG)',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
              if (_imagemSelecionada != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _imagemSelecionada!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              TextFormField(
                maxLength: 700,
                maxLines: 5,
                initialValue: _resumo,
                decoration: const InputDecoration(
                  labelText: 'Faça um Resumo sobre esse livro',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _resumo = v),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarLivro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.livroExistente != null
                      ? 'Atualizar Livro'
                      : 'Salvar Livro',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _numero_paginasController.dispose();
    _ano_publicacaoController.dispose();
    super.dispose();
  }
}
