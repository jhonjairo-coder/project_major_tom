---
name: tools
description: Seleccion de herramientas para cualquier fase. Consulta el catalogo vivo tools-inventory.md y elige la mejor INSTALADA. Usar ANTES de ejecutar comandos en recon, js-analyze, content-discovery y vuln-scan.
---

# tools — seleccion de herramientas del Kali

## Regla de oro
Antes de ejecutar CUALQUIER herramienta en una fase, lee el catalogo:
`/home/kali/ProjectMajorTom/tools-inventory.md`
(generado desde el sistema real; las marcadas [OK] existen, las [--] no).

## Pasos
1. [ ] Lee la seccion del catalogo correspondiente a la fase.
2. [ ] Elige la herramienta [OK] mas adecuada al subpaso (no siempre la primera).
3. [ ] Escribe la SINTAXIS COMPLETA con flags (nunca solo el nombre).
4. [ ] Salida a artefacto con ruta absoluta; un comando sin archivo de salida cuenta como no ejecutado.
5. [ ] Si ninguna [OK] sirve: NO instalar nada sin el operador. Anota en ~/.claude/LEARNINGS.md (pendiente): herramienta faltante + paquete sugerido.

## Ejemplos de decision
- endpoints historicos: waymore [OK] mejor que waybackurls si ambas existen (mas fuentes).
- fuzzing de dirs: ffuf para precision con wordlist custom; feroxbuster si se necesita recursion.
- secretos en JS: jsluice (estructural) + secretfinder (regex) en complemento, no en sustitucion.
