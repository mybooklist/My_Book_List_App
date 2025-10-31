// ignore_for_file: camel_case_types

import 'dart:io';

import 'package:flutter/material.dart';

class Livro_card extends StatelessWidget {
  final String titulo;
  final String autor;
  final String status;
  final String? imagem;
  final bool temCapa;

  const Livro_card({
    super.key,
    required this.titulo,
    required this.autor,
    required this.status,
    this.imagem,
    this.temCapa = false,
  });

  Widget _buildImagem(String path) {
    if (path.startsWith('lib/recursos/images')) {
      return Image.asset(path, fit: BoxFit.cover);
    } else {
      return Image.file(File(path), fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min, // só ocupa o necessário
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem com proporção fixa
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: imagem != null && imagem!.isNotEmpty
                  ? _buildImagem(imagem!)
                  : Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 50,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sem capa',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // Textos + tag
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  autor,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // TAG colorida
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: _getStatusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
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
      case 'Quero Ler':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}