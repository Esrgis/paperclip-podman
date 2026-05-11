# OpenClaw Adapter Guide for Paperclip

## Table of Contents
- [Overview](#overview)
- [Key Differences: OpenClaw vs CLI Tools](#key-differences-openclaw-vs-cli-tools)
- [Prerequisites](#prerequisites)
- [What You Need from OpenClaw](#what-you-need-from-openclaw)
- [Installation Options](#installation-options)
- [Configuration](#configuration)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Complete Checklist](#complete-checklist)

## Overview

OpenClaw is a **client-server** agent platform that integrates with Paperclip through the `openclaw_gateway` adapter. Unlike single-binary CLI tools (Claude Code, OpenCode), OpenClaw requires a continuously running gateway server that communicates via WebSocket protocol.

**If OpenClaw is an *employee*, Paperclip is the *company*.**

Paperclip orchestrates multiple agents (OpenClaw, Claude Code, Codex, Cursor) toward common goals.

## Key Differences: OpenClaw vs CLI Tools

| Feature | Claude Code / OpenCode | OpenClaw |
|---------|---------------------|----------|
| Architecture | Single binary CLI | Client-Server (Gateway + Agents) |
| Installation | `npm install -g claude` or `curl \| bash` | Docker container required |
| Network | Direct API calls | WebSocket gateway protocol |
| Session State | Ephemeral | Persistent (workspace, memory, tools) |
| Authentication | API keys only | Tokens + Device pairing |
| Resource Usage | Minimal (~50MB RAM) | Moderate (~2GB RAM for Docker) |
| Deployment | Local machine | Docker/Kubernetes server |

## Prerequisites

### System Requirements
- **Docker Desktop v29+** (with Docker Sandbox support)
- **2GB+ RAM** available
- **API keys** in `~/.secrets` (minimum `OPENAI_API_KEY`)
- **Network access** to OpenAI API (or your model provider)

### Paperclip Requirements
- Paperclip running in `lan` or `localhost` mode
- Board user permissions (for agent invite generation)

## What You Need from OpenClaw

To use OpenClaw as an adapter, you need **only 3 things**:

### 1. Gateway URL
Format: `ws://<host>:<port>` or `wss://<domain>:<port>`

Examples:
- Local: `ws://127.0.0.1:18789`
- Remote: `ws://openclaw.yourfriend.com:18789`
- Secure: `wss://openclaw.yourdomain.com:443`

### 2. Authentication Credential
**Option A - Token (recommended)**: A 32-64 character random string
```json
{
  "authToken": "your-gateway-token-here"
}
```

**Option B - Password**: Shared password for simple auth
```json
{
  "password": "your-shared-password"
}
```

**Option C - Header**: Direct header injection
```json
{
  "headers": {
    "x-openclaw-token": "your-token"
  }
}
```

### 3. Device Pairing Approval
- First-time setup requires approving the Paperclip device in OpenClaw
- Run: `openclaw devices approve --latest` (on OpenClaw server)
- Alternative: Disable device auth (`"disableDeviceAuth": true`)

**You DO NOT need:**
- ❌ OpenClaw source code
- ❌ Built binaries
- ❌ Database dumps
- ❌ Configuration files
- Just the **3 items above**!

## Installation Options

### Option 1: Automated Smoke Test (Recommended for Testing)

This runs a complete end-to-end test with Docker:

```bash
# Clone Paperclip repo if needed
git clone https://github.com/paperclipai/paperclip ..
cd paperclip

# Install dependencies
pnpm install

# Run automated smoke test
pnpm smoke:openclaw-join
```

This will:
- Start Paperclip with OpenClaw adapter
- Create an agent invite
- Spin up OpenClaw in Docker
- Complete device pairing
- Run a test task

### Option 2: Manual Docker Setup

```bash
# 1. Start Paperclip
pnpm dev --bind lan

# 2. In another terminal, start OpenClaw Docker
OPENCLAW_RESET_STATE=1 pnpm smoke:openclaw-docker-ui

# 3. Copy the printed Dashboard URL
# Should look like: http://127.0.0.1:18789/#token=...
```

### Option 3: Connect to Existing OpenClaw

If your friend already runs OpenClaw:

```bash
# 1. Get connection details from your friend:
# - Gateway URL (ws://...)
# - Auth token/password
# - Device approval confirmation

# 2. Skip to Configuration section
```

## Configuration

### Step 1: Create OpenClaw Agent in Paperclip

1. Go to `http://127.0.0.1:3100/CLA/company/settings`
2. Navigate to **Invites** section
3. Click **Generate OpenClaw Invite Prompt**
4. Copy the generated prompt

### Step 2: Configure OpenClaw Agent

In OpenClaw dashboard (URL from installation):

```json
Paste the invite prompt here as one message
```

If it stalls, send follow-up:
```
How is onboarding going? Continue setup now.
```

### Step 3: Approve Join Request

Back in Paperclip UI:

1. Go to pending invites/agents
2. Approve the OpenClaw agent
3. Verify agent appears in CLA agents list

### Step 4: Verify Adapter Configuration

Check that the created agent has correct settings:

```bash
AGENT_ID="<your-agent-id>"
curl -sS "http://127.0.0.1:3100/api/agents/$AGENT_ID" | \
  jq '{adapterType, adapterConfig}'
```

Expected output:
```json
{
  "adapterType": "openclaw_gateway",
  "adapterConfig": {
    "url": "ws://127.0.0.1:18789",
    "authToken": "<non-empty-token>",
    "disableDeviceAuth": false,
    "devicePrivateKeyPem": "<exists>"
  }
}
```

### Config File Example

Create agent config in Paperclip:

```json
{
  "name": "openclaw-agent",
  "adapterType": "openclaw_gateway",
  "url": "ws://127.0.0.1:18789",
  "authToken": "your-gateway-token",
  "sessionKeyStrategy": "issue",
  "timeoutSec": 300,
  "waitTimeoutMs": 150000,
  "autoPairOnFirstConnect": true,
  "disableDeviceAuth": false
}
```

### Environment Variables

```bash
# OpenClaw settings
OPENAI_API_KEY="sk-..."              # Required
OPENCLAW_GATEWAY_PORT=18789            # Default
OPENCLAW_GATEWAY_TOKEN="..."          # Generate random
OPENCLAW_MODEL_PRIMARY="openai/gpt-5.2"
OPENCLAW_CONFIG_DIR="~/.openclaw"

# Paperclip settings (if authenticated mode)
PAPERCLIP_AUTH_HEADER="Bearer <token>"
# or
PAPERCLIP_COOKIE="your_session_cookie=..."
```

## Testing

### Test A: Basic Task Execution

1. Create an issue in Paperclip
2. Assign to OpenClaw agent
3. Instructions: `post comment "OPENCLAW_TEST_$(date +%s)" and mark done`
4. Verify: Issue status becomes `done` with comment

### Test B: Message Tool

1. Create another issue
2. Instructions: `send "OPENCLAW_MSG_$(date +%s)" to webchat, then comment same marker, then mark done`
3. Verify:
   - Comment appears on issue
   - Message appears in OpenClaw chat

### Test C: Cross-Session Task Creation

1. In OpenClaw CLI: Start `/new` session
2. Ask: `Create a Paperclip issue with title "OPENCLAW_CROSS_$(date +%s)"`
3. Verify: New issue appears in Paperclip

### Running Smoke Tests

```bash
# All OpenClaw smoke tests
pnpm smoke:openclaw-join       # End-to-end join test
pnpm smoke:openclaw-docker-ui # Docker UI only
pnpm smoke:openclaw-sse-standalone # Server-sent events
```

## Troubleshooting

### Connection Issues

**Problem**: "Connection refused"
```bash
# Check if OpenClaw gateway is running
curl http://localhost:18789/health

# Check Docker container
docker ps | grep openclaw

# Check bind address (must be 0.0.0.0 or lan)
docker exec openclaw-gateway sh -c \
  "grep -R bind /home/node/.openclaw/openclaw.json"
```

**Problem**: "Unauthorized"
```bash
# Verify token matches
echo $OPENCLAW_GATEWAY_TOKEN
docker exec openclaw-gateway sh -c \
  "node -p \"require('/home/node/.openclaw/openclaw.json').gateway.auth.token\""
```

**Problem**: "Pairing required"
```bash
# Approve device manually
docker exec openclaw-gateway sh -lc \
  "openclaw devices approve --latest --json \
   --url 'ws://127.0.0.1:18789' \
   --token '\$(node -p \"require('/home/node/.openclaw/openclaw.json').gateway.auth.token\")'"

# Or disable device auth
# In OpenClaw config: "disableDeviceAuth": true
```

### Timeout Issues

**Problem**: "Connection timeout"
```bash
# Increase timeout in Paperclip agent config
timeoutSec: 600          # 10 minutes
waitTimeoutMs: 300000   # 5 minutes
```

### Docker Issues

**Problem**: "No space left on device"
```bash
# Clean Docker
docker system df
docker system prune -f
docker image prune -f
```

**Problem**: "Unable to create temp dir"
```bash
# Add tmpfs to docker-compose.yml
services:
  openclaw-gateway:
    tmpfs:
      - /tmp:exec,size=512M
  openclaw-cli:
    tmpfs:
      - /tmp:exec,size=512M
```

### Log Monitoring

```bash
# Stream OpenClaw logs
docker compose logs -f openclaw-gateway

# Paperclip adapter logs
# Check Paperclip logs for "[openclaw-gateway]" prefix
```

### Network Issues

**Problem**: "Hostname not allowed"
```bash
# Add allowed hostname
pnpm paperclipai allowed-hostname host.docker.internal
pnpm paperclipai allowed-hostname <your-hostname>
```

**Problem**: OpenClaw in Docker can't reach Paperclip
```bash
# Use host.docker.internal for local Paperclip
export PAPERCLIP_HOST_FROM_CONTAINER="host.docker.internal"
```

## Connection Modes

### Local Development (Same Machine)

```bash
# Paperclip on host, OpenClaw in Docker
Paperclip URL: http://host.docker.internal:3100
Gateway URL: ws://127.0.0.1:18789
```

### Remote OpenClaw (Friend's Server)

```bash
# Get from your friend:
Gateway URL: ws://192.168.1.100:18789
Auth Token:  their-token-here
Approve device: ask them to run approval command
```

### Production (Public Access)

```bash
# Use wss:// with valid SSL
Gateway URL: wss://openclaw.yourdomain.com
TLS: Use proper certificates
Auth: Strong token required
```

## Complete Checklist

### Before You Start

- [ ] Docker Desktop v29+ installed
- [ ] 2GB RAM available
- [ ] API keys in `~/.secrets`
- [ ] Paperclip repository cloned
- [ ] Dependencies installed (`pnpm install`)

### OpenClaw Prerequisites (from your friend)

- [ ] Gateway URL (ws:// or wss://)
- [ ] Auth token/password (16+ characters)
- [ ] Device approval confirmation
- [ ] Network access (ports open)
- [ ] SSL certificate (if using wss://)

### Configuration Steps

- [ ] Paperclip running (`pnpm dev --bind lan`)
- [ ] Generate OpenClaw invite in Paperclip UI
- [ ] Configure OpenClaw agent
- [ ] Approve join request in Paperclip
- [ ] Verify adapter type is `openclaw_gateway`
- [ ] Verify token length >= 16 chars
- [ ] Verify `devicePrivateKeyPem` exists
- [ ] Verify `disableDeviceAuth` is false

### Testing

- [ ] Test A: Basic task completes
- [ ] Test B: Message tool works
- [ ] Test C: Cross-session issue creation works
- [ ] All tasks show "done" status
- [ ] Agent logs show proper `[openclaw-gateway]` prefix
- [ ] No timeout errors

### Troubleshooting

- [ ] Gateway health check passes (`/health`)
- [ ] WebSocket connects without errors
- [ ] Device approval completed
- [ ] Firewall allows WebSocket traffic
- [ ] Hostname added to allowed list (if needed)
- [ ] Token/password verified
- [ ] Logs show no auth errors

## Quick Reference

### Essential Commands

```bash
# Start OpenClaw smoke test
pnpm smoke:openclaw-join

# Start OpenClaw with UI
pnpm smoke:openclaw-docker-ui

# Check agent config
curl -sS "http://127.0.0.1:3100/api/agents/<id>" | jq .

# Device approval
docker exec openclaw-gateway openclaw devices approve --latest

# View logs
docker compose logs -f openclaw-gateway
```

### Essential URLs

- Paperclip UI: `http://127.0.0.1:3100`
- OpenClaw Dashboard: `http://127.0.0.1:18789/#token=...`
- OpenClaw Health: `http://127.0.0.1:18789/health`

### Essential Config

```json
{
  "adapterType": "openclaw_gateway",
  "url": "ws://<host>:<port>",
  "authToken": "<token>",
  "autoPairOnFirstConnect": true,
  "disableDeviceAuth": false
}
```

## Resources

- [OpenClaw Documentation](https://docs.openclaw.ai/)
- [Paperclip README](README.md)
- [Docker Setup Guide](docs/guides/openclaw-docker-setup.md)
- [Onboarding Checklist](doc/OPENCLAW_ONBOARDING.md)

## Support

For issues with:
- **OpenClaw**: Contact your friend running the server
- **Paperclip Adapter**: Open issue in Paperclip repository
- **Docker**: Check Docker Desktop logs
- **Network**: Verify firewall and hostname settings
