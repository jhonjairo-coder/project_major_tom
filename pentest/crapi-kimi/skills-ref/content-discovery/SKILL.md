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
