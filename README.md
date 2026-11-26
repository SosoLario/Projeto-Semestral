# Projeto-Semestral

Aplicativo mobile em Flutter integrado a uma API REST em Python (Flask) e SQLite para gestão de horários e frequência acadêmica — Projeto Semestral USCS.

## Estrutura do Repositório

* **`documentação/`**: Relatório oficial do projeto, pesquisa de campo e protótipos.
* **`projeto_semestral/`**: Código-fonte do aplicativo desenvolvido em Flutter/Dart.
* **`projeto_semestral_api/`**: API REST desenvolvida em Python (Flask) com banco de dados SQLite.

## Tecnologias Utilizadas

* **Frontend / Mobile:** Flutter (Dart)
* **Backend / API:** Python 3 e Flask
* **Banco de Dados:** SQLite (`classmanager.db`)

## Como Executar o Projeto

### 1. API (Backend)
1. Acesse a pasta `projeto_semestral_api/api`.
2. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```
3. Inicie o servidor:
   ```bash
   python app.py
   ```

### 2. Aplicativo (Flutter)
1. Acesse a pasta `projeto_semestral`.
2. Baixe os pacotes do projeto:
   ```bash
   flutter pub get
   ```
3. Execute o aplicativo:
   ```bash
   flutter run
   ```
