/**
 * portDetector — extrae puertos de servers locales a partir del texto de un
 * comando Bash o de su salida. Heurístico, pensado para mostrar en la oficina
 * "qué localhost/puerto abrió un agente". No pretende ser perfecto: prioriza
 * señales fuertes (URLs locales con puerto, frases de "serving/listening").
 *
 * Feature propia del fork (no upstream). Aislada en su módulo para minimizar
 * conflictos al traer updates de upstream.
 */

const LOCAL_HOSTS = '(?:localhost|127\\.0\\.0\\.1|0\\.0\\.0\\.0|\\[::1\\])';

// 1) URL local con puerto explícito:  http://localhost:5173  http://127.0.0.1:8000
const URL_WITH_PORT = new RegExp(`https?://${LOCAL_HOSTS}:(\\d{2,5})\\b`, 'gi');

// 2) Frases de server escuchando:  "Serving HTTP on 0.0.0.0 port 8099",
//    "Listening on port 3000", "running at ... :5173", "Local: http://localhost:5173"
const SERVING_PHRASE = /\b(?:serving|listening|listen|running|server|started|ready|local)\b[^\n]{0,40}?(?:\bport\s+|:)(\d{2,5})\b/gi;

// 3) Flags/argumentos explícitos de puerto:  --port 3000  --port=8080  -p 5173
//    php -S localhost:8000   python -m http.server 8000
const PORT_FLAG = /(?:--port[=\s]+|-p\s+|http\.server\s+|-S\s+\S*?:)(\d{2,5})\b/gi;

function isValidPort(p: string): boolean {
  const n = Number(p);
  return Number.isInteger(n) && n >= 1 && n <= 65535;
}

/**
 * Devuelve los puertos detectados como strings "localhost:PORT" (deduplicados).
 */
export function detectPorts(text: string | undefined | null): string[] {
  if (!text || typeof text !== 'string') return [];
  const ports = new Set<string>();

  for (const re of [URL_WITH_PORT, SERVING_PHRASE, PORT_FLAG]) {
    re.lastIndex = 0;
    let m: RegExpExecArray | null;
    while ((m = re.exec(text)) !== null) {
      const port = m[1];
      if (isValidPort(port)) ports.add(`localhost:${port}`);
    }
  }

  return [...ports];
}
