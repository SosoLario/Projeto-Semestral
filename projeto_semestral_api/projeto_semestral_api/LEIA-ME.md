# Projeto Semestral – API + integração

## 1. Rodar a API (pasta `api/`)
```bash
cd api
python -m venv venv && source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py                                      # http://localhost:5000
```
O banco `classmanager.db` (SQLite) é criado sozinho, com dados de exemplo.
Login de teste: `carlos.souza@email.com` / `123456`

## 2. Aplicar no app Flutter (pasta `projeto_semestral/`)
Copie o conteúdo da pasta `projeto_semestral/` deste zip por cima do seu projeto (aceite substituir):
- `lib/services/api_service.dart` (novo)
- `lib/screens/login_screen.dart`, `home_screen.dart`, `profile_screen.dart` (agora usam a API)
- `android/app/src/main/AndroidManifest.xml` (permissão de internet + http liberado)

Depois: `flutter pub get` e rode o app.

## 3. Endereço da API
- Chrome / Windows / macOS / simulador iOS: `flutter run` (usa `http://localhost:5000`)
- Emulador Android: `flutter run --dart-define=API_URL=http://10.0.2.2:5000`
- Celular físico: `flutter run --dart-define=API_URL=http://IP_DO_PC:5000` (mesma rede Wi-Fi)

## Rotas
| Método | Rota | Auth |
|---|---|---|
| POST | `/api/login` | não |
| GET | `/api/perfil` | Bearer token |
| GET | `/api/turmas` | Bearer token |
| GET | `/api/frequencia?mes=2026-10` | Bearer token |

Tabelas: `alunos`, `turmas`, `matriculas`, `aulas`, `frequencias`.
