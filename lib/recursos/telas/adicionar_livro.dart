// ignore_for_file: unused_field, non_constant_identifier_names, unused_element, file_names, avoid_print, use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:my_book_list/app_colors.dart';

class AdicionarLivro extends StatefulWidget {
  final Map<String, dynamic>? livroExistente;
  final bool usuarioLogado;
  final Function(Map<String, dynamic>)? onLivroSalvo;

  const AdicionarLivro({
    super.key,
    this.livroExistente,
    required this.usuarioLogado,
    this.onLivroSalvo,
  });

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

  // estilização dos campos do formulário
  InputDecoration _inputDecoration(
    String label, {
    IconData? prefixIcon,
    Widget? suffix,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
    );
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: Colors.grey)
          : null,
      suffixIcon: suffix,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.azul, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  final _inicioController = TextEditingController();
  final _fimController = TextEditingController();

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  void initState() {
    super.initState();

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
          : 'Quero Ler';

      final generoExistente = widget.livroExistente!['genero_literario'];
      _genero_literario = _generos.contains(generoExistente)
          ? generoExistente
          : 'Romance';

      // AVALIAÇÃO: Só preenche se usuário estiver logado
      if (widget.usuarioLogado) {
        final avaliacaoExistente = widget.livroExistente!['avaliacao'];
        _avaliacao = _avaliacoes.contains(avaliacaoExistente)
            ? avaliacaoExistente
            : 'Bom';
      } else {
        _avaliacao = '';
      }

      // RESUMO: Só preenche se usuário estiver logado
      if (widget.usuarioLogado) {
        _resumo = widget.livroExistente!['resumo'] ?? '';
      } else {
        _resumo = '';
      }

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
    } else {
      // Valores padrão para novo livro
      _status = 'Quero Ler';
      _genero_literario = 'Literatura Estrangeira';

      // AVALIAÇÃO E RESUMO: Só tem valores padrão se usuário estiver logado
      if (widget.usuarioLogado) {
        _avaliacao = 'Bom';
        _resumo = '';
      } else {
        _avaliacao = '';
        _resumo = '';
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

  // MÉTODO para salvar livro no Shared Preferences
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

      print(' DEBUG _salvarLivroNoSharedPreferences:');
      print('   - Livro a salvar: ${livro['titulo']} (ID: ${livro['id']})');
      print('   - Livros existentes: ${livrosList.length}');
      print('   - Modo: ${widget.livroExistente != null ? "EDIÇÃO" : "NOVO"}');

      // Verifica se é edição ou novo livro
      if (widget.livroExistente != null) {
        // MODO EDIÇÃO
        final String livroId = livro['id'];
        print('   - Procurando ID: $livroId para editar');

        final int index = livrosList.indexWhere(
          (l) => l['id'].toString() == livroId.toString(),
        );
        print('   - Index encontrado: $index');

        if (index != -1) {
          // ATUALIZA livro existente
          livrosList[index] = {
            ...livrosList[index], // Mantém campos existentes
            ...livro, // Aplica atualizações
          };
          print('LIVRO ATUALIZADO na posição $index');
        } else {
          // Se não encontrou, ADICIONA como novo
          print('Livro não encontrado, ADICIONANDO COMO NOVO');
          livrosList.add({...livro, 'fonte': 'usuario'});
        }
      } else {
        // MODO NOVO LIVRO
        print('ADICIONANDO NOVO LIVRO');
        final novoLivroCompleto = {
          ...livro,
          'fonte': 'usuario',
          'id': DateTime.now().millisecondsSinceEpoch
              .toString(), // Garante ID único
        };
        livrosList.add(novoLivroCompleto);
      }

      // Salva a lista atualizada
      await prefs.setString('livros', json.encode(livrosList));

      print('LISTA SALVA com ${livrosList.length} livros');
    } catch (e) {
      print('ERRO em _salvarLivroNoSharedPreferences: $e');
      throw Exception('Erro ao salvar livro: $e');
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

  // MÉTODO PRINCIPAL para salvar o livro
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

        print('Preparando livro para salvar...');

        // VERIFICA SE TEM IMAGEM SELECIONADA, SE NÃO, USA A PADRÃO
        String caminhoImagem = "";
        if (_imagemSelecionada != null) {
          caminhoImagem = _imagemSelecionada!.path;
        }

        // Cria o mapa do livro
        final Map<String, dynamic> livro = {
          'titulo': _tituloController.text,
          'autor': _autorController.text,
          'status': _status ?? 'Quero Ler',
          'genero_literario': _genero_literario ?? 'Romance',
          'ano_publicacao': _ano_publicacaoController.text,
          'numero_paginas': _numero_paginasController.text,
          'inicio_leitura': _inicio_leitura != null
              ? '${_inicio_leitura!.day}/${_inicio_leitura!.month}/${_inicio_leitura!.year}'
              : '',
          'fim_leitura': _fim_leitura != null
              ? '${_fim_leitura!.day}/${_fim_leitura!.month}/${_fim_leitura!.year}'
              : '',
          'imagem': caminhoImagem,

          // AVALIAÇÃO E RESUMO: Só inclui se usuário estiver logado
          if (widget.usuarioLogado) ...{
            'avaliacao': _avaliacao ?? '',
            'resumo': _resumo,
          } else ...{
            'avaliacao': '',
            'resumo': '',
          },
        };

        // Se for edição, mantém o ID original
        if (widget.livroExistente != null) {
          livro['id'] = widget.livroExistente!['id'];
          print('Editando livro ID: ${livro['id']}');
        } else {
          // Se for novo livro, gera um ID único
          livro['id'] = DateTime.now().millisecondsSinceEpoch.toString();
          print('Novo livro ID: ${livro['id']}');
        }

        // Salva no Shared Preferences
        await _salvarLivroNoSharedPreferences(livro);

        // Fecha o loading
        Navigator.pop(context);

        // CHAMA O CALLBACK SE EXISTIR - ANTES de fechar a tela
        if (widget.onLivroSalvo != null) {
          widget.onLivroSalvo!(livro);
        }

        // Fecha a tela de adicionar/editar livro
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

  // inicio dos campos de formulário
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
              // Campos básicos (sempre visíveis)
              TextFormField(
                controller: _tituloController,
                decoration: _inputDecoration(
                  'Título do Livro',
                  prefixIcon: Icons.menu_book_outlined,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _autorController,
                decoration: _inputDecoration(
                  'Nome do Autor',
                  prefixIcon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _inicioController,
                      readOnly: true,
                      decoration: _inputDecoration(
                        'Início da Leitura',
                        suffix: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () async {
                        final data = await showDatePicker(
                          context: context,
                          initialDate: _inicio_leitura ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (data != null) {
                          setState(() {
                            _inicio_leitura = data;
                            _inicioController.text = _formatarData(data);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _fimController,
                      readOnly: true,
                      decoration: _inputDecoration(
                        'Fim da Leitura',
                        suffix: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () async {
                        final data = await showDatePicker(
                          context: context,
                          initialDate: _fim_leitura ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (data != null) {
                          setState(() {
                            _fim_leitura = data;
                            _fimController.text = _formatarData(data);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // CAMPO DE AVALIAÇÃO (apenas para usuários logados)
              if (widget.usuarioLogado) ...[
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Avaliação'),
                  value: _avaliacao,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  items: _avaliacoes
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (v) => setState(() => _avaliacao = v),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: _inputDecoration('Status da Leitura'),
                      value: _status,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      items: _statusOptions
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _status = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _numero_paginasController,
                      decoration: _inputDecoration('Páginas'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: _inputDecoration('Gênero Literário'),
                      value: _genero_literario,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      items: _generos
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      selectedItemBuilder: (context) => _generos
                          .map(
                            (g) => Text(
                              g,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 14),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _genero_literario = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _ano_publicacaoController,
                      decoration: _inputDecoration('Ano'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _selecionarImagem,
                  icon: const Icon(
                    Icons.image_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  label: const Text(
                    'Selecionar imagem de capa (PNG, JPG)',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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

              // CAMPO DE RESUMO (apenas para usuários logados)
              if (widget.usuarioLogado) ...[
                const SizedBox(height: 12),
                TextFormField(
                  maxLength: 700,
                  maxLines: 5,
                  initialValue: _resumo,
                  decoration: _inputDecoration(
                    'Faça um resumo sobre esse livro',
                  ),
                  onChanged: (v) => setState(() => _resumo = v),
                ),
              ],

              // AVISO para usuários não logados
              if (!widget.usuarioLogado) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Faça login para adicionar avaliação e resumo',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarLivro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azul,
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
