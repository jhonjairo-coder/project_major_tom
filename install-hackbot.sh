#!/bin/bash
# install-hackbot.sh — AUTÓNOMO: instala skills + templates + launcher del hackbot.
# No requiere carpetas adicionales; todo está embebido. Riesgo: bajo, solo escribe en $HOME.

set -e
DEST=~/ProjectMajorTom

echo "== 1/4 Skills (lee Claude Code al arrancar) =="
mkdir -p ~/.claude/skills

mkdir -p ~/.claude/skills/recon
cat > ~/.claude/skills/recon/SKILL.md <<'SKILLEOF'
---
name: recon
description: Enumeración de subdominios y sondeo HTTP de los objetivos listados en SCOPE.md. Primera fase de todo pentest web.
---

# recon

Objetivo: inventario vivo de objetivos. SOLO actúa sobre dominios/IPs presentes en SCOPE.md.

BASE = ruta absoluta del proyecto (ej. /home/kali/work/pentest/<cliente>).

## Pasos — crea sus checkboxes en LEDGER.md al arrancar
1. [ ] Leer SCOPE.md y extraer dominios raíz. Si está vacío, DETENTE y pide el alcance.
2. [ ] Subdominios pasivos:
   `subfinder -d <dominio> -all -silent -o $BASE/spec/01-recon/subdomains_raw.txt`
   (bajo riesgo: solo consultas a APIs pasivas, sin tráfico al objetivo)
3. [ ] Agregar dominios raíz, deduplicar:
   `cat subdomains_raw.txt <(echo <dominio>) | sort -u > $BASE/spec/01-recon/subdomains.txt`
4. [ ] Sondeo HTTP con sintaxis COMPLETA (jamás solo "httpx -l subs" — el modelo usará la sintaxis perezosa):
   ```
   httpx -l $BASE/spec/01-recon/subdomains.txt      -p http:80,8080,8000,8888,3000 -p https:443,8443,9443      -sc -cl -title -td -server -ip -cdn -location -favicon      -fr -maxr 3 -fep -rl 50 -t 25 -timeout 8 -retries 2 -random-agent      -j -o $BASE/spec/01-recon/httpx.json      -sr -srd $BASE/spec/01-recon/responses/ -stats -silent
   ```
   (riesgo: activo, rate-limit 50 req/s — respetar SCOPE.md)
5. [ ] Extraer hosts vivos:
   `jq -r '.url' $BASE/spec/01-recon/httpx.json | sort -u > $BASE/spec/01-recon/probed.txt`
6. [ ] Marcar cada paso en LEDGER.md conforme se completa.

## Artefactos terminados (todos nonzero bytes)
- spec/01-recon/subdomains.txt
- spec/01-recon/httpx.json
- spec/01-recon/probed.txt  (una URL por línea)

## Regla de oro
Todo comando guarda salida a archivo con ruta absoluta. Un paso sin archivo de salida cuenta como NO ejecutado.
SKILLEOF

mkdir -p ~/.claude/skills/js-analyze
cat > ~/.claude/skills/js-analyze/SKILL.md <<'SKILLEOF'
---
name: js-analyze
description: Descarga y analiza JavaScript (inline, externo, lazy-loaded, histórico, source maps) de los hosts vivos. Produce endpoints, secretos y gadgets. Dos fases para combatir completion bias.
---

# js-analyze — DOS FASES: discover/download → analyze

Entrada: $BASE/spec/01-recon/probed.txt

## FASE 1 — discover/download
1. [ ] Por cada sitio vivo, descargar HTML inicial con curl y UA real. NUNCA uses el fetch integrado del agente: su user-agent es bloqueado por bot protection y no lo verás fallar.
   `curl -sS --max-time 15 -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" <url> -o $BASE/spec/02-js/raw/<host>/index.html`
2. [ ] Extraer todos los <script src> y bloques inline del HTML.
3. [ ] JS lazy-loaded: registrar chunks cargados tras clicks/autenticación. Si el sitio exige navegador real, usar Interceptor (modo spider) y volcar el tráfico a $BASE/traffic/.
4. [ ] Histórico (Wayback + otras cachés): encontrar APIs v1/v2 aún vivas pero no enlazadas.
   `waymore -i <dominio> -o $BASE/spec/02-js/historical/`
