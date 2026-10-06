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
