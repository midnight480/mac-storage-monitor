---
name: ai-dlc
description: AI-Driven Development Life Cycle (AI-DLC) adaptive workflow for software development. Invoke when the user says "Using AI-DLC" or wants structured development with requirements analysis, design, and code generation phases.
---

# AI-DLC Workflow

When activated, follow the complete AI-DLC methodology:

1. Read the full workflow from `CLAUDE.md` or `.kiro/steering/aws-aidlc-rules/core-workflow.md`
2. Load rule details from `.aidlc-rule-details/` (or `.kiro/aws-aidlc-rule-details/`)
3. Execute the three-phase adaptive workflow:
   - 🔵 INCEPTION: Requirements, User Stories, Design
   - 🟢 CONSTRUCTION: Functional Design, NFR, Code Generation
   - 🟡 OPERATIONS: Deployment (future)
4. Start with welcome message from rule details `common/welcome-message.md`
5. Begin with Workspace Detection, then adapt based on project state

## Principles
- Adaptive: Only execute stages that add value
- Human-in-the-loop: Approval required at each phase
- Quality-focused: Depth scales with complexity
