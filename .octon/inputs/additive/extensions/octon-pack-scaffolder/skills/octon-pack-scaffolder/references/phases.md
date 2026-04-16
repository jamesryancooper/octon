# Phases

1. Normalize the explicit scaffold request.
2. Enforce the additive write boundary under the target pack root.
3. Delegate to the matching leaf scaffold without inferring alternate routes.
4. Validate the resulting shape against `context/output-shapes.md`.
5. Return a created/skipped/blocked receipt.