5. [ ] Source maps: probar <js>.map por cada archivo, /static/js/*.map, y revisar la app móvil si existe (mismo bundle).
6. [ ] Marcar fase 1 en LEDGER.md y cerrar esta fase (contexto nuevo para la 2).

## FASE 2 — analyze
7. [ ] Deofuscar/deminificar con jsluice o JScout sobre $BASE/spec/02-js/raw/.
8. [ ] Endpoints + parámetros → $BASE/spec/02-js/endpoints.jsonl (una línea JSON por endpoint: url, method, params, source).
9. [ ] Secretos: regex conocidos + strings de alta entropía (≥20 chars, charset mixto).
10. [ ] Gadgets JS y sinks peligrosos (postMessage, eval, innerHTML, document.write).
11. [ ] APIs viejas y librerías con versión + CVE conocido.
12. [ ] Comentarios interesantes del código (feature flags, rutas internas, credenciales en comentarios).
13. [ ] Marcar fase 2 en LEDGER.md.

## Artefactos terminados
spec/02-js/{raw/, historical/, endpoints.jsonl, secrets.txt, gadgets.md, analysis.md}

## Por qué dos fases
Completion bias: con una skill de 13 pasos el modelo hará los primeros 3 y dirá "listo". Dividir obliga a completar cada fase por separado.
SKILLEOF

mkdir -p ~/.claude/skills/content-discovery
cat > ~/.claude/skills/content-discovery/SKILL.md <<'SKILLEOF'
---
name: content-discovery
description: Fuerza bruta de rutas/archivos con lista genérica + lista personalizada derivada del JS y framework del objetivo.
---

# content-discovery

Entrada: $BASE/spec/01-recon/probed.txt y $BASE/spec/02-js/

## Pasos
1. [ ] Lista GENÉRICA contra hosts vivos:
   ```
   ffuf -u <url>/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt      -mc all -fc 404 -t 40 -timeout 8 -of json -o $BASE/spec/03-content/ffuf-generic.json
   ```
   (activo, rate controlado; verificar que el host está en SCOPE.md)
2. [ ] Detectar framework/paths propios analizando spec/02-js/raw/ y comentarios.
3. [ ] Construir $BASE/spec/03-content/custom-wordlist.txt: paths de API v1/v2, admin, config, backup, .env, .git, swagger, actuators.
4. [ ] Lista PERSONALIZADA:
   ```
   ffuf -u <url>/FUZZ -w $BASE/spec/03-content/custom-wordlist.txt      -mc all -fc 404 -t 40 -timeout 8 -of json -o $BASE/spec/03-content/ffuf-custom.json
   ```
5. [ ] Por cada hallazgo con status interesante (2xx/3xx, directorio listado, backup, .git) crear finding preliminar en $BASE/findings/prelim-<slug>.md.
6. [ ] Marcar LEDGER.md.

## Artefactos terminados
spec/03-content/{custom-wordlist.txt, ffuf-generic.json, ffuf-custom.json} — todos nonzero.
SKILLEOF

mkdir -p ~/.claude/skills/vuln-scan
cat > ~/.claude/skills/vuln-scan/SKILL.md <<'SKILLEOF'
---
name: vuln-scan
description: Detección de vulnerabilidades dividida por categorías en subagentes (completion bias). Nuclei + validación manual asistida con evidencia.
---

# vuln-scan

REGLA DE SEGURIDAD: ninguna categoría destructiva (fuzzing de escritura, DoS, spam, DELETE) se ejecuta sin confirmación explícita del operador.

## Pasos
1. [ ] Nuclei con sintaxis completa sobre hosts vivos:
   ```
   nuclei -l $BASE/spec/01-recon/probed.txt -s critical,high,medium      -rl 50 -c 25 -timeout 8 -stats -j -o $BASE/findings/nuclei.json
   ```
   (activo: 50 req/s; confirmar que SCOPE.md lo autoriza)
2. [ ] Lanzar cada categoría como SUBAGENTE independiente (no una sola corrida):
   - xss-reflejado, xss-almacenado, xss-dom, xss-ciego
   - ssrf-fase1-identificacion → ssrf-fase2-post-explotacion (DOS pasos, no uno)
   - idor, auth/login, oauth/redirect
3. [ ] Validar CANDIDATO de nuclei a CONFIRMADO: reproducir con curl, guardar request/response en $BASE/findings/<slug>/.
4. [ ] SSRF: priorizar escaneo de localhost/paneles admin internos sobre AWS metadata (método viejo, hoy requiere header). Lección de la charla: el training data empuja métodos obsoletos; indicar el objetivo moderno explícitamente.
5. [ ] Cadena de "breadcrumbs": si dos lows pueden encadenarse a crítico, marcar para revisión humana (la IA no encadena sola).
6. [ ] Por vuln confirmada: $BASE/findings/<slug>.md con severidad, evidencia (archivos nonzero), curl de reproducción, impacto.
7. [ ] Marcar LEDGER.md.

## Artefactos terminados
findings/nuclei.json + findings/*.md cada uno con evidencia en disco.
SKILLEOF

mkdir -p ~/.claude/skills/report
cat > ~/.claude/skills/report/SKILL.md <<'SKILLEOF'
---
name: report
description: Consolida findings validados en REPORTE.md ejecutivo. Corrige la inflación de severidad de la IA contra el impacto real demostrado.
---

# report

## Pasos
1. [ ] Leer todos los findings/*.md del proyecto.
2. [ ] Descartar falsos positivos con justificación de una línea cada uno.
3. [ ] Construir $BASE/findings/REPORTE.md:
   - Resumen ejecutivo (3-5 líneas)
   - Tabla de severidades (crítica/alta/media/baja + conteo)
   - Por cada vuln: descripción, evidencia (ruta a archivos nonzero), curl de reproducción, impacto, remediación
4. [ ] ANTI-INFLACIÓN: la IA sobre-califica severidad. Si no hay prueba de impacto real (dato robado, auth bypassado), bajar un nivel y anotarlo.
5. [ ] Marcar LEDGER.md.

## Artefacto terminado
findings/REPORTE.md (nonzero), con evidencias referenciadas que existen en disco.
SKILLEOF

mkdir -p ~/.claude/skills/review
cat > ~/.claude/skills/review/SKILL.md <<'SKILLEOF'
---
name: review
description: Auditor de completitud que corre al final de CADA fase. Verifica LEDGER y artefactos nonzero. En fallo emite el nudge prompt exacto. No rehace trabajo, solo audita.
---

# review — auditor, no ejecutor

## Pasos
1. [ ] Leer $BASE/LEDGER.md: ¿todos los checkboxes están `- [x]`? Listar los faltantes con nombre exacto.
2. [ ] Por cada paso marcado: verificar que el artefacto declarado existe y es nonzero bytes (`test -s <ruta>`). Listar los que falten o estén vacíos.
3. [ ] Verificar que cada herramienta ejecutada tuvo su archivo de salida/log.
4. [ ] Verificar que la estructura de spec/ y findings/ coincide con la referencia del CLAUDE.md del proyecto.
5. [ ] Emitir veredicto.

## Veredicto
- PASS → imprimir `REVIEW: PASS` + resumen de cobertura (fases completadas / artefactos verificados).
- FAIL → imprimir `REVIEW: FAIL` + lista exacta de lo faltante + reinyectar literalmente:

  "Tu trabajo fue revisado por el skill review: omitiste un paso o el artefacto de prueba es insuficiente. Revisa LEDGER.md y la salida de cada paso, encuentra lo que falta y complétalo."

El operador (o la automatización) debe re-lanzar la fase fallida con ese mensaje hasta obtener PASS.
SKILLEOF

echo "== 2/4 Plantillas y SCOPE en $DEST/pentest/_templates =="
mkdir -p $DEST/pentest/_templates
cat > $DEST/pentest/_templates/CLAUDE-web.md <<'TMPEOF'
# HACKBOT — ciclo autónomo recon → detección → reporte

Rol: operador de pentest web autorizado. Idioma: español. Salidas densas, sin relleno.

## Autoridad de alcance (innegociable)
- SCOPE.md es la única fuente de verdad de objetivos. Todo dominio/IP a tocar debe estar listado ahí.
- Si surge un objetivo fuera de SCOPE.md, DETENTE y pregunta.
- Acciones destructivas (DELETE de registros, fuzzing de escritura, DoS, spam) requieren mi confirmación explícita previa.
- Documentar timestamps en UTC en cada fase.

## Ciclo de fases — HARD GATES
Una fase NO inicia hasta que la anterior recibe `REVIEW: PASS` del skill `review`.

| # | Skill | Artefactos terminados |
|---|-------|----------------------|
| 1 | recon | spec/01-recon/{subdomains.txt,httpx.json,probed.txt} |
| 2 | js-analyze | spec/02-js/{raw/,historical/,endpoints.jsonl,secrets.txt,gadgets.md,analysis.md} |
| 3 | content-discovery | spec/03-content/{custom-wordlist.txt,ffuf-generic.json,ffuf-custom.json} |
| 4 | vuln-scan | findings/nuclei.json + findings/*.md con evidencia |
| 5 | report | findings/REPORTE.md |
| 6 | review | LEDGER.md 100% ✅ + artefactos verificados nonzero |

## LEDGER.md — libro mayor de completitud
- Al iniciar CADA skill, crea o extiende LEDGER.md en la raíz del proyecto con sus pasos como `- [ ]`.
- Al completar un paso, marca `- [x]`. Sin check no cuenta como hecho.
- Todo comando ejecutado debe guardar salida a archivo con ruta absoluta. Comando sin archivo de salida = paso no ejecutado.

## Nudge prompt (uso al fallar review)
Reinyectar textualmente:
"Tu trabajo fue revisado por el skill review: omitiste un paso o el artefacto de prueba es insuficiente. Revisa LEDGER.md y la salida de cada paso, encuentra lo que falta y complétalo."

## Reglas de contexto (de la experiencia en hackbots)
- Rutas ABSOLUTAS siempre: toda herramienta, todo agente, todo artefacto. El agente falla con paths relativos y lo oculta.
- Nunca des solo el nombre de una herramienta ("prueba con httpx"): sintaxis completa con flags (ver skills).
- Salida SIEMPRE en carpetas del proyecto, nunca en la carpeta del skill.
- Los LLM son no deterministas: si un resultado es dudoso, re-ejecuta el paso.
- Human-in-the-loop es requisito de diseño: tú validas findings críticos antes de reportar.

## Cuando termines el ciclo
Imprime: resumen de fases con su veredicto, conteo de findings por severidad, ruta del REPORTE.md, y timestamps UTC de inicio/fin.
TMPEOF

cat > $DEST/pentest/_templates/SCOPE-template.md <<'SCOPEDF'
# SCOPE — única fuente de verdad de objetivos autorizados
# Formato: uno por línea. Ej: https://app.cliente.com, 10.0.0.0/24
# El hackbot NO toca nada que no esté listado aquí.

SCOPEDF

echo "== 3/4 Launcher =="
cat > $DEST/hackbot-run.sh <<'RUNEOF'
#!/bin/bash
# Uso: ./hackbot-run.sh <nombre-cliente>
# Lanza el ciclo autónomo completo del hackbot contra un proyecto creado con nuevo-pentest.sh.
# Riesgo: bajo — solo arranca Claude Code local; el tráfico de scanning sale según SCOPE.md.

CLIENTE=$1
BASE=~/ProjectMajorTom/pentest/$CLIENTE

if [ -z "$CLIENTE" ]; then
  echo "Uso: $0 <cliente>"
  exit 1
fi

if [ ! -f "$BASE/SCOPE.md" ]; then
  echo "✗ No existe $BASE/SCOPE.md — crea el proyecto con nuevo-pentest.sh y llena el alcance"
  exit 1
fi

cd "$BASE" || exit 1
echo "▶ Hackbot iniciando ciclo autónomo en $BASE"
echo "  Alcance: $(grep -v '^#' "$BASE/SCOPE.md" | grep -v '^$' | tr '\n' ' ')"
claude "Ejecuta el ciclo completo del HACKBOT en este proyecto: recon → js-analyze → content-discovery → vuln-scan → report → review. Respeta SCOPE.md como única fuente de verdad y las hard gates del CLAUDE.md. No omitas ningún paso: LEDGER.md debe quedar 100% marcado."
RUNEOF
chmod +x $DEST/hackbot-run.sh

# Alinear nuevo-pentest.sh a la nueva ubicación (si existe y aún apunta a ~/work)
if [ -f $DEST/nuevo-pentest.sh ] && grep -q "work/pentest" $DEST/nuevo-pentest.sh; then
  sed -i 's|~/work/pentest|~/ProjectMajorTom/pentest|g' $DEST/nuevo-pentest.sh
  echo "  nuevo-pentest.sh reubicado a ~/ProjectMajorTom/pentest"
fi

echo "== 4/4 Verificación =="
echo "Skills: $(ls ~/.claude/skills | tr '\n' ' ')"
echo "Templates: $(ls $DEST/pentest/_templates | tr '\n' ' ')"
echo ""
echo "Flujo:"
echo "  ./nuevo-pentest.sh <cliente> web && nano ~/ProjectMajorTom/pentest/<cliente>/SCOPE.md"
echo "  ./hackbot-run.sh <cliente>"
