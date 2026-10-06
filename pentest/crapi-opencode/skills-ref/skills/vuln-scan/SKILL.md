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
