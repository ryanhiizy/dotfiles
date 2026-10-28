#!/bin/sh
# Executor's GitHub MCP server, signed in with gh's token.
set -eu
GITHUB_PERSONAL_ACCESS_TOKEN="$("$HOME/.local/share/mise/shims/gh" auth token)"
export GITHUB_PERSONAL_ACCESS_TOKEN
exec "$HOME/.local/share/executor/github-mcp/2.0.2/github-mcp-server" stdio
