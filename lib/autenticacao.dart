// ignore_for_file: avoid_print

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Autenticacao {
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();


   // Verifica se o usuário está logado
  Future<bool> estaLogado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') != null;
  }

  // Faz login com Google
  Future<String?> entrarComGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final userEmail = googleUser.email;
      
      // Salva o email no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', userEmail);
      
      return userEmail;
    } catch (error) {
      print('Erro no login: $error');
      return null;
    }
  }

   // Faz logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
  }

  // Obtém o email do usuário logado
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }
  
}

