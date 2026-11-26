"""
API do ClassManager (Flask + SQLite).

Rodar:  python app.py
Docs:   veja README.md
"""
import datetime as dt
import os
import sqlite3
from functools import wraps

import jwt
from flask import Flask, g, jsonify, request
from werkzeug.security import check_password_hash, generate_password_hash

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.environ.get("DB_PATH", os.path.join(BASE_DIR, "classmanager.db"))
JWT_SECRET = os.environ.get("JWT_SECRET", "troque-esta-chave-em-producao")
TOKEN_HORAS = 12
DIAS = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"]

SCHEMA = """
CREATE TABLE IF NOT EXISTS alunos (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    nome       TEXT NOT NULL,
    matricula  TEXT NOT NULL UNIQUE,
    email      TEXT NOT NULL UNIQUE,
    telefone   TEXT,
    senha_hash TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS turmas (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    disciplina  TEXT NOT NULL,
    nivel       TEXT NOT NULL,
    dia_semana  INTEGER NOT NULL CHECK (dia_semana BETWEEN 0 AND 6), -- 0 = Seg
    hora_inicio TEXT NOT NULL,                                       -- 'HH:MM'
    hora_fim    TEXT NOT NULL,
    sala        TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS matriculas (
    aluno_id INTEGER NOT NULL REFERENCES alunos(id) ON DELETE CASCADE,
    turma_id INTEGER NOT NULL REFERENCES turmas(id) ON DELETE CASCADE,
    PRIMARY KEY (aluno_id, turma_id)
);
CREATE TABLE IF NOT EXISTS aulas (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    turma_id INTEGER NOT NULL REFERENCES turmas(id) ON DELETE CASCADE,
    data     TEXT NOT NULL,                                          -- 'YYYY-MM-DD'
    UNIQUE (turma_id, data)
);
CREATE TABLE IF NOT EXISTS frequencias (
    aula_id  INTEGER NOT NULL REFERENCES aulas(id) ON DELETE CASCADE,
    aluno_id INTEGER NOT NULL REFERENCES alunos(id) ON DELETE CASCADE,
    presente INTEGER NOT NULL CHECK (presente IN (0, 1)),
    PRIMARY KEY (aula_id, aluno_id)
);
"""


# ----------------------------------------------------------------- banco
def conectar():
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    con.execute("PRAGMA foreign_keys = ON")
    return con


def get_db():
    if "db" not in g:
        g.db = conectar()
    return g.db


def init_db():
    con = conectar()
    con.executescript(SCHEMA)
    if con.execute("SELECT COUNT(*) FROM alunos").fetchone()[0] == 0:
        seed(con)
    con.commit()
    con.close()


def seed(con):
    """Dados de exemplo iguais aos que estavam fixos no app Flutter."""
    con.execute(
        "INSERT INTO alunos (nome, matricula, email, telefone, senha_hash) VALUES (?,?,?,?,?)",
        ("Carlos Eduardo Souza", "2026-001", "carlos.souza@email.com",
         "(11) 98765-4321", generate_password_hash("123456")),
    )
    turmas = [  # disciplina, nivel, dia (0=Seg), inicio, fim, sala
        ("Inglês", "Intermediário", 0, "08:00", "09:00", "Sala 102"),
        ("Inglês", "Intermediário", 1, "10:00", "11:00", "Sala 103"),
    ]
    for t in turmas:
        con.execute(
            "INSERT INTO turmas (disciplina, nivel, dia_semana, hora_inicio, hora_fim, sala) "
            "VALUES (?,?,?,?,?,?)", t)
        con.execute("INSERT INTO matriculas (aluno_id, turma_id) VALUES (1, ?)",
                    (con.execute("SELECT last_insert_rowid()").fetchone()[0],))

    # (turma_id, data, presente)
    aulas = [
        (1, "2026-09-07", 1), (1, "2026-09-14", 1), (1, "2026-09-21", 1), (1, "2026-09-28", 1),
        (1, "2026-10-05", 1), (1, "2026-10-12", 1), (1, "2026-10-19", 0), (1, "2026-10-26", 1),
        (2, "2026-09-08", 1), (2, "2026-09-15", 1), (2, "2026-09-22", 1), (2, "2026-09-29", 1),
        (2, "2026-10-06", 1), (2, "2026-10-13", 1), (2, "2026-10-20", 1), (2, "2026-10-27", 1),
    ]
    for turma_id, data, presente in aulas:
        cur = con.execute("INSERT INTO aulas (turma_id, data) VALUES (?,?)", (turma_id, data))
        con.execute("INSERT INTO frequencias (aula_id, aluno_id, presente) VALUES (?,1,?)",
                    (cur.lastrowid, presente))


# ------------------------------------------------------------------- app
app = Flask(__name__)
app.json.ensure_ascii = False  # mantém acentos legíveis no JSON
init_db()


