import 'package:flutter/material.dart';

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
  String? _imagem;
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
    'Literatura Estrangeira'
  ];
  final List<String> _avaliacoes = [
    'Ótimo',
    'Muito bom',
    'Bom',
    'Regular',
    'Ruim'
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
                      child: Text(_inicio_leitura == null
                          ? 'Início da Leitura'
                          : '${_inicio_leitura!.day}/${_inicio_leitura!.month}/${_inicio_leitura!.year}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selecionarData(false),
                      child: Text(_fim_leitura == null
                          ? 'Fim da Leitura'
                          : '${_fim_leitura!.day}/${_fim_leitura!.month}/${_fim_leitura!.year}'),
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
                      decoration:
                          const InputDecoration(labelText: 'Status da Leitura'),
                      value: _status,
                      items: _statusOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _status = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _numero_paginasController,
                      decoration:
                          const InputDecoration(labelText: 'Páginas'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Gênero Literário'),
                      value: _genero_literario,
                      items: _generos
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
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
                onPressed: () {
                  // Aqui você pode implementar o seletor de imagem futuramente
                },
                icon: const Icon(Icons.image_outlined),
                label: const Text('Selecionar imagem de capa (PNG, JPG)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLength: 700,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Faça uma Resenha sobre esse livro',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _resumo = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aqui salva o livro
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Livro salvo com sucesso!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Salvar Livro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
