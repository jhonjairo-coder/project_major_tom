#!/bin/bash
ROOT="$(cd "$(dirname "$0")" && pwd)"
# verificar-hackbot.sh — chequeo completo de la instalación del hackbot
# Uso: ./verificar-hackbot.sh   |   Riesgo: nulo, solo lee.

PASS=0; FAIL=0
ok()   { echo "  PASS  $1"; PASS=$((PASS+1)); }
bad()  { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }
chk()  { if eval "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1  -->  $3"; fi; }

echo "== 1. Cerebro y enlaces =="
chk "cerebro existe"                "[ -d "$ROOT"/brain/skills ]"                 "mkdir -p "$ROOT"/brain/skills"
chk "skills accesibles via ~/.claude/skills" "[ $(ls ~/.claude/skills/*/SKILL.md 2>/dev/null | wc -l) -ge 7 ]" "ln -s "$ROOT"/brain/skills/<skill> ~/.claude/skills/"
chk "LEARNINGS.md existe y nonzero" "[ -s "$ROOT"/brain/LEARNINGS.md ]"           "crear "$ROOT"/brain/LEARNINGS.md (ver formato tabla)"
chk "enlace LEARNINGS"              "[ -L ~/.claude/LEARNINGS.md ] && [ -e ~/.claude/LEARNINGS.md ]" "ln -s "$ROOT"/brain/LEARNINGS.md ~/.claude/LEARNINGS.md"
chk "git versionando ProjectMajorTom" "[ -d "$ROOT"/.git ]" "cd "$ROOT" && git init"

echo "== 2. Skills (7, con SKILL.md nonzero y name coincidente) =="
for s in recon js-analyze content-discovery vuln-scan report review retro; do
  chk "skill $s" "[ -s "$ROOT"/brain/skills/$s/SKILL.md ] && grep -q '^name: $s\$' "$ROOT"/brain/skills/$s/SKILL.md" "reinstalar skill $s"
done

echo "== 3. Memoria global =="
chk "CLAUDE.md global"              "[ -s ~/.claude/CLAUDE.md ]"                      "copiar CLAUDE-global.md a ~/.claude/CLAUDE.md"
chk "global referencia LEARNINGS"   "grep -q LEARNINGS ~/.claude/CLAUDE.md"           "agregar regla de lectura de LEARNINGS.md"

echo "== 4. Plantillas y proyecto =="
chk "CLAUDE-web.md template"        "[ -s "$ROOT"/pentest/_templates/CLAUDE-web.md ]"  "cp templates/CLAUDE-web.md"
chk "CLAUDE-api.md template"        "[ -s "$ROOT"/pentest/_templates/CLAUDE-api.md ]"  "generar CLAUDE-api.md desde CLAUDE-web.md"
chk "SCOPE-template"                "[ -s "$ROOT"/pentest/_templates/SCOPE-template.md ]" "reinstalar"
chk "crAPI/CLAUDE.md orquestador"   "grep -q 'HARD GATES' "$ROOT"/pentest/crAPI/CLAUDE.md 2>/dev/null" "cp _templates/CLAUDE-api.md a crAPI/CLAUDE.md"
chk "crAPI/SCOPE.md con objetivo"   "grep -qvE '^\\s*(#|$)' "$ROOT"/pentest/crAPI/SCOPE.md 2>/dev/null" "echo 'http://localhost:8888' > crAPI/SCOPE.md"
chk "snippet aprendizaje en orquestador" "grep -q 'skill .retro' "$ROOT"/pentest/crAPI/CLAUDE.md 2>/dev/null" "cat aprendizaje-snippet.md >> crAPI/CLAUDE.md"

echo "== 5. Scripts ejecutables =="
chk "nuevo-pentest.sh"              "[ -x "$ROOT"/nuevo-pentest.sh ]"             "chmod +x"
chk "hackbot-run.sh"                "[ -x "$ROOT"/hackbot-run.sh ]"               "chmod +x"
chk "hackbot-run gate scope vacío"  "grep -q 'SCOPE.md no tiene objetivos' "$ROOT"/hackbot-run.sh" "agregar gate G1 al script"

echo "== 6. Herramientas de Kali =="
for t in claude jq curl git; do
  chk "nucleo: $t" "command -v $t" "sudo apt install $t"
done
if [ -f "$ROOT/tools-inventory.md" ]; then
  while IFS= read -r tool; do
    chk "herramienta: $tool" "command -v $tool" "reinstalar $tool"
  done < <(grep '^| \[OK\]' "$ROOT/tools-inventory.md" | awk -F'|' '{gsub(/[ `]/,"",$3); print $3}' | sort -u)
else
  echo "  WARN  sin tools-inventory.md -> generar: python3 tools-inventory.py"
fi
chk "SecLists (ffuf)"               "[ -f /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt ]" "sudo apt install seclists"

echo ""
echo "======================================="
echo "  PASS: $PASS   FAIL: $FAIL"
[ $FAIL -eq 0 ] && echo "  TODO LISTO - puedes correr: ./hackbot-run.sh crAPI" || echo "  Corrige los FAIL y vuelve a ejecutar este script"
