# Orchestration Watchers

Schema-backed watcher definitions that detect conditions and emit canonical
watcher events.

## Authority Order

`manifest.yml -> registry.yml -> watcher.yml + sources.yml + rules.yml + emits.yml -> state/`

Watchers may recommend downstream automation targets. They may not launch
workflows directly.
