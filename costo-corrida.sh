#!/bin/bash
# costo-corrida.sh — costo por corrida y promedio de un proyecto del hackbot
# Uso: ./costo-corrida.sh <proyecto>   (default crAPI)
# Riesgo: nulo — solo lee ~/.claude/projects.

PROYECTO=${1:-crAPI}

# === PRECIOS POR MILLON DE TOKENS (USD) — ACTUALIZA segun tu modelo/plan ===
P_IN=3.0      # input
P_OUT=15.0    # output (5-10x el input)
P_CW=3.75     # cache write = 1.25 x input
P_CR=0.30     # cache read  = 0.10 x input
# Referencias aproximadas (verifica las vigentes): nivel medio ~3/15,
# nivel alto ~15/75, nivel economico ~0.8/4

DIR=$(ls -d ~/.claude/projects/*pentest*"$PROYECTO"* 2>/dev/null | head -1)
[ -z "$DIR" ] && { echo "No se encontraron sesiones para $PROYECTO en ~/.claude/projects"; exit 1; }

echo "Proyecto: $PROYECTO ($DIR)"
printf "%-14s | %-10s | %11s | %10s | %11s | %11s | %10s\n" \
  "sesion" "fecha" "input" "output" "cache_w" "cache_r" "costo USD"
echo "-----------------------------------------------------------------------------------------------"

for f in "$DIR"/*.jsonl; do
  jq -rs --arg f "$(basename "$f" .jsonl | cut -c1-13)" --arg d "$(date -r "$f" +%F)" '
    ([.[] | select(.type=="assistant" and .message.usage) | .message.usage]) as $u
    | ($u | map(.input_tokens)                      | add // 0) as $i
    | ($u | map(.output_tokens)                     | add // 0) as $o
    | ($u | map(.cache_creation_input_tokens // 0)  | add)      as $cw
    | ($u | map(.cache_read_input_tokens  // 0)     | add)      as $cr
    | select($i + $o > 0)
    | [$f, $d, $i, $o, $cw, $cr] | @tsv' "$f" 2>/dev/null
done | awk -F'\t' -v pin="$P_IN" -v pout="$P_OUT" -v pcw="$P_CW" -v pcr="$P_CR" '{
  cost = $3/1e6*pin + $4/1e6*pout + $5/1e6*pcw + $6/1e6*pcr;
  printf "%-14s | %-10s | %'\''%d'\'' | %'\''%d'\'' | %'\''%d'\'' | %'\''%d'\'' | $%.4f\n", $1, $2, $3, $4, $5, $6, cost;
  n++; ti+=$3; to+=$4; tcw+=$5; tcr+=$6; tc+=cost;
} END {
  if (n > 0)
    printf "\nCORRIDAS CON USO: %d\nTOTAL:            $%.4f\nPROMEDIO/corrida: $%.4f\nTokens promedio:  input %'\''%d'\'' | output %'\''%d'\'' | cache_write %'\''%d'\'' | cache_read %'\''%d'\''\n", n, tc, tc/n, ti/n, to/n, tcw/n, tcr/n;
  else
    print "No se encontraron mensajes con usage (¿ya corriste el hackbot?).";
}'
