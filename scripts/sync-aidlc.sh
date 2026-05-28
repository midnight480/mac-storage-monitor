#!/usr/bin/env bash
# sync-aidlc.sh - Synchronize AI-DLC workflow definitions across all agent formats
# Source: .kiro/steering/aws-aidlc-rules/core-workflow.md
# Target: AGENTS.md, CLAUDE.md, GEMINI.md, .antigravity/rules.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE="$ROOT_DIR/.kiro/steering/aws-aidlc-rules/core-workflow.md"
RULE_DETAILS_SRC="$ROOT_DIR/.kiro/aws-aidlc-rule-details"
RULE_DETAILS_DST="$ROOT_DIR/.aidlc-rule-details"

if [ ! -f "$SOURCE" ]; then
  echo "ERROR: Source file not found: $SOURCE"
  exit 1
fi

echo "🔄 Syncing AI-DLC workflow definitions..."

# Create symlink for rule details if not exists
if [ ! -e "$RULE_DETAILS_DST" ]; then
  echo "  Creating symlink: .aidlc-rule-details -> .kiro/aws-aidlc-rule-details"
  ln -sf ".kiro/aws-aidlc-rule-details" "$RULE_DETAILS_DST"
fi

CONTENT=$(cat "$SOURCE")

# Generate AGENTS.md (OpenAI Codex)
cat > "$ROOT_DIR/AGENTS.md" << EOF
# AI-DLC (AI-Driven Development Life Cycle) Workflow

> This file is auto-generated from \`.kiro/steering/aws-aidlc-rules/core-workflow.md\`.
> Rule details are located in \`.aidlc-rule-details/\` (symlinked from \`.kiro/aws-aidlc-rule-details/\`).
> Do not edit directly. Run \`scripts/sync-aidlc.sh\` to regenerate.

$CONTENT
EOF
echo "  ✅ AGENTS.md"

# Generate CLAUDE.md (Claude Code)
cat > "$ROOT_DIR/CLAUDE.md" << EOF
# AI-DLC (AI-Driven Development Life Cycle) Workflow

> This file is the Claude Code project memory for AI-DLC workflow.
> Rule details are located in \`.aidlc-rule-details/\`.
> Use \`/ai-dlc\` to invoke the AI-DLC workflow skill.
> Do not edit directly. Run \`scripts/sync-aidlc.sh\` to regenerate.

$CONTENT
EOF
echo "  ✅ CLAUDE.md"

# Generate GEMINI.md (Gemini CLI)
cat > "$ROOT_DIR/GEMINI.md" << EOF
# AI-DLC (AI-Driven Development Life Cycle) Workflow

> This file is the Gemini CLI project context for AI-DLC workflow.
> Rule details are located in \`.aidlc-rule-details/\`.
> Use the \`ai-dlc\` skill to invoke the workflow.
> Do not edit directly. Run \`scripts/sync-aidlc.sh\` to regenerate.

$CONTENT
EOF
echo "  ✅ GEMINI.md"

# Generate .antigravity/rules.md (Google Antigravity / Jules)
mkdir -p "$ROOT_DIR/.antigravity"
cat > "$ROOT_DIR/.antigravity/rules.md" << EOF
# AI-DLC (AI-Driven Development Life Cycle) Workflow

> This is the Google Antigravity (Jules) rules file for AI-DLC workflow.
> Rule details are located in \`.aidlc-rule-details/\`.
> Do not edit directly. Run \`scripts/sync-aidlc.sh\` to regenerate.

$CONTENT
EOF
echo "  ✅ .antigravity/rules.md"

echo ""
echo "✨ Sync complete! All agent definitions updated from source."
echo "   Source: .kiro/steering/aws-aidlc-rules/core-workflow.md"
