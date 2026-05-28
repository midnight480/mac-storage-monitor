---
name: ai-dlc
description: AI-Driven Development Life Cycle (AI-DLC) adaptive workflow for software development. Use when the user says "Using AI-DLC" or asks to start a structured development workflow with requirements, design, and implementation phases.
---

# AI-DLC Workflow Skill

When this skill is activated, load and follow the complete AI-DLC workflow defined in the project's `AGENTS.md` file (or `.kiro/steering/aws-aidlc-rules/core-workflow.md`).

## Instructions

1. Read the full workflow from `AGENTS.md` or the core-workflow.md file
2. Load rule details from `.aidlc-rule-details/` (or `.kiro/aws-aidlc-rule-details/`)
3. Follow the three-phase adaptive workflow: INCEPTION → CONSTRUCTION → OPERATIONS
4. Always start with the welcome message from `common/welcome-message.md`
5. Execute workspace detection first, then proceed adaptively

## Key Principles
- Adaptive execution: Only execute stages that add value
- Human in the loop: Critical decisions require explicit user confirmation
- Quality focus: Complex changes get full treatment, simple changes stay efficient
