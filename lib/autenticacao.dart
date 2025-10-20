// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';

class Autenticacao {
  // Email fixo para teste (ou use um diálogo)
  final String _emailFixo = "usuario@meuapp.com";

  // Verifica se o usuário está logado
  Future<bool> estaLogado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') != null;
  }

  // Faz login com email fixo
  Future<String?> entrarComEmail() async {
    try {
      print('🔐 Fazendo login com email fixo...');
      
      // Usa o email fixo
      final userEmail = _emailFixo;
      
      // Salva o email no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', userEmail);
      
      print('✅ Login bem-sucedido: $userEmail');
      return userEmail;
    } catch (error) {
      print('❌ Erro no login: $error');
      return null;
    }
  }

  // Faz logout
  Future<void> sair() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userEmail');
      print('✅ Logout realizado com sucesso');
    } catch (error) {
      print('❌ Erro no logout: $error');
      rethrow;
    }
  }

  // Obtém o email do usuário logado
  Future<String?> getEmailUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }
}