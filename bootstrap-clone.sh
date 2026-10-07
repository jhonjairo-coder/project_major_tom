#!/bin/bash
# bootstrap-clone.sh — Deja un clone recien clonado listo para correr el hackbot.
# Uso: ./bootstrap-clone.sh   (desde la raiz del repo, CUALQUIER ruta/nombre)
# Idempotente: re-ejecutable sin miedo. Riesgo: bajo (crea enlaces y un respaldo).
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ok(){   echo "  [OK] $1"; }
warn(){ echo "  [!!] $1"; }

echo "== BOOTSTRAP: $ROOT =="

# 1. Permisos de scripts
chmod +x "$ROOT"/*.sh 2>/dev/null
ok "permisos +x en *.sh"

# 2. Enlaces de skills: DINAMICO (todo directorio con SKILL.md, menos synced)
mkdir -p ~/.claude/skills
n=0
for d in "$ROOT"/brain/skills/*/; do
  s="$(basename "$d")"
  [ "$s" = "synced" ] && continue
  if [ ! -s "$d/SKILL.md" ]; then
    warn "skill '$s' sin SKILL.md nonzero (se omite)"
    continue
  fi
  ln -sfn "$d" ~/.claude/skills/"$s"
  n=$((n+1))
done
ok "$n skills enlazados en ~/.claude/skills"

# 3. LEARNINGS + memoria global (con respaldo si ya existe una)
ln -sfn "$ROOT/brain/LEARNINGS.md" ~/.claude/LEARNINGS.md
ok "enlace ~/.claude/LEARNINGS.md -> brain/LEARNINGS.md"
if [ -f ~/.claude/CLAUDE.md ] && [ ! -L ~/.claude/CLAUDE.md ]; then
  cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak.$(date +%Y%m%d%H%M%S)
  warn "CLAUDE.md existente respaldado (.bak.TIMESTAMP)"
fi
cp "$ROOT/CLAUDE-global.md" ~/.claude/CLAUDE.md
ok "memoria global instalada en ~/.claude/CLAUDE.md"

# 4. Inventario de herramientas de ESTA maquina (el commiteado es de otra PC)
if command -v python3 >/dev/null 2>&1 && [ -f "$ROOT/tools-inventory.py" ]; then
  (cd "$ROOT" && python3 tools-inventory.py >/dev/null 2>&1)
  ok "tools-inventory.md regenerado segun ESTE PC"
else
  warn "sin python3 o tools-inventory.py: regenera el inventario luego"
fi

# 5. Identidad git LOCAL al repo (no toca tu config global)
if ! git -C "$ROOT" config user.name >/dev/null 2>&1; then
  git -C "$ROOT" config user.name  "$(whoami)"
  git -C "$ROOT" config user.email "$(whoami)@$(hostname)"
  warn "identidad git local puesta por defecto; si vas a pushear, configura la real:"
  warn "  git config user.name \"Tu Nombre\" && git config user.email \"tu@correo.com\""
fi

# 6. Verificacion final (la puerta de salida del sistema)
echo ""
echo "== VERIFICACION =="
if [ -x "$ROOT/verificar-hackbot.sh" ]; then
  "$ROOT/verificar-hackbot.sh" | tail -4
  echo ""
  echo "Notas:"
  echo "  - FAIL de binarios: instala o copia el binario Go estatico desde otra PC."
  echo "  - FAIL de git/SSH: agrega tu llave en github.com/settings/keys y prueba: ssh -T git@github.com"
  echo "  - Si el remote es https:// cambialo: git remote set-url origin git@github.com:USER/REPO.git"
else
  warn "verificar-hackbot.sh no encontrado en la raiz"
fi
