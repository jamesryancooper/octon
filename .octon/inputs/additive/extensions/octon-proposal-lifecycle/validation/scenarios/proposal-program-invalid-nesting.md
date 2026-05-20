# Proposal Program Invalid Nesting

## Target Kind

`create-program`

## Expected Behavior

The route rejects child proposal packet directories nested under a parent
proposal path and requires children at canonical
`.octon/inputs/exploratory/proposals/<kind>/<child-proposal-id>/` paths.
