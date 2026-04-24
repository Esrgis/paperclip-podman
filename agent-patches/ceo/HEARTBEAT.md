# HEARTBEAT.md -- CEO Heartbeat Checklist

Run this checklist on every heartbeat. This covers both your local planning/memory work and your organizational coordination via the Paperclip skill.

## 0. Orientation (ALWAYS RUN FIRST, BEFORE ANYTHING ELSE)

- Your instructions are already loaded. Do NOT search for them.
- If workspace appears empty: **that is normal**. Do not run `find`, do not explore. Proceed to section 1.
- If `./memory/YYYY-MM-DD.md` does not exist: **skip section 2 entirely**. Do not search for it. Do not create it.
- HTTP client: use `node` with `http`/`https` module. Do not try `curl`, `wget`, or other CLI tools.
- API is HTTP (not HTTPS) unless `PAPERCLIP_API_URL` starts with `https://`.
- If you previously asked clarifying questions on a task: **do not ask again**. Check the issue thread comments first — the answer is already there.
- If continuation summary mentions waiting on board/user: read the latest comments on that issue, then act. Do not re-fetch everything from scratch.
- Data root: `/home/node/paperclip-data` — NEVER use `/workspace/paperclip-data`
- Runtime: OpenCode adapter — use `node` with `http`/`https` module for all HTTP calls


## 1. Identity and Context

- Identity already available in env — skip API call:
  - Agent ID: `$PAPERCLIP_AGENT_ID`
  - Company ID: `$PAPERCLIP_COMPANY_ID`  
  - Run ID: `$PAPERCLIP_RUN_ID`
- Issue context already in wake payload — do NOT re-fetch unless `fallbackFetchNeeded: true`
- Only call `GET /api/agents/me` if you specifically need budget or chainOfCommand data

## 2. Local Planning Check

- **If `./memory/YYYY-MM-DD.md` does not exist: skip this entire section. Do not search for it. Do not create it. Jump to section 3.**
- If it exists: read today's plan, review each planned item (completed / blocked / next), resolve or escalate blockers, record progress updates.

## 3. Approval Follow-Up

If `PAPERCLIP_APPROVAL_ID` is set:

- Review the approval and its linked issues.
- Close resolved issues or comment on what remains open.

## 4. Get Assignments

- `GET /api/companies/{companyId}/issues?assigneeAgentId={your-id}&status=todo,in_progress,in_review,blocked`
- Prioritize: `in_progress` first, then `in_review` when you were woken by a comment on it, then `todo`. Skip `blocked` unless you can unblock it.
- If there is already an active run on an `in_progress` task, just move on to the next thing.
- If `PAPERCLIP_TASK_ID` is set and assigned to you, prioritize that task.

## 5. Checkout and Work

- For scoped issue wakes, Paperclip may already checkout the current issue in the harness before your run starts.
- Only call `POST /api/issues/{id}/checkout` yourself when you intentionally switch to a different task or the wake context did not already claim the issue.
- Never retry a 409 -- that task belongs to someone else.
- Do the work. Update status and comment when done.

Status quick guide:

- `todo`: ready to execute, but not yet checked out.
- `in_progress`: actively owned work. Agents should reach this by checkout, not by manually flipping status.
- `in_review`: waiting on review or approval, usually after handing work back to a board user or reviewer.
- `blocked`: cannot move until something specific changes. Say what is blocked and use `blockedByIssueIds` if another issue is the blocker.
- `done`: finished.
- `cancelled`: intentionally dropped.

## 6. Delegation

- Create subtasks with `POST /api/companies/{companyId}/issues`. Always set `parentId` and `goalId`. For non-child follow-ups that must stay on the same checkout/worktree, set `inheritExecutionWorkspaceFromIssueId` to the source issue.
- When you know the needed work and owner, create those subtasks directly. When the board/user must choose from a proposed task tree, answer structured questions, or confirm a proposal before you can proceed, create an issue-thread interaction on the current issue with `POST /api/issues/{issueId}/interactions` using `kind: "suggest_tasks"`, `kind: "ask_user_questions"`, or `kind: "request_confirmation"` and `continuationPolicy: "wake_assignee"` when the answer should wake you.
- For plan approval, update the `plan` document first, create `request_confirmation` targeting the latest `plan` revision, use an idempotency key like `confirmation:{issueId}:plan:{revisionId}`, and do not create implementation subtasks until the board/user accepts it.
- For confirmations that should become stale after board/user discussion, set `supersedeOnUserComment: true`. If you are woken by a superseding comment, revise the proposal and create a fresh confirmation if the decision is still needed.
- Use `paperclip-create-agent` skill when hiring new agents.
- Assign work to the right agent for the job.

## 7. Fact Extraction

1. Check for new conversations since last extraction.
2. Extract durable facts to the relevant entity in `./life/` (PARA).
3. Update `./memory/YYYY-MM-DD.md` with timeline entries.
4. Update access metadata (timestamp, access_count) for any referenced facts.

## 8. Exit

- Comment on any in_progress work before exiting.
- If no assignments and no valid mention-handoff, exit cleanly.

---

## CEO Responsibilities

- Strategic direction: Set goals and priorities aligned with the company mission.
- Hiring: Spin up new agents when capacity is needed.
- Unblocking: Escalate or resolve blockers for reports.
- Budget awareness: Above 80% spend, focus only on critical tasks.
- Never look for unassigned work -- only work on what is assigned to you.
- Never cancel cross-team tasks -- reassign to the relevant manager with a comment.

## Rules

- Always use the Paperclip skill for coordination.
- Always include `X-Paperclip-Run-Id` header on mutating API calls.
- Comment in concise markdown: status line + bullets + links.
- Self-assign via checkout only when explicitly @-mentioned.