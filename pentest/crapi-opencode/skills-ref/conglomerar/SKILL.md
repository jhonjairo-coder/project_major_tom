---

name: conglomerar
description: Fusiona findings de corridas multi-harness (proyectos <cliente>-claude/-opencode/-kimi) en REPORTE-CONSOLIDADO.md con atribucion. Correr SOLO cuando TODAS las corridas terminaron (REVIEW: PASS en cada una).

---

# conglomerar — reporte consolidado multi-harness (patron Armada)

## Entrada

Busca corridas en pentest/<cliente>-*/ (el .harness de cada proyecto dice cual es).
Ejemplo: pentest/crAPI-claude/, pentest/crAPI-opencode/, pentest/crAPI-kimi/

## Pasos

1. [ ] Verificar que CADA corrida termino: findings/REPORTE.md existe y LEDGER.md 100% marcado.
Falta alguna -> DETENTE y di cual.
2. [ ] Leer todos los findings/*.md de cada corrida.
3. [ ] Dedup: mismo endpoint + misma clase de vulnerabilidad = UN finding consolidado;
conservar lista de fuentes (harnesses).
4. [ ] Por finding consolidado: severidad = maxima entre fuentes justificada con la mejor
evidencia; atribucion = harness(es) que lo reportaron.
5. [ ] Hallazgos UNICOS por harness: resaltarlos — miden la diversidad que aporta cada modelo.
6. [ ] Escribir pentest/<cliente>-CONSOLIDADO/REPORTE-CONSOLIDADO.md:

- tabla: | hallazgo | severidad | claude | opencode | kimi |
- detalle por finding (evidencia + fuente + curl repro)
- cobertura: categorias cubiertas y GAPS (nadie las cubrio -> candidatas a micro-skill)
- metricas por harness: % LEDGER, nudges, confirmados/FP, costo si hay costo-corrida.sh

7. [ ] Registrar en ~/.claude/LEARNINGS.md (pendiente): que harness encuentra que,
donde fallo cada uno, gaps de cobertura.

## Reglas

- NO inventar findings que ninguna corrida reporto.
- Finding de un solo harness se marca "unconfirmed-single-source" para validacion humana prioritaria.
- Dos fuentes discrepan en severidad -> reportar ambas con justificacion.