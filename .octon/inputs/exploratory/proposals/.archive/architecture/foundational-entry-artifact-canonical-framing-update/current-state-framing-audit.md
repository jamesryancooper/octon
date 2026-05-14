# Current-State Framing Audit

_Status: In-review proposal packet artifact_


## Summary

The current foundational framing is directionally compatible with the target architecture but agent-centered at the entry layer.

## Already aligned

- Root README says Octon binds runs to objectives, run contracts, scoped capabilities, authorization decisions, retained evidence, rollback posture, continuity state, and review/disclosure surfaces.
- Root README says Octon is not a prompt library, coding bot, generic agent framework, unconstrained autonomy layer, or dashboard over agent logs.
- `.octon/README.md` clearly states class roots and says `generated/**` never mints authority and `inputs/**` never becomes a direct runtime or policy dependency.
- Ingress and bootstrap artifacts already identify authored authority, state/control, state/evidence, continuity, generated, and input roles.
- Glossary bans "Model Harness" as primary term and says "Orchestrator" is valid only for a coordination component/role.

## Needs correction

- Root README opens with "Octon helps AI agents build software..." which makes the agent the first conceptual object.
- Root README uses "Governed Agent Runtime" without immediately saying the runtime is workflow-state and evidence-first.
- Root and `.octon` AGENTS adapters say "Enable reliable agent execution..." without saying agents are bounded activities inside workflow state.
- `.octon/README.md` says "agents get governed room to work" before explaining workflow/runtime state as the primary control surface.
- Glossary currently defines `Agent` as a live operational composite and `Governed Agent Runtime` as the runtime core; target framing should add `Governed Workflow Runtime` and `bounded agent node`.

## Misread risks

Current wording could be misread as:
- agent orchestration;
- agent framework;
- controlled autonomy branding rather than workflow control;
- prompt/instruction governance;
- tool access governance without connector operation admission.

## Preserve

Do not rewrite Octon's identity wholesale. Preserve:
- Constitutional Engineering Harness;
- controlled autonomy as bounded public explanation;
- Governed Agent Runtime as compatibility term during transition;
- Orchestrator as a runtime role, not whole-system category;
- class-root authority model.
