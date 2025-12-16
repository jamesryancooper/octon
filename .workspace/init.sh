#!/bin/bash
# .workspace bootstrap script
# Verifies structure and reports readiness

set -e

echo "=== .workspace Health Check ==="

# Check required files
for file in START.md scope.md conventions.md; do
  if [ -f "$file" ]; then
    echo "✓ $file"
  else
    echo "✗ $file (missing)"
  fi
done

# Check required directories
for dir in progress checklists prompts; do
  if [ -d "$dir" ]; then
    echo "✓ $dir/"
  else
    echo "✗ $dir/ (missing)"
  fi
done

# Check optional directories
echo ""
echo "Optional directories:"
for dir in workflows commands context templates examples; do
  if [ -d "$dir" ]; then
    echo "✓ $dir/"
  else
    echo "○ $dir/ (not created)"
  fi
done

echo ""
echo "=== Ready ==="
