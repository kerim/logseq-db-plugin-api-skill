# Catalyst Query Protocol

**Status:** Production-verified (2026-03-01). Full round-trip confirmed end-to-end.

The Catalyst Query Protocol is how Claude Code runs arbitrary Datalog queries against a live Logseq DB graph via MCP. It uses Logseq's own DB as the IPC bus — no external infrastructure required.

---

## Protocol Overview

```
Claude Code (MCP)                    Catalyst Plugin (JS in Logseq)
─────────────────                    ──────────────────────────────
1. Create page "Catalyst Query {uuid}"
   with Datalog query as first block
                        ──────────►  2. Detect page by title pattern
                                        Execute via datascriptQuery()
                                        Write JSON result as second block
                                        addBlockTag(uuid, "Catalyst Query Done")
3. Poll getPage until blocks >= 2
4. Read blocks[1] as JSON result
5. Retitle page to archive (cleanup)
```

---

## MCP Side — Claude Code Workflow

### Step 1: Create the request page

```python
# No tag needed — plugin detects by title pattern
r, sid = tool("upsertNodes", {
    "operations": [
        {"operation": "add", "entityType": "page", "id": "qp",
         "data": {"title": f"Catalyst Query {query_uuid}"}},
        {"operation": "add", "entityType": "block", "id": None,
         "data": {"page-id": "qp", "title": datalog_string}}
    ]
}, sid)
```

**Key:** No tag assignment needed. The plugin detects by title prefix `"Catalyst Query "`. MCP's `upsertNodes` with `tags: [uuid]` does NOT write to `:block/tags` in Datascript — tag-based detection is unreliable for MCP-created pages.

### Step 2: Poll for completion

```python
for i in range(30):          # 30s timeout
    time.sleep(1)
    r, sid = tool("getPage", {"pageName": page_title}, sid)
    content = json.loads(r["result"]["content"][0]["text"])
    blocks = content.get("blocks", [])
    if len(blocks) >= 2:
        break                # Done — result is in blocks[1]
```

