---
name: send-to-grok-bot
description: Hand a task off to the user's Grok Bot, which carries it out and reports back in its own chat. Use when the user says "send to Grok Bot", "hand this to Grok Bot", "have Grok Bot do this", or runs /send-to-grok-bot.
argument-hint: "[what Grok Bot should do]"
allowed-tools: Bash(bash *send.sh*)
---

# Send to Grok Bot

Hand a task to Grok Bot by POSTing it to its Cursor automation webhook. Grok Bot runs the task and reports back to the user in its own chat — not here.

## 1. Write the payload

Build this JSON body:

```json
{
  "source": "Claude Code",
  "task": "<one clear, self-contained description of what Grok Bot should do>",
  "context": "<anything Grok Bot needs: links, file contents, decisions made so far>",
  "priority": "normal"
}
```

- **task** must make sense to someone who never saw this conversation. Name the deliverable, the audience, and what "done" looks like. No "this", "the above", or "like we discussed".
- **context** carries everything Grok Bot needs: URLs, relevant file contents or excerpts, brand/tone decisions, constraints, and what has already been tried.
- **priority** is `"normal"` unless the user explicitly asks for something else (e.g. `"high"`).
- If `$ARGUMENTS` is given, it is the task; otherwise derive the task from the current conversation. Ask only if what to send is genuinely unclear.
- **Never include passwords, API keys, tokens, or other secrets** in `task` or `context` — redact them (`[REDACTED]`) if they appear in pasted material.

## 2. Send it

Pipe the JSON to the bundled script (it builds nothing itself; it just POSTs stdin and prints the status):

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/send.sh" <<'JSON'
{ "source": "Claude Code", "task": "...", "context": "...", "priority": "normal" }
JSON
```

If `${CLAUDE_SKILL_DIR}` is empty, use the directory this SKILL.md lives in. Make sure the heredoc body is valid JSON (escape quotes and newlines inside strings); the script validates it with `jq` before sending.

The script authenticates with `Authorization: Bearer $GROK_BOT_SENDER_KEY`. In Claude Code cloud sessions the key is saved as a network secret for `api2.cursor.sh` and injected by the proxy, so the variable can stay unset. On a local machine, the user sets `GROK_BOT_SENDER_KEY` in their shell profile. Never ask the user to paste the key into chat.

## 3. Report back

Tell the user, briefly:

- **Succeeded** or **Failed**, with the **HTTP status code** (2xx = succeeded).
- A one-line summary of the task that was sent.
- On failure, the response body the script printed and the likely cause (401/403 = bad or missing sender key — `missing required scope: automation:…` means the key is valid but not authorized for this automation, so the user needs a key with that scope from the Grok Bot routine panel; 404 = wrong webhook URL; 5xx/000 = Grok Bot side or network — safe to retry once).
- On success, remind them Grok Bot will report back in its own chat.
