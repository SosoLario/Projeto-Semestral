// Copie para: lib/services/api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String mensagem;
  ApiException(this.mensagem);
  @override
  String toString() => mensagem;
}

class ApiService {
  // Emulador Android: http://10.0.2.2:5000
  // Chrome / Windows / macOS / simulador iOS: http://localhost:5000
  // Celular físico: http://IP_DO_SEU_PC:5000 (mesma rede Wi-Fi)
  // Troque sem editar o código: flutter run --dart-define=API_URL=http://10.0.2.2:5000
  static const String baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://localhost:5000');

  static String? _token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<dynamic> _tratar(http.Response r) async {
    final corpo = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode >= 200 && r.statusCode < 300) return corpo;
    throw ApiException(
        (corpo is Map && corpo['erro'] != null) ? corpo['erro'] : 'Erro ${r.statusCode}');
  }

  static Future<Map<String, dynamic>> login(String email, String senha) async {
    final r = await http
        .post(Uri.parse('$baseUrl/api/login'),
            headers: _headers, body: jsonEncode({'email': email, 'senha': senha}))
        .timeout(const Duration(seconds: 10));
    final dados = await _tratar(r) as Map<String, dynamic>;
    _token = dados['token'];
    return dados['aluno'];
  }

  static void logout() => _token = null;

  static Future<Map<String, dynamic>> perfil() async {
    final r = await http.get(Uri.parse('$baseUrl/api/perfil'), headers: _headers);
    return await _tratar(r) as Map<String, dynamic>;
  }

  static Future<List> turmas() async {
    final r = await http.get(Uri.parse('$baseUrl/api/turmas'), headers: _headers);
    return await _tratar(r) as List;
  }

  /// [mes] no formato 'YYYY-MM' (ex.: '2026-10'). Sem mês, traz o histórico todo.
  static Future<Map<String, dynamic>> frequencia({String? mes}) async {
    final uri = Uri.parse('$baseUrl/api/frequencia')
        .replace(queryParameters: mes == null ? null : {'mes': mes});
    final r = await http.get(uri, headers: _headers);
    return await _tratar(r) as Map<String, dynamic>;
  }
}
