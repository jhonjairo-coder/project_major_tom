#!/usr/bin/env python3
# informes_html.py — Genera INFORME HTML profesional de un proyecto del hackbot
# Uso: ./informes_html.py pentest/<proyecto> [-o salida.html]
# Sin dependencias externas. Python 3.6+.

import os, re, sys, datetime, html as H

SEV = [
    ("critica", "Cr\u00edtica", "#f85149"),
    ("alta",    "Alta",       "#f85149"),
    ("high",    "Alta",       "#f85149"),
    ("media",   "Media",      "#d2a8ff"),
    ("medium",  "Media",      "#d2a8ff"),
    ("baja",    "Baja/Info",  "#79c0ff"),
    ("low",     "Baja/Info",  "#79c0ff"),
    ("info",    "Baja/Info",  "#79c0ff"),
    ("negativo","Descartado", "#56d364"),
    ("descartado","Descartado","#56d364"),
    ("pendiente","Pendiente", "#8b949e"),
]
def clasificar(texto):
    t = texto.lower()
    if re.search(r"descartad|negativ|no aplica|false positive|falso positivo", t): return ("Descartado","#56d364")
    if re.search(r"pendiente|no concluyente|requiere autorizaci", t): return ("Pendiente","#8b949e")
    for k, nombre, color in SEV:
        if k in t: return (nombre, color)
    return ("Por clasificar","#8b949e")

def inline(s):
    s = H.escape(s)
    s = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", s)
    s = re.sub(r"`([^`]+)`", r"<code>\1</code>", s)
    return s

def md2html(md):
    out, lines = [], md.split("\n")
    i, n = 0, len(lines)
    while i < n:
        L = lines[i]
        if L.strip().startswith("```"):
            i += 1; code = []
            while i < n and not lines[i].strip().startswith("```"): code.append(lines[i]); i += 1
            out.append("<pre>" + H.escape("\n".join(code)) + "</pre>"); i += 1; continue
        m = re.match(r"^(#{1,6})\s+(.*)", L)
        if m:
            lvl = min(4, len(m.group(1)) + 2)
            out.append("<h%d>%s</h%d>" % (lvl, inline(m.group(2)), lvl)); i += 1; continue
        if L.strip().startswith("|") and i + 1 < n and re.match(r"^\s*\|[\s:\-|]+\|\s*$", lines[i+1]):
            head = [c.strip() for c in L.strip().strip("|").split("|")]
            i += 2; rows = []
            while i < n and lines[i].strip().startswith("|"):
                rows.append([c.strip() for c in lines[i].strip().strip("|").split("|")]); i += 1
            t = "<table><tr>" + "".join("<th>%s</th>" % inline(c) for c in head) + "</tr>"
            for r in rows: t += "<tr>" + "".join("<td>%s</td>" % inline(c) for c in r) + "</tr>"
            out.append(t + "</table>"); continue
        m = re.match(r"^\s*[-*]\s+(.*)", L)
        if m:
            items = []
            while i < n:
                m2 = re.match(r"^\s*[-*]\s+(.*)", lines[i])
                if not m2: break
                items.append("<li>%s</li>" % inline(m2.group(1))); i += 1
            out.append("<ul>" + "".join(items) + "</ul>"); continue
        m = re.match(r"^\s*(\d+)\.\s+(.*)", L)
        if m:
            items = []
            while i < n:
                m2 = re.match(r"^\s*\d+\.\s+(.*)", lines[i])
                if not m2: break
                items.append("<li>%s</li>" % inline(m2.group(1))); i += 1
            out.append("<ol>" + "".join(items) + "</ol>"); continue
        if L.strip().startswith(">"):
            out.append("<div class='warn'>%s</div>" % inline(L.strip().lstrip("> ").strip())); i += 1; continue
        if L.strip(): out.append("<p>%s</p>" % inline(L.strip()))
        i += 1
    return "\n".join(out)

CSS = """
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',system-ui,sans-serif;background:#0d1117;color:#c9d1d9;line-height:1.6;padding:40px 20px}
.wrap{max-width:1000px;margin:0 auto;background:#161b22;border:1px solid #30363d;border-radius:8px;padding:40px}
h1{color:#f0f6fc;font-size:2em;border-bottom:2px solid #58a6ff;padding-bottom:15px;margin-bottom:10px}
h2{color:#f0f6fc;font-size:1.5em;margin-top:30px;border-left:4px solid #58a6ff;padding-left:15px}
h3{color:#79c0ff;font-size:1.1em;margin-top:22px}
h4{color:#79c0ff;font-size:1em;margin-top:16px}
.meta{color:#8b949e;font-size:.9em;margin-bottom:25px;display:flex;gap:20px;flex-wrap:wrap}
.meta b{color:#79c0ff}
table{width:100%;border-collapse:collapse;margin:18px 0;background:#0d1117;border:1px solid #30363d}
th,td{padding:10px 14px;text-align:left;border-bottom:1px solid #30363d;font-size:.92em}
th{background:#21262d;color:#79c0ff}
tr:hover{background:#21262d}
.chip{display:inline-block;padding:2px 10px;border-radius:12px;font-size:.8em;font-weight:600;color:#0d1117}
.finding{border:1px solid #30363d;border-left:5px solid #888;border-radius:6px;padding:18px 20px;margin:22px 0;background:#0d1117}
pre{background:#010409;border:1px solid #30363d;border-radius:6px;padding:12px;overflow-x:auto;font-size:.85em;color:#a5d6ff;margin:10px 0}
code{background:#010409;color:#79c0ff;padding:2px 6px;border-radius:3px;font-family:Consolas,monospace;font-size:.9em}
pre code{padding:0}
.warn{background:#21262d;border-left:4px solid #f0b72f;padding:12px 15px;margin:12px 0;border-radius:4px;color:#f0b72f}
.rem{background:#0d1117;border-left:3px solid #56d364;padding:10px 12px;margin:10px 0}
.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:14px;margin:22px 0}
.stat{background:#0d1117;border:1px solid #30363d;border-radius:8px;padding:16px;text-align:center}
.stat .n{font-size:2em;font-weight:700}
.stat .l{font-size:.8em;color:#8b949e}
.idx{font-size:.85em;color:#8b949e}
.idx li{margin:3px 0}
a{color:#58a6ff}
.footer{margin-top:35px;padding-top:18px;border-top:1px solid #30363d;color:#8b949e;font-size:.85em}
"""

