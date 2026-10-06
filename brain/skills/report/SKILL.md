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
6. [ ] Verificar que existe spec/owasp-coverage.md con las 10 categorias API (+ anexo web si aplica). Faltan categorias sin razon -> FAIL de review.
