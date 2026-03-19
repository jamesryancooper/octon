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
for dir in ../framework/agency ../framework/capabilities ../framework/cognition ../framework/orchestration ../framework/assurance ../framework/engine ../framework/scaffolding ../instance/ingress ../instance/bootstrap ../instance/locality ../instance/locality/scopes ../instance/cognition ../instance/cognition/context/scopes ../instance/capabilities/runtime ../instance/orchestration/missions ../inputs/additive/extensions ../state/continuity/repo ../state/control/locality ../generated/effective/locality ../generated/proposals; do
  if [ -e "$dir" ]; then
    echo "✓ $dir"
  else
    echo "✗ $dir (missing)"
  fi
done

echo ""
echo "Packet 2 control-plane surfaces:"
for file in ../framework/manifest.yml ../instance/manifest.yml ../instance/extensions.yml; do
  if [ -f "$file" ]; then
    echo "✓ $file"
  else
    echo "✗ $file (missing)"
  fi
done

echo ""
echo "Packet 4 repo-instance surfaces:"
for dir in ../instance/governance/policies ../instance/governance/contracts ../instance/agency/runtime ../instance/assurance/runtime ../instance/capabilities/runtime/commands; do
  if [ -e "$dir" ]; then
    echo "✓ $dir"
  else
    echo "✗ $dir (missing)"
  fi
done

echo ""
echo "=== Ready ==="
