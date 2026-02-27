---
name: agent
description: |
  Agent author - use PROACTIVELY when:
  - Creating a new Claude agent definition
  - Updating or improving an existing agent's prompt
  - Refining an agent description for better auto-activation
  Triggers: create agent, new agent, update agent, agent prompt, agent description
argument-hint: [agent-name]
allowed-tools: Read, Write, Edit, Glob
---

# Agent Skill

Create or update a Claude agent definition in `home-manager/modules/claude/agents/`.

## Agent file location

All agent files live at:
```
home-manager/modules/claude/agents/<agent-name>.md
```

## Template

Use this template for every agent file:

```markdown
---
name: your-agent-name
description: Use this agent when [specific trigger description]
model: sonnet
tools: Read, Write, Edit, Bash, Grep, Glob
skills: []
---

# Your Agent Name

## Role Definition

You are an expert in [domain]. Your responsibilities include:
- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]

## Activation Triggers

Use this agent when:
- [Trigger 1]
- [Trigger 2]
- [Trigger 3]

## Methodology

When given a task, you should:
1. [Step 1]
2. [Step 2]
3. [Step 3]
4. [Step 4]

## Output Format

Your deliverables should include:
- [Output 1]
- [Output 2]

## Constraints

- [Constraint 1]
- [Constraint 2]

## Examples

### Example 1: [Scenario Name]

**User**: [Example prompt]

**Your approach**:
1. [What you do first]
2. [What you do next]
3. [Final output]
```

## Description field — Tool SEO rules

The `description` is the most important field. It determines when Claude auto-activates the agent. Write it like SEO copy:

```yaml
# Bad — too vague
description: Reviews code

# Good — explicit triggers and context
description: |
  Security code reviewer - use PROACTIVELY when:
  - Reviewing authentication/authorization code
  - Analyzing API endpoints
  - Checking input validation
  - Auditing data handling
  Triggers: security, auth, vulnerability, OWASP, injection
```

Rules:
- Say `use PROACTIVELY` to encourage automatic activation
- List explicit trigger phrases as keywords
- List 3–5 concrete contexts where the agent should activate
- Keep each bullet to one line

## Tools and model

Only include tools the agent actually needs:
- Read-only research agents: `Read, Grep, Glob`
- Agents that run commands: add `Bash`
- Agents that write/edit files: add `Write, Edit`
- Default model: `sonnet`. Use `opus` only for complex reasoning tasks.

## Steps

If `$ARGUMENTS` is provided, it is the agent name to create or update.

1. Check if `home-manager/modules/claude/agents/$ARGUMENTS.md` already exists
2. If updating: read the existing file first, then apply targeted edits
3. If creating: write the full file using the template above
4. Fill in all sections — do not leave placeholder brackets in the output
5. Apply Tool SEO to the description
6. Confirm the file path to the user
