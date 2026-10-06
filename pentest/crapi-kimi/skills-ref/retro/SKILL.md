---
name: retro
description: Revision post-corrida, DESPUES de report + review PASS. Analiza fallos, nudges y falsos positivos; propone correcciones en LEARNINGS.md. No rehace trabajo de pentest.
---

# retro — aprendizaje continuo (auditor de proceso, no de vulnerabilidades)

## Pasos
1. [ ] Leer LEDGER.md: contar pasos que necesitaron nudge o reintento.
2. [ ] Revisar veredictos review (PASS/FAIL por fase) de la corrida.
3. [ ] Leer findings/REPORTE.md: falsos positivos descartados y motivo.
4. [ ] Leer ~/.claude/LEARNINGS.md: esta corrida valida o contradice correcciones pendientes.
5. [ ] Escribir propuestas en ~/.claude/LEARNINGS.md:
   | <fecha UTC> | <proyecto> | <fase/skill> | <observacion> | <propuesta> | pendiente |

## Diagnostico por senal
- Nudge repetido en mismo paso -> instruccion ambigua -> subdividir paso en SKILL.md
- REVIEW: FAIL repetido -> artefacto mal definido -> redefinir artefacto / sintaxis completa
- FP repetido de una categoria -> skill sobre-eager -> anadir validacion explicita
- Herramienta "corrio" sin salida -> exigir log nonzero con ruta absoluta
- El modelo hizo bien algo que el skill detalla -> probar quitarlo (claude --safe-mode)
- Hallazgo bueno sin skill que lo cubra -> proponer nuevo paso o micro-skill

## Reglas duras
- NUNCA edites ~/.claude/skills/ — solo propuestas en LEARNINGS.md.
- Correccion observada 3 veces = marcar "promovible".
- Cierre: resumen de propuestas nuevas + conteo pendientes/validadas.
