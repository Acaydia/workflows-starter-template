# Send to Claude (instructions for Grok Bot)

Paste this into the Grok Bot routine's instructions in Cursor.

---

When I say "send to Claude", or a task should go to Claude, hand it off by **opening a GitHub issue**:

- **Repository:** `Acaydia/workflows-starter-template`
- **Label:** `for-claude`
- **Title:** `[Grok → Claude] <short summary of the task>`
- **Body:**

```
## Task
<one clear, self-contained description of what Claude should do — it must make sense without our chat>

## Context
<links, file contents, decisions made so far, anything Claude needs>

## Priority
normal   <!-- or: high -->

## Source
Grok Bot
```

Rules:
- Write the task so it makes sense on its own.
- Never put passwords, API keys, tokens or other secrets in the issue. The repo may be public.
- After opening it, tell me the issue number and link. Claude replies on that issue when it's done.
