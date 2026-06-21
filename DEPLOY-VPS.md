# 🖥️ Pixel Agents en el VPS de Aumenta — instructivo

Este fork corre el **server standalone de pixel-agents** en el VPS para visualizar
los agentes de Claude Code (de cualquier sesión tmux) como personajes en una oficina.

> El build pesado se hace en tu PC. Al VPS solo viaja el `dist/` + un runtime mínimo
> de Fastify (instalado con `--ignore-scripts`). No corre el `npm install` del repo
> externo en el server compartido.

## Arquitectura

```
Claude (en tmux)  →  hooks  →  server pixel-agents (VPS, :3100)  →  webview
        │                              (lee también los JSONL de ~/.claude/projects)
        └─ vos lo ves desde tu PC por un túnel SSH → http://localhost:3100
```

- **Server en el VPS:** `~/pixel-agents-run/` (contiene `dist/` + `node_modules` de Fastify).
- **Config de pixel-agents:** `~/.pixel-agents/` (`server.json` con puerto/token, `config.json` con settings, `hooks/claude-hook.js`).
- **Watch All Sessions:** activado en `~/.pixel-agents/config.json` para enganchar agentes de cualquier directorio.

## Ver la oficina (desde tu PC)

Abrir el túnel y entrar a `http://localhost:3100`:

```powershell
ssh -L 3100:127.0.0.1:3100 aumenta
```

(o usar el acceso directo **"Ver oficina Aumenta"** del escritorio).

## Persistencia (el server arranca solo)

En el VPS, `cron` corre `~/pixel-agents-run/start.sh`:
- `@reboot` → lo levanta tras un reinicio.
- cada 5 min → lo reinicia si se cayó (el script es idempotente).

Ver/editar: `crontab -l` / `crontab -e` en el VPS.
Arrancar a mano: `bash ~/pixel-agents-run/start.sh`
Ver logs: `tail -f /tmp/pixel.log` o `tmux attach -t pixel` (salir: `Ctrl+b d`).

## Modificar el código (tu fork)

```bash
# 1. cambiás lo que quieras en este repo (origin = tu fork)
# 2. redeployás el build al VPS:
bash deploy/redeploy.sh
```

## Traer mejoras del repo original (upstream)

```bash
git fetch upstream
git merge upstream/main      # resolver conflictos si los hay
bash deploy/redeploy.sh
```

## Remotes

- `origin`   → `SantiagoVespoli/pixel-agents` (tu fork; acá pusheás)
- `upstream` → repo original de pixel-agents (de acá traés updates)
