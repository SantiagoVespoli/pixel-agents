#!/usr/bin/env bash
# Test de la feature de puertos: lanza un agente que abre puertos y verifica
# que el server emite agentPortsUpdate por WebSocket. Correr EN el VPS.
set -u

tmux kill-session -t porttest 2>/dev/null

PROMPT='Con la herramienta Bash ejecuta estos dos comandos, uno por uno: "timeout 2 python3 -m http.server 8099" y luego "echo http://localhost:5173/". Despues confirmame en una linea que los ejecutaste.'
tmux new-session -d -s porttest "cd ~ && claude -p '$PROMPT' > /tmp/porttest.out 2>&1"
echo "agente lanzado, escuchando WebSocket ~35s..."

node -e '
const got = [];
const ws = new WebSocket("ws://127.0.0.1:3100/ws");
ws.onopen = () => ws.send(JSON.stringify({ type: "webviewReady" }));
ws.onmessage = (e) => {
  try {
    const m = JSON.parse(e.data);
    if (m.type === "agentPortsUpdate") {
      got.push(m);
      console.log("  >> agentPortsUpdate id=" + m.id + " ports=" + JSON.stringify(m.ports));
    }
  } catch {}
};
setTimeout(() => {
  const all = new Set(got.flatMap((g) => g.ports));
  console.log("=== mensajes agentPortsUpdate: " + got.length + " | puertos unicos: " + JSON.stringify([...all]) + " ===");
  process.exit(0);
}, 35000);
' 2>&1 | grep -vE "ExperimentalWarning|node --"

echo "=== salida del agente ==="
tail -5 /tmp/porttest.out
