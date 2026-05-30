# Target Architecture

Validator coverage should protect the new mechanism index and related product
surfaces from authority drift.

Required guards:

- product feature catalog remains navigation-only;
- mechanism index is not runtime authority;
- `state/control/**` is mutable operational truth and state/control not
  retained evidence;
- generated-effective outputs remain non-authority;
- operator read models remain navigation and visibility only;
- raw/input surfaces do not become runtime or policy dependencies;
- lifecycle interaction receipts not authorization;
- parent proposal-program evidence does not satisfy child packet receipts;
- proposal lifecycle, Change closeout, worktree closeout, and repo hygiene do
  not collapse into one authority system;
- retired terminology remains contained to compatibility or historical notes.