@app.teardown_appcontext
def fechar_db(_):
    db = g.pop("db", None)
    if db is not None:
        db.close()


@app.after_request
def cors(resp):
    # Necessário para rodar o Flutter no Chrome (flutter run -d chrome).
    resp.headers["Access-Control-Allow-Origin"] = "*"
    resp.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
    resp.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    return resp


def erro(msg, status):
    return jsonify({"erro": msg}), status


def autenticado(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        auth = request.headers.get("Authorization", "")
        if not auth.startswith("Bearer "):
            return erro("Token ausente", 401)
        try:
            dados = jwt.decode(auth[7:], JWT_SECRET, algorithms=["HS256"])
        except jwt.ExpiredSignatureError:
            return erro("Sessão expirada", 401)
        except jwt.InvalidTokenError:
            return erro("Token inválido", 401)
        g.aluno_id = int(dados["sub"])
        return f(*args, **kwargs)
    return wrapper


def aluno_dict(row):
    return {"id": row["id"], "nome": row["nome"], "matricula": row["matricula"],
            "email": row["email"], "telefone": row["telefone"]}


# ----------------------------------------------------------------- rotas
@app.get("/api/health")
def health():
    return jsonify({"status": "ok"})


@app.post("/api/login")
def login():
    corpo = request.get_json(silent=True) or {}
    email = str(corpo.get("email", "")).strip().lower()
    senha = str(corpo.get("senha", ""))
    if not email or not senha:
        return erro("Informe e-mail e senha", 400)

    aluno = get_db().execute(
        "SELECT * FROM alunos WHERE lower(email) = ?", (email,)).fetchone()
    if aluno is None or not check_password_hash(aluno["senha_hash"], senha):
        return erro("E-mail ou senha inválidos", 401)

    agora = dt.datetime.now(dt.timezone.utc)
    token = jwt.encode(
        {"sub": str(aluno["id"]), "iat": agora,
         "exp": agora + dt.timedelta(hours=TOKEN_HORAS)},
        JWT_SECRET, algorithm="HS256")
    return jsonify({"token": token, "aluno": aluno_dict(aluno)})


@app.get("/api/perfil")
@autenticado
def perfil():
    aluno = get_db().execute("SELECT * FROM alunos WHERE id = ?", (g.aluno_id,)).fetchone()
    if aluno is None:
        return erro("Aluno não encontrado", 404)
    return jsonify(aluno_dict(aluno))


@app.get("/api/turmas")
@autenticado
def turmas():
    rows = get_db().execute(
        """SELECT t.* FROM turmas t
           JOIN matriculas m ON m.turma_id = t.id
           WHERE m.aluno_id = ?
           ORDER BY t.dia_semana, t.hora_inicio""", (g.aluno_id,)).fetchall()
    return jsonify([
        {"disciplina": r["disciplina"], "nivel": r["nivel"],
         "horario": f'{DIAS[r["dia_semana"]]} - {r["hora_inicio"]}',
         "sala": r["sala"]}
        for r in rows])


@app.get("/api/frequencia")
@autenticado
def frequencia():
    """
    Totais (percentual / frequentadas / faltas) consideram TODAS as aulas do aluno.
    O histórico pode ser filtrado com ?mes=YYYY-MM (ex.: 2026-10).
    """
    mes = request.args.get("mes")
    if mes is not None:
        try:
            dt.datetime.strptime(mes, "%Y-%m")
        except ValueError:
            return erro("Parâmetro 'mes' deve ser YYYY-MM", 400)

    db = get_db()
    total, presentes = db.execute(
        "SELECT COUNT(*), COALESCE(SUM(presente), 0) FROM frequencias WHERE aluno_id = ?",
        (g.aluno_id,)).fetchone()
    faltas = total - presentes
    percentual = round(100 * presentes / total) if total else 0

    sql = """SELECT a.data, t.disciplina, t.hora_inicio, t.hora_fim, f.presente
             FROM frequencias f
             JOIN aulas a ON a.id = f.aula_id
             JOIN turmas t ON t.id = a.turma_id
             WHERE f.aluno_id = ?"""
    params = [g.aluno_id]
    if mes:
        sql += " AND substr(a.data, 1, 7) = ?"
        params.append(mes)
    sql += " ORDER BY a.data, t.hora_inicio"

    historico = [
        {"data": dt.date.fromisoformat(r["data"]).strftime("%d/%m/%Y"),
         "aula": r["disciplina"],
         "horario": f'{r["hora_inicio"]} - {r["hora_fim"]}',
         "presente": bool(r["presente"])}
        for r in db.execute(sql, params).fetchall()]

    # Strings, porque o app Flutter exibe esses três valores como String.
    return jsonify({"percentual": f"{percentual}%", "frequentadas": str(presentes),
                    "faltas": str(faltas), "historico": historico})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)), debug=True)
