// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';

class Livro_card extends StatelessWidget {
  final String titulo;
  final String autor;
  final String status;
  final String? imagem;

  const Livro_card({
    super.key,
    required this.titulo,
    required this.autor,
    required this.status,
    this.imagem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Capa do livro
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: imagem != null
                    ? DecorationImage(
                        image: AssetImage(imagem!), // pode trocar por NetworkImage
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imagem == null
                  ? const Center(
                      child: Icon(Icons.image_not_supported,
                          size: 40, color: Colors.grey),
                    )
                  : null,
            ),
          ),

          // Título e autor
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  autor,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Status
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Lido':
        return Colors.green;
      case 'Lendo':
        return Colors.orange;
      case 'Quero ler':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
