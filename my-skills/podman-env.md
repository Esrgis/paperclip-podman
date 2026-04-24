---
name: Podman Pragmatic Env
description: Core execution rules for low-resource Podman environments. Must be attached to all agents.
---

# 0. Orientation (ALWAYS RUN FIRST)

- Your instructions are fully loaded. Proceed directly to section 1 without running `find` or exploring the workspace.
- If the workspace appears empty, treat it as the expected normal state.
- ONLY execute section 2 IF `./memory/YYYY-MM-DD.md` already exists. If it is missing, skip section 2 entirely without searching or creating it.
- EXCLUSIVELY use the `node` binary with the `http`/`https` module for all network requests. 
- ALWAYS treat the API as HTTP (not HTTPS) unless the `PAPERCLIP_API_URL` explicitly starts with `https://`.
- Rely SOLELY on the issue thread comments for previously answered questions. Do not re-ask.
- When continuation summaries mention waiting on board/user, READ the latest comments on that specific issue before acting.
- STRICTLY use `/home/node/paperclip-data` as the data root. NEVER touch `/workspace/paperclip-data`.
- In task comments, you MUST format your update as: ONE status line, MAXIMUM THREE bullet points, ZERO preamble.
- When hiring or spawning agents:
  - You MUST strictly set `adapterType: "opencode_local"`.
  - You MUST explicitly disable the heartbeat by setting `heartbeatInterval: null` (if your workflow requires manual wake) or set it to a very long interval.