def main():
    args = sys.argv[1:]
    if not args:
        print("Uso: informes_html.py <carpeta_proyecto> [-o salida.html]"); sys.exit(1)
    proj = args[0]
    out = args[args.index("-o") + 1] if "-o" in args else os.path.join(proj, "INFORME.html")
    fdir = os.path.join(proj, "findings")
    if not os.path.isdir(fdir):
        print("No existe", fdir); sys.exit(1)

    mds = sorted(f for f in os.listdir(fdir) if f.endswith(".md"))
    reporte = os.path.join(fdir, "REPORTE.md")
    if os.path.exists(reporte) and "REPORTE.md" not in mds: mds.insert(0, "REPORTE.md")
    elif "REPORTE.md" in mds: mds.remove("REPORTE.md"); mds.insert(0, "REPORTE.md")

    bloques, stats = [], {}
    for f in mds:
        txt = open(os.path.join(fdir, f), encoding="utf-8", errors="replace").read()
        nombre, color = clasificar(txt[:1200] + " " + f)
        stats[nombre] = stats.get(nombre, 0) + 1
        anchor = f.replace(".md", "")
        titulo = re.search(r"^#\s+(.*)", txt, re.M)
        titulo = titulo.group(1).strip() if titulo else f
        bloques.append(
            "<div class='finding' style='border-left-color:%s' id='%s'>"
            "<h3><span class='chip' style='background:%s'>%s</span> &nbsp;%s"
            "<span style='float:right;font-size:.75em;color:#8b949e'>%s</span></h3>%s</div>"
            % (color, anchor, color, nombre, H.escape(titulo), f, md2html(txt)))

    ev = []
    for root, _, files in os.walk(fdir):
        for fn in sorted(files):
            fp = os.path.join(root, fn)
            ev.append("<li>%s <span style='color:#566070'>(%d bytes)</span></li>"
                      % (os.path.relpath(fp, fdir), os.path.getsize(fp)))

    scope = ""
    sp = os.path.join(proj, "SCOPE.md")
    if os.path.exists(sp):
        scope = "<b>Alcance:</b> " + H.escape(" ".join(
            l for l in open(sp).read().splitlines() if l.strip() and not l.strip().startswith("#")))[:200]

    stat_cards = "".join(
        "<div class='stat'><div class='n' style='color:%s'>%d</div><div class='l'>%s</div></div>"
        % (c, stats.get(n, 0), n) for n, c in
        [("Cr\u00edtica","#f85149"),("Alta","#f85149"),("Media","#d2a8ff"),
         ("Baja/Info","#79c0ff"),("Descartado","#56d364"),("Pendiente","#8b949e"),("Por clasificar","#8b949e")])

    tabla = "".join(
        "<tr><td><span class='chip' style='background:%s'>%s</span></td><td><a href='#%s'>%s</a></td></tr>"
        % (c, n, f.replace(".md",""), f) for (f, (n, c)) in
        [(f, clasificar(open(os.path.join(fdir,f),encoding='utf-8',errors='replace').read()[:1200]+" "+f)) for f in mds])

    doc = ("<!DOCTYPE html><html lang='es'><head><meta charset='utf-8'>"
           "<title>INFORME - %s</title><style>%s</style></head><body><div class='wrap'>"
           "<h1>INFORME DE PENTEST</h1>"
           "<div class='meta'><span><b>Proyecto:</b> %s</span><span><b>Fecha UTC:</b> %s</span><span>%s</span></div>"
           "<h2>Resumen</h2><div class='stats'>%s</div>"
           "<h2>\u00cdndice de hallazgos</h2><table><tr><th>Severidad</th><th>Documento</th></tr>%s</table>"
           "<h2>Detalle</h2>%s"
           "<h2>\u00cdndice de evidencia en disco</h2><ul class='idx'>%s</ul>"
           "<div class='footer'>Generado por informes_html.py &middot; HACKBOT (recon &rarr; js-analyze &rarr; "
           "content-discovery &rarr; vuln-scan &rarr; report &rarr; review)</div>"
           "</div></body></html>"
           % (H.escape(os.path.basename(proj.rstrip('/'))), CSS, H.escape(proj),
              datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M"), scope, stat_cards, tabla,
              "".join(bloques), "".join(ev)))
    open(out, "w", encoding="utf-8").write(doc)
    print("OK ->", out, os.path.getsize(out), "bytes |", len(mds), "documentos |", len(ev), "archivos de evidencia")

if __name__ == "__main__":
    main()
