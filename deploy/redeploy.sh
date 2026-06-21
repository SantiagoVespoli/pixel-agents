#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Recompila pixel-agents desde ESTE fork y redeploya el build al VPS.
# Usar después de cambiar código del repo. Correr desde la raíz del repo en
# Git Bash:   bash deploy/redeploy.sh
#
# El build pesado queda en tu PC; al VPS solo viaja el dist/ (sin npm install).
# ---------------------------------------------------------------------------
set -euo pipefail

HOST="${PIXEL_VPS_HOST:-aumenta}"      # alias del ssh config
RUN_DIR="pixel-agents-run"             # carpeta de runtime en el home del VPS

echo "[1/4] build: mensajes + webview + cli..."
npm run asyncapi:generate
npm run build:webview
node esbuild.js --production

echo "[2/4] subiendo dist al VPS ($HOST)..."
ssh "$HOST" "mkdir -p ~/$RUN_DIR/dist"
scp -q dist/cli.js "$HOST:~/$RUN_DIR/dist/"
scp -qr dist/webview dist/assets dist/hooks "$HOST:~/$RUN_DIR/dist/"

echo "[3/4] refrescando hook script (workaround del bug dist/dist)..."
ssh "$HOST" "mkdir -p ~/.pixel-agents/hooks && cp ~/$RUN_DIR/dist/hooks/claude-hook.js ~/.pixel-agents/hooks/claude-hook.js && chmod +x ~/.pixel-agents/hooks/claude-hook.js"

echo "[4/4] reiniciando server..."
ssh "$HOST" "tmux kill-session -t pixel 2>/dev/null; bash ~/$RUN_DIR/start.sh; sleep 2; curl -s -o /dev/null -w 'pixel: HTTP %{http_code}\n' http://127.0.0.1:3100/api/health"

echo "✅ redeploy completo. Abrí el túnel y mirá http://localhost:3100"
