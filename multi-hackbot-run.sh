#!/bin/bash
# multi-hackbot-run.sh — corridas multi-harness (Claude / OpenCode / Kimi) con findings separados
# Uso:
#   ./multi-hackbot-run.sh crAPI --solo claude     # prepara todo y corre solo Claude
#   ./multi-hackbot-run.sh crAPI --solo opencode   # en OTRA terminal
#   ./multi-hackbot-run.sh crAPI --solo kimi       # en OTRA terminal
# Riesgo: bajo. Prepara carpetas; el trafico de scanning lo decide cada harness segun SCOPE.md.

CLIENTE=$1; shift
SOLO=""
[ "$1" = "--solo" ] && SOLO=$2

SRC=~/ConectaIA/pentest/$CLIENTE
BASE=~/ConectaIA/pentest/${CLIENTE}-multi

if [ ! -f "$SRC/SCOPE.md" ]; then
  echo "Falta $SRC/SCOPE.md (proyecto base). Crealo con nuevo-pentest.sh y llenalo."
  exit 1
fi
if ! grep -qvE '^\s*(#|$)' "$SRC/SCOPE.md"; then
  echo "SCOPE.md sin objetivos"
  exit 1
fi

PROMPT="Ejecuta el ciclo completo del HACKBOT en este proyecto: recon -> js-analyze -> content-discovery -> vuln-scan -> report -> review. Respeta SCOPE.md como unica fuente de verdad y las hard gates del CLAUDE.md. No omitas ningun paso: LEDGER.md debe quedar 100% marcado."

# 1. Preparar una copia de proyecto por harness (findings separados por construccion)
for h in claude opencode kimi; do
  mkdir -p "$BASE/$h"
  cp "$SRC/SCOPE.md" "$BASE/$h/"
  cp "$SRC/CLAUDE.md" "$BASE/$h/CLAUDE.md"
  cp "$SRC/CLAUDE.md" "$BASE/$h/AGENTS.md"   # OpenCode/Kimi leen AGENTS.md
  echo "✓ preparado $BASE/$h"
done

# 2. Lanzar (cada harness en su propia terminal/tmux pane, o --solo)
launch() {
  h=$1
  case $h in
    claude)   (cd "$BASE/claude"   && claude "$PROMPT") ;;
    opencode) (cd "$BASE/opencode" && opencode run "$PROMPT") ;;
    kimi)     (cd "$BASE/kimi"     && kimi "$PROMPT") ;;
  esac
}

if [ -n "$SOLO" ]; then
  command -v $SOLO >/dev/null || { echo "no encuentro el binario: $SOLO"; exit 1; }
  launch $SOLO
else
  echo "Sugerencia: corre cada harness en su propia terminal (o tmux con 3 panes):"
  echo "  ./multi-hackbot-run.sh $CLIENTE --solo claude"
  echo "  ./multi-hackbot-run.sh $CLIENTE --solo opencode"
  echo "  ./multi-hackbot-run.sh $CLIENTE --solo kimi"
fi
