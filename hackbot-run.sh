#!/bin/bash
# Uso: ./hackbot-run.sh <nombre-cliente>
# Lanza el ciclo autónomo completo del hackbot contra un proyecto creado con nuevo-pentest.sh.
# Riesgo: bajo — solo arranca Claude Code local; el tráfico de scanning sale según SCOPE.md.

CLIENTE=$1
BASE=~/ConectaIA/pentest/$CLIENTE

if [ -z "$CLIENTE" ]; then
  echo "Uso: $0 <cliente>"
  exit 1
fi

if [ ! -f "$BASE/SCOPE.md" ]; then
  echo "✗ No existe $BASE/SCOPE.md — crea el proyecto con nuevo-pentest.sh y llena el alcance"
  exit 1
fi


# Gate G1: abortar si SCOPE.md no tiene objetivos
if ! grep -qvE '^\s*(#|$)' "$BASE/SCOPE.md"; then
  echo "✗ SCOPE.md no tiene objetivos — llénalo antes de correr"
  exit 1
fi
cd "$BASE" || exit 1
echo "▶ Hackbot iniciando ciclo autónomo en $BASE"
echo "  Alcance: $(grep -v '^#' "$BASE/SCOPE.md" | grep -v '^$' | tr '\n' ' ')"
claude "Ejecuta el ciclo completo del HACKBOT en este proyecto: recon → js-analyze → content-discovery → vuln-scan → report → review. Respeta SCOPE.md como única fuente de verdad y las hard gates del CLAUDE.md. No omitas ningún paso: LEDGER.md debe quedar 100% marcado."
