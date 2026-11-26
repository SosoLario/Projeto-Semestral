import os, tempfile

os.environ["DB_PATH"] = os.path.join(tempfile.mkdtemp(), "teste.db")
import app as api  # noqa: E402

c = api.app.test_client()


def auth():
    r = c.post("/api/login", json={"email": "carlos.souza@email.com", "senha": "123456"})
    return {"Authorization": "Bearer " + r.get_json()["token"]}


def test_login_ok_e_falha():
    assert c.post("/api/login", json={"email": "carlos.souza@email.com", "senha": "123456"}).status_code == 200
    assert c.post("/api/login", json={"email": "carlos.souza@email.com", "senha": "errada"}).status_code == 401
    assert c.post("/api/login", json={}).status_code == 400


def test_rotas_exigem_token():
    for rota in ("/api/perfil", "/api/turmas", "/api/frequencia"):
        assert c.get(rota).status_code == 401
        assert c.get(rota, headers={"Authorization": "Bearer xxx"}).status_code == 401


def test_perfil_e_turmas():
    h = auth()
    assert c.get("/api/perfil", headers=h).get_json()["matricula"] == "2026-001"
    t = c.get("/api/turmas", headers=h).get_json()
    assert t[0] == {"disciplina": "Inglês", "nivel": "Intermediário", "horario": "Seg - 08:00", "sala": "Sala 102"}
    assert t[1]["horario"] == "Ter - 10:00"


def test_frequencia():
    h = auth()
    d = c.get("/api/frequencia", headers=h).get_json()
    assert (d["percentual"], d["frequentadas"], d["faltas"]) == ("94%", "15", "1")
    out = c.get("/api/frequencia?mes=2026-10", headers=h).get_json()["historico"]
    assert len(out) == 8 and out[0]["data"] == "05/10/2026"
    assert [x["presente"] for x in out].count(False) == 1
    assert c.get("/api/frequencia?mes=out", headers=h).status_code == 400


def test_cors_preflight():
    r = c.open("/api/login", method="OPTIONS")
    assert r.headers["Access-Control-Allow-Origin"] == "*"
