CLASSMANAGER — GESTÃO DE TURMAS E FREQUÊNCIA
============================================

Aplicação mobile desenvolvida como Projeto Semestral da disciplina de Programação para Dispositivos Móveis da USCS — Universidade Municipal de São Caetano do Sul.

- Docente: Prof. Me. Raphael Lopes de Souza
- Área de Aplicação: Educação (auxílio à rotina acadêmica de alunos e instituições)


INTEGRANTES DO GRUPO - Grupo do PIM
--------------------

1. Sophia Beringheri Lario — RA: [813168-1]
2. Gabriel Akamine - RA: [818477]
3.  Igor Silva — RA: [818253-1]
4. Juan Contrera — RA: [818255-0]
5. Caio Ignacio — RA: [813198-4]
6. Arthur Scaramella — RA: [812538-5] 		


OBJETIVO DO PROJETO
-------------------
O ClassManager é uma aplicação voltada para a área educacional que otimiza o acompanhamento da rotina acadêmica. Por meio do aplicativo, o estudante consegue consultar seus horários de aula, salas, histórico detalhado de presenças e faltas, além de visualizar suas informações cadastrais de forma prática e centralizada.


TECNOLOGIAS UTILIZADAS
----------------------
- Frontend (Mobile/Web): Flutter & Dart
- Backend (API REST): Python 3 & Flask (com autenticação via JWT e hash de senha scrypt)
- Banco de Dados: SQLite (classmanager)


TELAS INTEGRADAS COM A API
--------------------------
O aplicativo conta com 4 telas conectadas diretamente à API REST em Python e ao banco de dados SQLite:

1. Login (POST /api/login): Realiza a autenticação do usuário no banco de dados e retorna o token de acesso.
2. Horários / Turmas (GET /api/turmas): Consome a lista de disciplinas matriculadas, níveis, dias/horários e salas de aula.
3. Frequência (GET /api/frequencias): Consulta o percentual geral de presença, quantidade de aulas frequentadas, faltas e o histórico filtrado por mês.
4. Meu Perfil (GET /api/perfil): Carrega os dados cadastrais do aluno autenticado (nome, matrícula, e-mail e telefone) e permite encerrar a sessão.


ESTRUTURA DO REPOSITÓRIO
------------------------
- projeto_semestral/     -> Código-fonte do aplicativo mobile em Flutter
- projeto_semestral_api/ -> API REST em Python (Flask) e banco SQLite (classmanager)
- documentacao/          -> Relatório do projeto (pesquisa de campo e protótipo de baixa fidelidade)
- README.txt             -> Documentação e instruções de execução do projeto


COMO EXECUTAR O PROJETO LOCALMENTE
----------------------------------
Para testar a aplicação completa, é necessário iniciar primeiro o servidor da API em Python e, em seguida, executar o aplicativo Flutter.

Pré-requisitos:
- Python 3.x instalado (https://www.python.org/)
- Flutter SDK instalado e configurado no PATH (https://flutter.dev/)

1. Executar o Backend (API Python + Banco SQLite):
Abra um terminal na pasta projeto_semestral_api/api e execute:
    pip install -r requirements.txt
    python app.py
O servidor será iniciado em http://127.0.0.1:5000.

2. Executar o Frontend (Aplicativo Flutter):
Em um segundo terminal, acesse a pasta projeto_semestral e execute:
    flutter pub get
    flutter run -d chrome

3. Credenciais de Acesso (Ambiente de Teste):
Na tela de login do aplicativo, utilize o usuário pré-cadastrado no banco de dados:
- E-mail: carlos.souza@email.com
- Senha: 123456


## DOCUMENTAÇÃO, PESQUISA DE CAMPO E PROTÓTIPO

Os entregáveis complementares exigidos na elaboração do projeto estão disponíveis na pasta `documentação/`:

- **Relatório Técnico:** Contém a justificativa do tema baseada na pesquisa de campo realizada com profissionais da área da educação e o protótipo de baixa fidelidade das telas integradas à API.
- **Capturas de Tela (Evidências do Sistema):** Prints das telas do aplicativo em execução integrado à API (`login.png`, `horarios.png`, `frequencia.png` e `perfil.png`).
