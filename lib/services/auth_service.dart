// lib/services/auth_service.dart
// Serviço de autenticação com Firebase Auth

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Instância única do FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Retorna o usuário atualmente logado (null se não há sessão)
  User? get currentUser => _auth.currentUser;

  // Stream que emite eventos quando o estado de login muda
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── CADASTRO ─────────────────────────────────────────────────────────────
  // Retorna null em caso de sucesso, ou uma mensagem de erro em String
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // sucesso
    } on FirebaseAuthException catch (e) {
      // Tradução dos erros mais comuns
      switch (e.code) {
        case 'email-already-in-use':
          return 'Este e-mail já está cadastrado.';
        case 'weak-password':
          return 'Senha fraca. Use ao menos 6 caracteres.';
        case 'invalid-email':
          return 'E-mail inválido.';
        default:
          return 'Erro ao cadastrar: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  // ─── LOGIN ─────────────────────────────────────────────────────────────────
  // Retorna null em caso de sucesso, ou uma mensagem de erro em String
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // sucesso
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado.';
        case 'wrong-password':
          return 'Senha incorreta.';
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'invalid-credential':
          return 'E-mail ou senha incorretos.';
        case 'too-many-requests':
          return 'Muitas tentativas. Aguarde e tente novamente.';
        default:
          return 'Erro ao fazer login: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  // ─── LOGOUT ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }
}
