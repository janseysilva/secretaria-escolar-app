"""API do app de Secretaria Escolar (versão celular) - recebe os dados
preenchidos no app Flutter e gera o .docx usando a MESMA lógica já
testada e aprovada na versão de Windows (documentos.py, copiado sem
alterações). O app fica sem estado (stateless): cada pedido manda os
dados da escola inteiros (inclusive logo/assinatura em base64,
opcionais) e recebe o .docx pronto de volta - nada fica salvo no
servidor entre um pedido e outro."""

import base64
import io
import os
import tempfile
import uuid
import zipfile

from fastapi import Body, FastAPI, Request
from fastapi.responses import Response

import documentos
import relatorio_bolsa_familia

app = FastAPI(title="Secretaria Escolar API")

MEDIA_TYPE_DOCX = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"


def _preparar_dados_escola(dados_escola_in, pasta_temp):
    """Copia dados_escola, decodificando logo_base64/assinatura_base64
    (se vierem) pra arquivos temporários - as funções de documentos.py
    esperam um CAMINHO de arquivo (logo_path/assinatura_path), não bytes."""
    dados = dict(dados_escola_in or {})
    for campo_base64, campo_path in (("logo_base64", "logo_path"), ("assinatura_base64", "assinatura_path")):
        valor_base64 = dados.pop(campo_base64, None)
        if valor_base64:
            caminho = os.path.join(pasta_temp, f"{campo_path}_{uuid.uuid4().hex}.png")
            with open(caminho, "wb") as f:
                f.write(base64.b64decode(valor_base64))
            dados[campo_path] = caminho
        else:
            dados.setdefault(campo_path, None)
    return dados


def _gerar_resposta_docx(funcao_geradora, *args_gerador):
    """Roda uma funcao gerar_X de documentos.py numa pasta temporaria e
    devolve o .docx resultante como resposta HTTP, limpando tudo depois."""
    with tempfile.TemporaryDirectory() as pasta_temp:
        caminho_saida = os.path.join(pasta_temp, "documento.docx")
        funcao_geradora(*args_gerador, caminho_saida)
        with open(caminho_saida, "rb") as f:
            conteudo = f.read()
    return Response(content=conteudo, media_type=MEDIA_TYPE_DOCX,
                     headers={"Content-Disposition": 'attachment; filename="documento.docx"'})


@app.get("/")
def raiz():
    return {"status": "ok", "servico": "Secretaria Escolar API"}


@app.post("/gerar/memorando")
def gerar_memorando(payload: dict = Body(...)):
    with tempfile.TemporaryDirectory() as pasta_temp:
        dados_escola = _preparar_dados_escola(payload.get("dados_escola"), pasta_temp)
        return _gerar_resposta_docx(documentos.gerar_memorando, dados_escola, payload.get("dados_memo", {}))


@app.post("/gerar/oficio")
def gerar_oficio(payload: dict = Body(...)):
    with tempfile.TemporaryDirectory() as pasta_temp:
        dados_escola = _preparar_dados_escola(payload.get("dados_escola"), pasta_temp)
        return _gerar_resposta_docx(documentos.gerar_oficio, dados_escola, payload.get("dados_oficio", {}))


@app.post("/gerar/declaracao")
def gerar_declaracao(payload: dict = Body(...)):
    with tempfile.TemporaryDirectory() as pasta_temp:
        dados_escola = _preparar_dados_escola(payload.get("dados_escola"), pasta_temp)
        return _gerar_resposta_docx(documentos.gerar_declaracao, dados_escola, payload.get("dados_decl", {}))


@app.post("/gerar/capa-livro")
def gerar_capa_livro(payload: dict = Body(...)):
    with tempfile.TemporaryDirectory() as pasta_temp:
        dados_escola = _preparar_dados_escola(payload.get("dados_escola"), pasta_temp)
        return _gerar_resposta_docx(documentos.gerar_capa_livro, dados_escola, payload.get("dados_livro", {}))


@app.post("/gerar/ficha-matricula")
def gerar_ficha_matricula(payload: dict = Body(...)):
    with tempfile.TemporaryDirectory() as pasta_temp:
        dados_escola = _preparar_dados_escola(payload.get("dados_escola"), pasta_temp)
        return _gerar_resposta_docx(documentos.gerar_ficha_matricula, dados_escola, payload.get("dados_ficha", {}))


@app.post("/gerar/lista-reuniao")
def gerar_lista_reuniao(payload: dict = Body(...)):
    with tempfile.TemporaryDirectory() as pasta_temp:
        dados_escola = _preparar_dados_escola(payload.get("dados_escola"), pasta_temp)
        turmas = payload.get("turmas")
        if turmas:
            return _gerar_resposta_docx(
                documentos.gerar_lista_reuniao_varias_turmas, dados_escola, payload.get("dados_comuns", {}), turmas)
        return _gerar_resposta_docx(documentos.gerar_lista_reuniao, dados_escola, payload.get("dados_lista", {}))


@app.post("/gerar/lista-frequencia")
def gerar_lista_frequencia(payload: dict = Body(...)):
    with tempfile.TemporaryDirectory() as pasta_temp:
        dados_escola = _preparar_dados_escola(payload.get("dados_escola"), pasta_temp)
        turmas = payload.get("turmas")
        if turmas:
            return _gerar_resposta_docx(
                documentos.gerar_lista_frequencia_varias_turmas, dados_escola, payload.get("dados_comuns", {}), turmas)
        return _gerar_resposta_docx(
            documentos.gerar_lista_frequencia, dados_escola, payload.get("dados_frequencia", {}))


