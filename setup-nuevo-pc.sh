#!/bin/bash
# Uso: ./setup-nuevo-pc.sh  (desde la raiz del repo clonado, CUALQUIER ruta/nombre)
ROOT="$(cd "$(dirname "$0")" && pwd)"
mkdir -p ~/.claude/skills
for s in recon js-analyze content-discovery vuln-scan report review retro conglomerar owasp tools; do
  [ -d "$ROOT/brain/skills/$s" ] && ln -sfn "$ROOT/brain/skills/$s" ~/.claude/skills/$s
done
ln -sfn "$ROOT/brain/LEARNINGS.md" ~/.claude/LEARNINGS.md
[ -f ~/.claude/CLAUDE.md ] && cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak
cp "$ROOT/CLAUDE-global.md" ~/.claude/CLAUDE.md
chmod +x "$ROOT"/*.sh 2>/dev/null
echo "✓ PC configurado. Verificando:"
"$ROOT/verificar-hackbot.sh" | tail -3
