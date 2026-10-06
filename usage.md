# HACKBOT — USO RAPIDO (~/ProjectMajorTom)
# Referencia visual: xdg-open mapa-archivos-hackbot.html
# Mapa de red: xdg-open mapa-neuronal-obsidian.html

## 0. ANTES DE CADA SESION (sanidad del sistema)
cd ~/ProjectMajorTom && ./verificar-hackbot.sh    # objetivo: FAIL: 0

## 1. CREAR PROYECTO (abre el caso)
./nuevo-pentest.sh Acme api            # api|web  [3er arg: claude|opencode|kimi = multi-harness]
echo "https://app.acme.com" > pentest/Acme/SCOPE.md   # sin esto, gate G1 aborta

## 2. LANZAR (autonomo: recon -> js -> content -> vuln-scan -> report -> review)
./hackbot-run.sh Acme                  # registra el costo solo en costos.log
# objetivo local de prueba: crAPI (docker compose -f ~/crAPI-main/deploy/docker/docker-compose.yml up -d)

## 3. REVISAR (TÚ, human-in-the-loop)
cat pentest/Acme/findings/REPORTE.md
cat pentest/Acme/LEDGER.md             # debe estar 100% marcado
./informes_html.py pentest/Acme        # INFORME.html profesional
xdg-open pentest/Acme/INFORME.html

## 4. APRENDIZAJE (ciclo retro -> LEARNINGS -> skills)
cat brain/LEARNINGS.md                 # propuestas de retro: valida/descarta
# promueves al SKILL.md -> git add -A && git commit -m "promueve skill X: regla"

## 5. COSTO
./pentest/Acme/costo.sh                # o: ./costo-corrida.sh Acme [horas]
cat costos.log                         # historial de baseline

## MULTI-HARNESS (comparar modelos)
./nuevo-pentest.sh Acme api claude && ./nuevo-pentest.sh Acme api opencode && ./nuevo-pentest.sh Acme api kimi
for h in claude opencode kimi; do echo "https://app.acme.com" > pentest/Acme-$h/SCOPE.md; done
./hackbot-run.sh Acme-claude           # en otras 2 terminales: opencode/kimi con su CLI
# cuando los 3 terminen (REVIEW: PASS en cada LEDGER):
cd pentest/Acme-claude && claude "ejecuta el skill conglomerar"   # tabla de atribucion

## REGLAS DE ORO (incidentes reales del 2026-10-06)
# - SCOPE.md es la unica verdad. Nada fuera de el, nunca.
# - PoC con EFECTO PERSISTENTE (cambiar password, DELETE, takeover): SOLO con tu confirmacion en sesion.
# - PROHIBIDO para el agente afirmar "el operador autorizo" sin que pregunto.
# - Subagente que termina su categoria se DETIENE; pivotear a otra = scope creep.
# - El agente propone en LEARNINGS.md; TU promueves a skills. Nunca al reves.
# - Artefacto de 0 bytes = paso no ejecutado (asi lo audita review).
NOTA: ejecutar siempre desde ~/ProjectMajorTom (cd primero); rutas relativas asumen la raiz del repo.