**Signal:** `getPage` returns 2 blocks → plugin has written the result. No tag polling needed (and `getPage` doesn't reliably expose page-level tags anyway).

**Timing:** Typically completes within 1–4 seconds. Plugin scans on `DB.onChanged` plus a 3-second interval fallback.

### Step 3: Read the result

```python
result_raw = blocks[1].get("title", "") or blocks[1].get("content", "")
result = json.loads(result_raw)
# result = {"status": "ok", "results": [[...], ...]}
# result = {"status": "error", "message": "..."}
```

### Step 4: Cleanup

MCP has no delete operation. Retitle to archive:

```python
page_uuid = content["entity"]["uuid"]
tool("upsertNodes", {
    "operations": [{"operation": "edit", "entityType": "page",
                    "id": page_uuid,
                    "data": {"title": f"_Catalyst/Query Archive/{query_uuid}"}}]
}, sid)
```

Pages can also be left as-is — they accumulate under the `Catalyst Query *` namespace.

---

## Result Schema

```json
{"status": "ok", "results": [["value1"], ["value2"], ...]}
{"status": "error", "message": "Datascript error text"}
```

Results are raw Datascript output — nested arrays. Shape depends on the `:find` clause.

---

## Plugin Side — Implementation Notes

**Detection:** `findPendingQueryPages()` queries all pages with `:block/title` and `:block/uuid`, then filters in TypeScript:
```typescript
.filter(([, title]) =>
  title.startsWith('Catalyst Query ') &&
  title !== 'Catalyst Query Done' &&
  title !== 'Catalyst Query'
)
```

**Trigger:** `DB.onChanged` (fires for some MCP writes) plus `setInterval(3000)` fallback (catches all MCP writes reliably).

**Already-processed guard:** `if (blocks.length >= 2) return` — skips pages that already have a result block.

**Tag tracking:** Plugin still calls `addBlockTag(uuid, "Catalyst Query Done")` on completion. This is visible in the Logseq UI but is NOT the polling signal for Claude Code.

---

## MCP Capabilities Discovered (2026-03-01)

| Tool | Notes |
|------|-------|
| `listPages` | Returns all pages; `expand: true` needed for tag names |
| `getPage(pageName)` | Returns entity + blocks array; does NOT include page-level tags |
| `upsertNodes` | Creates/edits pages and blocks; `tags` field does NOT write `:block/tags` |
| `searchBlocks` | Full-text search; returns raw block data including internal IDs |
| `listTags` | `expand: true` needed for title/uuid; bare call returns nulls |
| `listProperties` | Lists all properties |
| **DELETE** | **Not available.** Pages accumulate unless retitled. |

**Known limitation:** `upsertNodes` with `tags: [uuid]` does not write to `:block/tags` in Datascript — the tag appears in MCP's own representation but not in the Logseq UI or plugin Datalog queries. Use title-based conventions instead of tags for MCP-to-plugin signaling.

---

## MCP Transport

- **URL:** `http://127.0.0.1:12315/mcp`
- **Auth:** `Authorization: Bearer <token>` (token in `~/Library/Application Support/Logseq/configs.edn`)
- **Transport:** Streamable HTTP (MCP 2024-11-05) — requires `Accept: application/json, text/event-stream`
- **Session:** `POST /mcp` with `initialize` → session ID in `mcp-session-id` response header (body is empty). Include `Mcp-Session-Id` in all subsequent requests.
- **Response format:** Tool call responses arrive in the **POST response body** as chunked SSE: `event: message\ndata: {...}\n\n`. The `initialize` response body is empty — session ID in header is sufficient.

**Known session issue (observed 2026-03-07):** New sessions initialized while the Logseq graph is loading may not deliver tool call responses (empty POST body). If tool calls return empty responses, verify the target graph is fully loaded and the Logseq window is active. Sessions established while the graph is open and active work reliably. A Logseq GitHub issue has been filed.

**Python transport note:** `urllib.request` blocks on `resp.read()` for chunked SSE streams. Use raw socket reads with short timeouts instead — read until `b"data: "` appears in the buffer, then parse the line. See the working helper below.

---

## Logseq Legacy HTTP API (mutations from Claude Code)

The MCP protocol is read-oriented. For mutations that MCP can't yet handle (class creation, tag assignment, extends relationships, page deletion), use the **legacy HTTP API** at the same port:

- **URL:** `http://127.0.0.1:12315/api`
- **Auth:** Same Bearer token
- **Format:** `POST {"method": "logseq.Editor.methodName", "args": [...]}` → returns JSON directly (no SSE, no session required)

```python
import urllib.request, json

def logseq_api(method, args, token="s7hhri3r2"):
    body = json.dumps({"method": method, "args": args}).encode()
    req = urllib.request.Request("http://127.0.0.1:12315/api", data=body,
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read().decode())

# Examples
tag   = logseq_api("logseq.Editor.createTag", ["My Class"])
_     = logseq_api("logseq.Editor.addTagExtends", [child_uuid, parent_uuid])
_     = logseq_api("logseq.Editor.addBlockTag",   [page_uuid, "My Class"])
_     = logseq_api("logseq.Editor.addTagProperty", [tag_uuid, prop_uuid])
items = logseq_api("logseq.Editor.getTagObjects",  ["My Class"])
_     = logseq_api("logseq.Editor.deletePage",     ["Page Title"])
```

Available methods mirror the plugin JS API (`logseq.Editor.*`, `logseq.DB.*`). Methods that don't exist return `{"error": "MethodNotExist: ..."}` (HTTP 500). The `logseq.api.*` namespace is **not** exposed — use `logseq.Editor.*` equivalents.

---

## Complete Python Helper

```python
import json, socket, uuid as uuidlib, time

HOST, PORT, TOKEN = "127.0.0.1", 12315, "s7hhri3r2"

def _make_mcp_req(method, path, body_dict, sid=None):
    body = json.dumps(body_dict).encode()
    h = [f"{method} {path} HTTP/1.1", f"Host: {HOST}:{PORT}",
         f"Authorization: Bearer {TOKEN}",
         "Content-Type: application/json",
         "Accept: application/json, text/event-stream",
         f"Content-Length: {len(body)}", "Connection: keep-alive"]
    if sid: h.append(f"Mcp-Session-Id: {sid}")
    return ("\r\n".join(h) + "\r\n\r\n").encode() + body

def _recv_data(s, timeout=15):
    s.settimeout(0.3)
    raw = b""
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            c = s.recv(8192)
            if not c: break
            raw += c
            if b"data: " in raw: break
        except socket.timeout: pass
    return raw

def _parse_chunked_sse(resp_bytes):
    body = resp_bytes[resp_bytes.index(b"\r\n\r\n")+4:] if b"\r\n\r\n" in resp_bytes else resp_bytes
    decoded = b""
    buf = body
    while buf:
        if b"\r\n" not in buf: break
        se = buf.index(b"\r\n")
        try: csz = int(buf[:se].decode("ascii","replace").strip(), 16)
        except: break
        if csz == 0: break
        ds = se + 2
        if len(buf) < ds + csz: decoded += buf[ds:]; break
        decoded += buf[ds:ds+csz]
        buf = buf[ds+csz:]
        if buf.startswith(b"\r\n"): buf = buf[2:]
    for line in decoded.decode("utf-8","replace").split("\n"):
        if line.startswith("data: "):
            return json.loads(line[6:])
    return None

def mcp_init():
    """Initialize MCP session. Returns session ID."""
    s = socket.socket()
    s.connect((HOST, PORT))
    s.sendall(_make_mcp_req("POST", "/mcp", {"jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"cc","version":"1.0"}}}))
    buf = b""
    deadline = time.time() + 5
    while time.time() < deadline:
        try:
            s.settimeout(0.3); c = s.recv(4096); buf += c if c else b""
            if b"\r\n\r\n" in buf: break
        except socket.timeout: break
    s.close()
    for line in buf.decode("utf-8","replace").split("\r\n"):
        if line.lower().startswith("mcp-session-id:"):
            return line.split(":",1)[1].strip()

def mcp_tool(sid, name, args, req_id=2, timeout=15):
    """Call an MCP tool and return the parsed JSON-RPC result."""
    s = socket.socket()
    s.connect((HOST, PORT))
    s.sendall(_make_mcp_req("POST", "/mcp", {"jsonrpc":"2.0","id":req_id,"method":"tools/call",
        "params":{"name":name,"arguments":args}}, sid=sid))
    resp = _recv_data(s, timeout)
    s.close()
    return _parse_chunked_sse(resp)

def run_datalog(sid, datalog: str, timeout: int = 30) -> dict:
    """Run a Datalog query via the Catalyst Query Protocol. Returns result dict."""
    query_uuid = str(uuidlib.uuid4())
    page_title = f"Catalyst Query {query_uuid}"

    mcp_tool(sid, "upsertNodes", {"operations": [
        {"operation":"add","entityType":"page","id":"qp","data":{"title": page_title}},
        {"operation":"add","entityType":"block","id":None,"data":{"page-id":"qp","title": datalog}}
    ]}, req_id=2)

    for i in range(timeout):
        time.sleep(1)
        r = mcp_tool(sid, "getPage", {"pageName": page_title}, req_id=100+i)
        if r is None: continue
        content_text = r.get("result",{}).get("content",[{}])[0].get("text","{}")
        content = json.loads(content_text)
        blocks = content.get("blocks", [])
        if len(blocks) >= 2:
            result_raw = blocks[1].get("title","") or blocks[1].get("content","")
            page_uuid = content.get("entity",{}).get("uuid","")
            if page_uuid:
                mcp_tool(sid, "upsertNodes", {"operations": [{"operation":"edit","entityType":"page",
                    "id": page_uuid, "data":{"title": f"_Catalyst/Query Archive/{query_uuid}"}}]}, req_id=200)
            return json.loads(result_raw)

    raise TimeoutError(f"Query not completed in {timeout}s: {datalog}")
```
