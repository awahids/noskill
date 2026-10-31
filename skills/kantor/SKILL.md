---
name: kantor
description: "Shortcut — open Kantor noskill: a 3D three-storey office where the noskill agents sit at their desks and walk tickets to each other, live from the project's docs/noskill tickets. Use as /noskill:kantor"
disable-model-invocation: true
---

# Kantor noskill

Write everything the user reads in Bahasa Indonesia unless the user writes in another language.

The page is `kantor-noskill.html` in this skill's base directory. It is written for the claude.ai Artifact runtime: no doctype/head/body of its own (the Artifact tool adds them), three.js from cdnjs, and two runtime capabilities:
- `mcp` → `host:filesystem` (`list_directory`, `read_multiple_files`) to read ticket files on the viewer's computer, only inside the Claude desktop app;
- `db` → document `boards/latest`, a copy of the board the desktop writes so a browser or phone can show it as "Snapshot".

## 1. If the Artifact tool is available (Cowork, claude.ai)

1. List the user's artifacts. If one is titled **Kantor noskill**, ask whether to open it as is or update it to this plugin's version. To update: read it first (`action: "read"`), then publish this file to its `url`.
2. Otherwise publish the file as a new artifact:
   - `file_path`: the html file above
   - `icon`: `building`
   - `description`: `Diorama 3D kantor tiga lantai tim agent noskill dengan board tiket live dari folder docs/noskill.`
   - `capabilities`:
     ```json
     {"mcp": {"servers": [{"server": "host:filesystem", "tools": ["list_directory", "read_multiple_files"]}]},
      "db": {"rules": [{"path": "boards", "read": "view", "write": "admin"}]}}
     ```
   Do not change the page source while publishing.
3. Tell the user, briefly, how to turn on live data:
   - Add a filesystem MCP server named exactly `filesystem` to the Claude desktop config (Settings → Developer → Edit Config), with the parent folders of their projects as the last args. With Node from nvm, use the full path of `npx` and set `env.PATH` to that Node's `bin` folder; then quit Claude with Cmd+Q and reopen.
     ```json
     "filesystem": {
       "command": "/full/path/to/npx",
       "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/<user>/code"],
       "env": { "PATH": "/full/path/to/node/bin:/usr/local/bin:/usr/bin:/bin" }
     }
     ```
   - Open the artifact in the Claude desktop app → **Folder tiket** → paste one `docs/noskill` (or `.../tickets`) path per line → **Pakai data live** → allow access.
   - In a browser or on a phone the page shows the last copy the desktop saved (label **Snapshot**), or the demo if none exists yet.
   - Local servers only work on artifacts the user owns.

## 2. If there is no Artifact tool (plain Claude Code terminal)

Copy the page into the project so it opens in a browser, wrapping it in a document shell:

```bash
docs="${user_config.docs_dir}"; [ "${docs#\$}" = "$docs" ] || docs=docs/noskill   # fallback if not substituted
mkdir -p "$docs"
{ printf '%s\n' '<!doctype html><html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><style>[hidden]{display:none!important}</style></head><body>'
  cat "<this skill's base directory>/kantor-noskill.html"
  printf '%s\n' '</body></html>'; } > "$docs/kantor-noskill.html"
```

Then tell the user the path and that opened this way the page runs in **demo mode only**: live tickets and Snapshot need the claude.ai artifact runtime (Cowork or claude.ai). Offer `open <path>` (macOS) or `xdg-open <path>` (Linux). Do not add `kantor-noskill.html` to git unless the user asks.