@app.post("/gerar/justificativa-faltas")
def gerar_justificativa_faltas(payload: dict = Body(...)):
    with tempfile.TemporaryDirectory() as pasta_temp:
        dados_escola = _preparar_dados_escola(payload.get("dados_escola"), pasta_temp)
        return _gerar_resposta_docx(
            documentos.gerar_justificativa_faltas, dados_escola, payload.get("dados_justificativa", {}))


@app.post("/gerar/certificado")
def gerar_certificado(payload: dict = Body(...)):
    with tempfile.TemporaryDirectory() as pasta_temp:
        dados_escola = _preparar_dados_escola(payload.get("dados_escola"), pasta_temp)
        return _gerar_resposta_docx(documentos.gerar_certificado, dados_escola, payload.get("dados_certificado", {}))


@app.post("/gerar/historico-escolar")
def gerar_historico_escolar(payload: dict = Body(...)):
    with tempfile.TemporaryDirectory() as pasta_temp:
        dados_escola = _preparar_dados_escola(payload.get("dados_escola"), pasta_temp)
        return _gerar_resposta_docx(
            documentos.gerar_historico_escolar, dados_escola, payload.get("dados_historico", {}))


@app.post("/gerar/bolsa-familia")
async def gerar_bolsa_familia(request: Request):
    """Diferente dos outros documentos, esse recebe arquivos de verdade
    (os PDFs de frequência, agrupados por mês, mais a lista de alunos do
    Bolsa Família) via multipart, não JSON. Cada "mes" enviado pelo app
    vem num campo "grupo_0", "grupo_1" etc. (um arquivo pode repetir o
    mesmo nome de campo - da mesma forma que a versao de PC deixa
    adicionar varias pastas de mes). Devolve um .zip com os formatos
    escolhidos (xlsx/docx/pdf), ja que pode ser mais de um arquivo de
    uma vez so."""
    form = await request.form()

    try:
        percentual_minimo = float(str(form.get("percentual_minimo", "60")).replace(",", "."))
    except ValueError:
        percentual_minimo = 60.0

    formatos = []
    if str(form.get("formato_xlsx", "")).lower() == "true":
        formatos.append("xlsx")
    if str(form.get("formato_docx", "")).lower() == "true":
        formatos.append("docx")
    if str(form.get("formato_pdf", "")).lower() == "true":
        formatos.append("pdf")
    if not formatos:
        return Response(content="Selecione ao menos um formato.", status_code=400)

    arquivo_lista_upload = form.get("arquivo_lista")
    if arquivo_lista_upload is None:
        return Response(content="Falta o arquivo da lista do Bolsa Família.", status_code=400)

    with tempfile.TemporaryDirectory() as raiz_temp:
        caminho_lista = os.path.join(raiz_temp, arquivo_lista_upload.filename)
        with open(caminho_lista, "wb") as f:
            f.write(await arquivo_lista_upload.read())

        chaves_grupo = sorted({chave for chave in form.keys() if chave.startswith("grupo_")})
        if not chaves_grupo:
            return Response(content="Adicione ao menos um mês com PDFs de frequência.", status_code=400)

        pastas = []
        for chave in chaves_grupo:
            pasta_mes = os.path.join(raiz_temp, chave)
            os.makedirs(pasta_mes, exist_ok=True)
            for arquivo in form.getlist(chave):
                caminho = os.path.join(pasta_mes, arquivo.filename)
                with open(caminho, "wb") as f:
                    f.write(await arquivo.read())
            pastas.append(pasta_mes)

        try:
            resultados, meses, _resumo = relatorio_bolsa_familia.analisar(
                pastas, caminho_lista, percentual_minimo, log=lambda *a, **k: None)
        except Exception as e:
            return Response(content=str(e), status_code=400)

        nome_base = relatorio_bolsa_familia.sugerir_nome(meses)
        arquivos_saida = []
        if "xlsx" in formatos:
            caminho = os.path.join(raiz_temp, f"{nome_base}.xlsx")
            relatorio_bolsa_familia.gerar_xlsx(resultados, caminho, percentual_minimo, meses)
            arquivos_saida.append(caminho)
        if "docx" in formatos:
            caminho = os.path.join(raiz_temp, f"{nome_base}.docx")
            relatorio_bolsa_familia.gerar_docx(resultados, caminho, percentual_minimo, meses)
            arquivos_saida.append(caminho)
        if "pdf" in formatos:
            caminho = os.path.join(raiz_temp, f"{nome_base}.pdf")
            relatorio_bolsa_familia.gerar_pdf(resultados, caminho, percentual_minimo, meses)
            arquivos_saida.append(caminho)

        buffer_zip = io.BytesIO()
        with zipfile.ZipFile(buffer_zip, "w", zipfile.ZIP_DEFLATED) as zf:
            for caminho in arquivos_saida:
                zf.write(caminho, os.path.basename(caminho))
        conteudo_zip = buffer_zip.getvalue()

    return Response(
        content=conteudo_zip, media_type="application/zip",
        headers={"Content-Disposition": f'attachment; filename="{nome_base}.zip"'})
