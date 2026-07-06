# User CLAUDE.md

## Operational Notes

Claude Code caches hook commands from `~/.claude/settings.json` at session start. Updating the file mid-session won't take effect until sessions restart. If a hook path breaks (e.g. after removing a worktree it pointed to), create a stub/symlink at the old path to bridge existing sessions until they are restarted.

## Worktrees

When asked to work in a worktree, do NOT use the EnterWorktree tool. Instead, create a git worktree as a sibling of the repo using the `{repo}__{suffix}` naming convention:

    git worktree add ../$(basename "$PWD")__{suffix} -b {branch-name}

When working in the `logbooks` repo and the task requires modifying `deep-affinity` code, proactively create a worktree off `deep-affinity` rather than editing its main checkout (which may be on a different branch or have in-progress work). Follow the `deep-affinity__{topic}` naming convention:

    git worktree add /home/drausin/git/genesistherapeutics/deep-affinity__{topic} -b drausin/{topic} origin/master

Weekly worktrees in the `logbooks` repo are named `logbooks__weekly-YYYY-MM-DD`.

## Ad-hoc Plans

Plans progress through three stages of durability. Promote up as scope solidifies; do not skip stages arbitrarily.

1. **Transient / in-session.** Session scratchpad or `EnterPlanMode`. Use while iterating on shape in a Claude conversation. Not tracked in git.
2. **Weekly logbooks branch.** Commit under `personal/drausin/plans/YYYY-MM-DD-topic.md` in the current week's `logbooks__weekly-*` worktree. Use when the plan is stable enough to review in an IDE and be part of the weekly log, but doesn't need its own PR.
3. **Standalone logbooks worktree.** Own worktree (`logbooks__{topic}`) + branch + PR. Use when the plan warrants dedicated review or timeline (e.g., cross-team, cross-week).

## Repos

Under `~/git/genesistherapeutics/`:

| Repo | Prefix | What lives here |
|---|---|---|
| `deep-affinity` | `da` | Core ML/science platform: `da/` (chem, cofolding, evals, ADME), `pipelines/`, `plat/` (Flow, cloud_queue, ray), `nucleus/` (Flask+React), `sapphire/`, `methods_api/`, `conf/` (Hydra), `deployment_targets/`, `partners/` (submodules) |
| `logbooks` | `lb` | Markdown-first: plans, reports, experiment logs, weekly TODOs. Personal scripts/tooling under `personal/<name>/` (self-contained, gitignored build artifacts). No partner data. |
| `cloud-queue` | `cq` | Cloud Queue job scheduling / dispatch system |
| `infra-terraform` | `infra-terraform` | GCP IAM, secrets, buckets, per-project cloud config |
| `kubernetes-control-repo` | (rare) | K8s cluster configs |
| `genesis-incyte`, `genesis-gilead` | (rare) | Partner-scoped configs and code. Usually accessed as submodules under `deep-affinity/partners/<partner>/`, not directly. |
| `logbooks-incyte`, `logbooks-gilead` | (rare) | Partner-siloed logbooks (analogous to `logbooks` but for content that can't leave the partner boundary) |

The prefix is what to use in PR link short-names, per the `pr-workflow` and `update-pr-status` skills.
