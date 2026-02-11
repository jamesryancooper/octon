#!/bin/bash
# .harmony bootstrap script
# Verifies capability-organized structure and reports readiness

set -e

echo "=== .harmony Health Check ==="

# Check required root files
for file in harmony.yml START.md scope.md conventions.md catalog.md README.md; do
  if [ -f "$file" ]; then
    echo "✓ $file"
  else
    echo "✗ $file (missing)"
  fi
done

# Check capability directories
echo ""
echo "Capability directories:"
for dir in cognition agency capabilities orchestration continuity ideation quality scaffolding output; do
  if [ -d "$dir" ]; then
    echo "✓ $dir/"
  else
    echo "✗ $dir/ (missing)"
  fi
done

# Check key subdirectories
echo ""
echo "Key subdirectories:"
for dir in cognition/context cognition/decisions agency/agents agency/assistants agency/teams capabilities/skills capabilities/commands orchestration/workflows orchestration/missions scaffolding/templates scaffolding/prompts; do
  if [ -d "$dir" ]; then
    echo "✓ $dir/"
  else
    echo "○ $dir/ (not created)"
  fi
done

echo ""
echo "=== Ready ==="
