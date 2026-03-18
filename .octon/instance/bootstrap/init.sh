#!/bin/bash
set -e

echo "=== .octon Super-Root Health Check ==="

for file in ../octon.yml ../README.md ../AGENTS.md OBJECTIVE.md START.md scope.md conventions.md catalog.md; do
  if [ -f "$file" ]; then
    echo "✓ $file"
  else
    echo "✗ $file (missing)"
  fi
done

echo ""
echo "Class roots:"
for dir in ../framework ../instance ../inputs ../state ../generated; do
  if [ -d "$dir" ]; then
    echo "✓ $dir/"
  else
    echo "✗ $dir/ (missing)"
  fi
done

echo ""
echo "Key authored surfaces:"
for dir in ../framework/agency ../framework/capabilities ../framework/cognition ../framework/orchestration ../framework/assurance ../framework/engine ../framework/scaffolding ../instance/ingress ../instance/bootstrap ../instance/cognition ../state/continuity/repo ../generated/proposals; do
  if [ -e "$dir" ]; then
    echo "✓ $dir"
  else
    echo "✗ $dir (missing)"
  fi
done

echo ""
echo "=== Ready ==="
