# API do ClassManager (Flask + SQLite)

## Rodar
```bash
cd classmanager_api
python -m venv venv && source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py                                      # http://localhost:5000
```
O banco `classmanager.db` é criado sozinho na primeira execução, já com dados de exemplo.
Para recriar do zero, apague o arquivo `classmanager.db` e rode de novo.

Login de teste: `carlos.souza@email.com` / `123456`

## Endpoints
| Método | Rota | Auth | Retorno |
|---|---|---|---|
| GET | `/api/health` | não | `{"status":"ok"}` |
| POST | `/api/login` | não | `{token, aluno}` — corpo: `{email, senha}` |
| GET | `/api/perfil` | sim | dados do aluno |
| GET | `/api/turmas` | sim | `[{disciplina, nivel, horario, sala}]` |
| GET | `/api/frequencia?mes=2026-10` | sim | `{percentual, frequentadas, faltas, historico[]}` |

Auth = header `Authorization: Bearer <token>`. O JSON tem as mesmas chaves dos dados simulados do app.

## Banco (SQLite)
`alunos` · `turmas` · `matriculas` (aluno↔turma) · `aulas` (turma + data) · `frequencias` (aula + aluno + presente)

## Ligando no Flutter
1. Copie `flutter/api_service.dart` para `lib/services/api_service.dart` (o pacote `http` já está no seu pubspec).
2. **login_screen.dart** — troque o `try/catch` de `_realizarLogin` por:
```dart
try {
  await ApiService.login(_emailController.text.trim(), _senhaController.text);
  if (!mounted) return;
  Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => const HomeScreen()));
} on ApiException catch (e) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
} catch (e) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao conectar com a API')));
} finally {
  if (mounted) setState(() => _isLoading = false);
}
```
   e remova o `await Future.delayed(...)` simulado. Adicione `import '../services/api_service.dart';`.
3. **home_screen.dart** — substitua os dois métodos simulados:
```dart
static const _meses = {'Outubro 2026': '2026-10', 'Setembro 2026': '2026-09'};

Future<List> fetchTurmasDaApi() => ApiService.turmas();

Future fetchFrequenciaDaApi() =>
    ApiService.frequencia(mes: _meses[_mesSelecionado]);
```
4. **Android**: em `android/app/src/main/AndroidManifest.xml` adicione, antes de `<application`:
   `<uses-permission android:name="android.permission.INTERNET"/>` e, dentro de `<application`,
   `android:usesCleartextTraffic="true"` (a API local usa http, não https).
5. Endereço da API: veja o comentário em `ApiService.baseUrl` (no emulador Android é `10.0.2.2`, não `localhost`).

## Antes de publicar de verdade
Defina `JWT_SECRET` (variável de ambiente), use HTTPS e troque `debug=True` por um servidor como gunicorn.
