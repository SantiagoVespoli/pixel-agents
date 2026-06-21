#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Arranca el server standalone de pixel-agents en una sesión tmux "pixel".
# Idempotente: si ya está vivo y sano, no hace nada. Pensado para correr desde
# cron (@reboot para persistir tras un reinicio, y cada 5 min como auto-restart).
# No necesita sudo.
# ---------------------------------------------------------------------------
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

RUN_DIR="$HOME/pixel-agents-run"
PORT=3100

# ¿ya está vivo y respondiendo?
if tmux has-session -t pixel 2>/dev/null && curl -sf -o /dev/null "http://127.0.0.1:${PORT}/api/health"; then
  exit 0
fi

# (re)arrancar limpio
tmux kill-session -t pixel 2>/dev/null || true
tmux new-session -d -s pixel "cd '$RUN_DIR' && /usr/bin/node dist/cli.js --port ${PORT} --host 127.0.0.1 > /tmp/pixel.log 2>&1"
echo "[start-vps] server de pixel-agents (re)arrancado en tmux 'pixel' :${PORT}"
