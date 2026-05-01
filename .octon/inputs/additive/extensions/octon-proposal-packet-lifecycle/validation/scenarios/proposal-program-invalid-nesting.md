# Proposal Program Invalid Nesting

## Target Kind

`create-proposal-program`

## Expected Behavior

The route rejects child proposal package directories nested under a parent
proposal path and requires children at canonical
`.octon/inputs/exploratory/proposals/<kind>/<child-proposal-id>/` paths.
