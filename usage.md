# PASO 1 — Crear el proyecto (abre el caso)
cd ~/ProjectMajorTom
./nuevo-pentest.sh Acme web
# Crea pentest/Acme/ con CLAUDE.md, AGENTS.md, SCOPE.md, carpetas y costo.sh

# PASO 2 — Llenar el alcance (TÚ, antes de cualquier scanning)
vi pentest/Acme/SCOPE.md        # p.ej: https://app.acme.com

# PASO 3 — Lanzar el hackbot (rec + detección + reporte autónomo)
./hackbot-run.sh Acme
# Al terminar, registra el costo solo en costos.log

# PASO 4 — Revisar resultados (TÚ, human-in-the-loop)
cat pentest/Acme/findings/REPORTE.md
cat pentest/Acme/LEDGER.md              # debe estar 100% ✅

# PASO 5 — Aprendizaje (post-corrida)
cat brain/LEARNINGS.md                  # propuestas de retro → validas/promueves
git add -A && git commit -q -m "pentest Acme: baseline + N hallazgos"

# PASO 6 — Costo (cuando quieras, sin orden estricto)
./pentest/Acme/costo.sh
