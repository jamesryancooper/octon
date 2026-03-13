#!/bin/bash
# .octon bootstrap script
# Verifies capability-organized structure and reports readiness

set -e

echo "=== .octon Health Check ==="

# Check required root files
for file in octon.yml START.md scope.md conventions.md catalog.md README.md; do
  if [ -f "$file" ]; then
    echo "✓ $file"
  else
    echo "✗ $file (missing)"
  fi
done

# Check capability directories
echo ""
echo "Capability directories:"
for dir in cognition agency capabilities orchestration continuity ideation assurance scaffolding output runtime; do
  if [ -d "$dir" ]; then
    echo "✓ $dir/"
  else
    echo "✗ $dir/ (missing)"
  fi
done

# Check key subdirectories
echo ""
echo "Key subdirectories:"
for dir in cognition/context cognition/decisions agency/governance agency/runtime/agents agency/runtime/assistants agency/runtime/teams capabilities/runtime/skills capabilities/runtime/commands orchestration/runtime/workflows orchestration/runtime/missions scaffolding/runtime/templates scaffolding/governance/patterns scaffolding/practices/prompts; do
  if [ -d "$dir" ]; then
    echo "✓ $dir/"
  else
    echo "○ $dir/ (not created)"
  fi
done

echo ""
echo "=== Ready ==="
