---
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit or optimize an existing skill, or need a new reusable behavior defined for OpenCode. Make sure to use this skill whenever someone says "make this a skill", "create a skill for X", or wants to capture a workflow as a reusable instruction set.
---

# Skill Creator

A skill for creating new skills and iteratively improving them.

## The Core Loop

1. **Understand intent** -- What should this skill do? When should it trigger?
2. **Write the skill** -- Draft `SKILL.md` with YAML frontmatter + instructions
3. **Test it** -- Use the skill on realistic prompts
4. **Evaluate** -- Review outputs qualitatively, iterate
5. **Optimize description** -- The description drives triggering accuracy

---

## Skill Anatomy

```
skill-name/
├── SKILL.md          (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── references/       (optional)
    └── *.md          -- Additional docs loaded as needed
```

### Required Frontmatter

```yaml
---
name: my-skill            # lowercase alphanumeric + hyphens, matches directory name
description: What it does and WHEN to use it. Be specific and slightly pushy.
---
```

The `description` is the **primary trigger mechanism**. It must explain both *what* the skill does AND *when* to use it. Err on the side of over-triggering rather than under-triggering.

### OpenCode-Specific Locations

Skills are discovered from:
- `~/.config/opencode/skills/<name>/SKILL.md` (global)
- `.opencode/skills/<name>/SKILL.md` (project-local)
- `.claude/skills/<name>/SKILL.md` (Claude-compatible, also recognized)

---

## Writing Good Skills

### Anatomy of Instructions

1. **What** -- What is the agent supposed to accomplish?
2. **How** -- Step-by-step process or key principles
3. **Output format** -- What should the result look like?
4. **Edge cases** -- What to do when things are ambiguous?

### Writing Patterns

**Define output format explicitly:**
```markdown
## Output format
Always use this structure:
## Summary
## Key findings
## Recommendations
```

**Explain the WHY, not just the WHAT:**
Instead of: `ALWAYS use TypeScript`
Better: `Use TypeScript because the project uses strict mode and the SDK has full TS support`

**Keep SKILL.md under ~500 lines.** If longer, extract sections to `references/` and reference them:
```markdown
For TypeScript patterns, load [references/typescript.md](references/typescript.md).
```

### Description Optimization Tips

Make descriptions "pushy" -- include triggers that might seem obvious:
- Bad: `"Guide for building dashboards"`
- Good: `"Guide for building dashboards. Use whenever user mentions dashboards, data visualization, charts, metrics display, or wants to show any kind of data visually, even if they don't say 'dashboard' explicitly."`

---

## Testing a Skill

Once written, test with 2-3 realistic prompts. Ask yourself:
- Does the skill produce the expected output format?
- Is it doing unnecessary work?
- Is the description specific enough to trigger at the right times?
- Is it too narrow / too broad?

---

## Example: Minimal Skill

```
~/.config/opencode/skills/git-release/SKILL.md
```

```markdown
---
name: git-release
description: Create consistent releases and changelogs. Use when preparing a tagged release, writing release notes, or bumping version numbers.
---

## What I do
- Draft release notes from merged PRs
- Propose a version bump following semver
- Provide a copy-pasteable `gh release create` command

## Process
1. Run `git log --oneline <last-tag>..HEAD` to list commits
2. Group by type: feat / fix / chore / docs
3. Draft release notes in Keep-a-Changelog format
4. Propose semver bump based on change types
5. Output the `gh release create` command

## Output format
### Release Notes (v<version>)
#### Added
- ...
#### Fixed
- ...

`gh release create v<version> --title "v<version>" --notes "<notes>"`
```

---

## Iterating

After testing:
1. Read the output critically -- does it match what you wanted?
2. Edit the SKILL.md
3. Re-test with the same prompts
4. Repeat until satisfied

Focus on: clarity of instructions, specificity of output format, and description accuracy.
