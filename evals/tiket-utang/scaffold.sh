set -e
. "$(dirname "$0")/../base.sh"
cat > lib/cache.js <<'J'
// shortcut: cache di memori proses, tidak dibagi antar instance; pindah ke Redis bila jalan lebih dari satu instance
const store = new Map();
export const get = (k) => store.get(k);
J
cat > lib/retry.js <<'J'
// shortcut: retry tetap 3 kali tanpa backoff
export const RETRIES = 3;
J
cat > lib/notes.js <<'J'
// Catatan: shortcut keyboard Ctrl+S menyimpan draf
export const note = 1;
J
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
