// ignore_for_file: unused_field, non_constant_identifier_names, unused_element

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_book_list/app_colors.dart';

class AdicionarLivro extends StatefulWidget {
  const AdicionarLivro({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Book List',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                    child: DropdownButtonFormField<String>(
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
                    child: DropdownButtonFormField<String>(
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
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? imagem = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (imagem != null) {
                    setState(() {
                      _imagemSelecionada = File(imagem.path);
                    });
                  }
                },
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

              const SizedBox(height: 16),
              TextFormField(
                maxLength: 700,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Faça um Resumo sobre esse livro',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _resumo = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final novoLivro = {
                      'titulo': _tituloController.text,
                      'autor': _autorController.text,
                      'status': _status ?? 'Sem status',
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

                    Navigator.pop(context, novoLivro); // envia o livro de volta
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Salvar Livro',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
