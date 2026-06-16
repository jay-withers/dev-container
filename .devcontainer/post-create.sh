#!/bin/sh
# Runs inside the container as postCreateCommand, after the container is created.
set -e

GIT_NAME=$(git config --file /host-home/.gitconfig user.name 2>/dev/null || true)
GIT_EMAIL=$(git config --file /host-home/.gitconfig user.email 2>/dev/null || true)

if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
  echo ""
  echo "ERROR: Git identity is not configured on your host."
  echo "Run the following, then reopen the container:"
  echo ""
  echo '  git config --global user.name  "Your Name"'
  echo '  git config --global user.email "you@example.com"'
  echo ""
  exit 1
fi

git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Install the Terraform version pinned in .terraform-version
tfenv install

# Install Terraform shell completion (writes a complete line to ~/.bashrc)
if ! grep -q 'complete.*terraform' "$HOME/.bashrc" 2>/dev/null; then
  terraform -install-autocomplete
fi

# Required when the repo is bind-mounted and owned by a different UID than the container user
git config --global --add safe.directory /workspaces/dev-container

# Route all pre-commit invocations to the config in config/
# pre-commit requires --config after the subcommand, so a function is needed (not an alias)
if ! grep -q 'pre-commit()' "$HOME/.bashrc"; then
cat >> "$HOME/.bashrc" << 'BASHRC'
pre-commit() {
  if [ $# -gt 0 ]; then
    local _sub="$1"; shift
    command pre-commit "$_sub" --config config/.pre-commit-config.yaml "$@"
  else
    command pre-commit
  fi
}
BASHRC
fi

# Install the pre-commit hooks defined in config/.pre-commit-config.yaml
pre-commit install --config config/.pre-commit-config.yaml

# Write Claude Code user settings
mkdir -p "$HOME/.claude"
cat > "$HOME/.claude/settings.json" << 'EOF'
{
    "effortLevel": "high"
}
EOF

# Write MCP server configuration to ~/.claude.json
# Claude Code v2.x reads mcpServers from ~/.claude.json, not settings.json
MCP_SERVERS='{
    "azure": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@azure/mcp@latest", "server", "start"],
        "env": {}
    },
    "microsoft-learn": {
        "type": "http",
        "url": "https://learn.microsoft.com/api/mcp"
    }
}'

if [ -f "$HOME/.claude.json" ]; then
    jq --argjson mcp "$MCP_SERVERS" '.mcpServers = $mcp' "$HOME/.claude.json" > /tmp/claude.json.tmp \
        && mv /tmp/claude.json.tmp "$HOME/.claude.json"
else
    jq -n --argjson mcp "$MCP_SERVERS" '{mcpServers: $mcp}' > "$HOME/.claude.json"
fi
