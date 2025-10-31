// anuncios_mockados.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AdManager {
  static final List<Map<String, dynamic>> ads = [
    {
      'id': '1',
      'title': 'Livro em Promoção!',
      'description': 'O Hobbit por apenas R\$ 29,90',
      'image': '📚',
      'color': Colors.blue,
    },
    {
      'id': '2', 
      'title': 'Nova Livraria na Cidade',
      'description': 'Venha conhecer nossa seleção',
      'image': '🏪',
      'color': Colors.green,
    },
    {
      'id': '3',
      'title': 'Clube do Livro',
      'description': 'Junte-se ao nosso clube mensal',
      'image': '👥',
      'color': Colors.orange,
    },
    {
      'id': '4',
      'title': 'E-book Grátis',
      'description': 'Baixe seu e-book gratuito hoje',
      'image': '📱',
      'color': Colors.purple,
    },
  ];

  static Map<String, dynamic> getRandomAd() {
    final random = DateTime.now().millisecond % ads.length;
    return ads[random];
  }
}

class BannerAnuncio extends StatelessWidget { // Mude o nome aqui
  final double height;
  final VoidCallback? onTap;

  const BannerAnuncio({ // E aqui
    super.key,
    this.height = 80,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ad = AdManager.getRandomAd();
    
    return GestureDetector(
      onTap: onTap ?? () {
        _showAdDialog(context, ad);
      },
      child: Container(
        height: height,
        //margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ad['color'] as Color,
              ad['color'].withOpacity(0.7),
            ],
          ),
          //borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Badge de "Anúncio"
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Conteúdo do anúncio
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Ícone/Emoji
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        ad['image'],
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Textos
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          ad['description'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdDialog(BuildContext context, Map<String, dynamic> ad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Anúncio: ${ad['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ad['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  ad['image'],
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(ad['description']),
            const SizedBox(height: 16),
            Text(
              'Este é um anúncio necessário para manter o nosso app.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Redirecionando para: ${ad['title']}'),
                  backgroundColor: ad['color'],
                ),
              );
            },
            child: const Text('Saiba Mais'),
          ),
        ],
      ),
    );
  }
}