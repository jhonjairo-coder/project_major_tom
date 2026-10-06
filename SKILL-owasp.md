---
name: owasp
description: Metodologia de pruebas basada en OWASP API Security Top 10 (2023). Ejecuta TODAS las categorias como subagentes, documenta cobertura en spec/owasp-coverage.md y nunca omite una categoria sin razon. Usar en la fase vuln-scan (api).
---

# owasp — cobertura sistematica OWASP API Security Top 10 2023

REGLA DURA: se prueban las 10 categorias, una como subagente independiente (anti completion bias).
Ninguna categoria se omite sin razon escrita. Efectos persistentes SOLO con confirmacion del operador (gate de autorizacion).

Despues de cada categoria, actualiza la matriz spec/owasp-coverage.md:
| ID | Categoria | Estado | Hallazgo(s) | Evidencia |
Estados: HALLAZGO / SIN HALLAZGO / PARCIAL / NO APLICA / NO PROBADO (con razon)

## API1:2023 — Broken Object Level Authorization (BOLA)
1. [ ] De spec/02-js/endpoints.jsonl: listar endpoints con {id} en path o body.
2. [ ] Crear usuarios A y B; por cada endpoint, token_A pidiendo objeto de B.
3. [ ] Enumerar IDs secuenciales (1..50) buscando 200 con datos ajenos.
4. [ ] Probar IDs de otros tenants si aplica (guid/uuid compartidos).

## API2:2023 — Broken Authentication
1. [ ] JWT: alg confusion (RS256->HS256), alg:none, firma vacia, weak secret (hashcat -m 16500), kid/jwk injection, exp ausente.
2. [ ] Login: rate limiting (20 intentos), enumeracion (mensaje distinto user vs pass), timing.
3. [ ] Password reset: predecibilidad de OTP, reuso, expiracion, token en URL.
4. [ ] Registro: campos de rol/privilegio aceptados.

## API3:2023 — Broken Object Property Level Authorization
1. [ ] Mass assignment: inyectar campos extra en signup/change-email/profile (role, isAdmin, balance, available_credit, id).
2. [ ] Excessive data exposure: comparar respuesta vs campos usados por el frontend (sus datos internos expuestos).

## API4:2023 — Unrestricted Resource Consumption
1. [ ] Rate limiting en endpoints caros (login, search, upload).
2. [ ] Paginacion: pageSize gigante, omision de limit.
3. [ ] Upload: tamano y tipo sin restriccion.

## API5:2023 — Broken Function Level Authorization (BFLA)
1. [ ] Endpoints admin (/admin, /internal) con token de usuario normal.
2. [ ] Verb tampering: PUT/DELETE/PATCH en rutas de solo lectura.
3. [ ] Paths de js-analyze no enlazados: probar sin auth y con user.

## API6:2023 — Unrestricted Access to Sensitive Business Flows
1. [ ] Flujos criticos (compra, reserva, transferencia): automatizar repeticion completa sin friccion.
2. [ ] Pasos del flujo saltables (llamar al paso N sin N-1).

## API7:2023 — Server-Side Request Forgery (SSRF)
1. [ ] FASE 1 identificacion: parametros tipo URL (webhook, avatar, url, api) -> canario interno.
2. [ ] FASE 2 post-explotacion: 127.0.0.1/localhost/puertos, 169.254.169.254, esquemas file/dict/gopher, servicios internos Docker (nombres de host comunes: mailhog, mongodb, redis).
3. [ ] Bypasses: decimal IP, 127.1, [::1], redirects, DNS rebind (documentar si no aplica).

## API8:2023 — Security Misconfiguration
1. [ ] Archivos: /.env, /.git/config, /swagger*, /actuator/*, backup, *.log, *.map, .DS_Store.
2. [ ] Headers: security headers ausentes, CORS wildcard con credentials, metodos habilitados (OPTIONS), stack traces/verbose errors.

## API9:2023 — Improper Inventory Management
1. [ ] Versiones viejas: /v1, /v2, /api/v1... (del wordlist custom de content-discovery).
2. [ ] Ambientes: /dev, /staging, /test, /debug, /internal.
3. [ ] Endpoints del JS no documentados en el spec publico.

## API10:2023 — Unsafe Consumption of APIs
1. [ ] URLs de terceros en respuestas del servidor (redirecciones, fetch server-side a dominios de entrada).
2. [ ] Webhooks: firma/validacion del emisor, replay.

## Anexo web (proyectos tipo web, WSTG resumen)
- INFO: fingerprint (whatweb), archivos expuestos, comentarios.
- ATHN/ATHZ/Sess: login, reset, sesion, escalado de privilegios.
- INPV: XSS (reflejado/almacenado/DOM), SQLi (sqlmap), template injection, XXE.
- CLIENT: CORS, clickjacking, postMessage.
