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
