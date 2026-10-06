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
