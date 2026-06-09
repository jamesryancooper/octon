# Target Architecture

The product feature catalog schema and the governed cross-surface mechanisms
index should use a shared authority-class vocabulary aligned to
`.octon/framework/cognition/_meta/architecture/contract-registry.yml`.

The target vocabulary must distinguish:

- authored authority;
- product contract;
- runtime spec;
- runtime implementation;
- mutable operational truth;
- retained evidence;
- generated-effective non-authority;
- generated operator read model;
- publication input only;
- exploratory/raw input;
- navigation only;
- compatibility only.

`state/control/**` must be labeled mutable operational truth. It must not be
labeled retained evidence. `state/evidence/**` remains the retained evidence
root. A generated operator read model must stay separate from
generated-effective runtime handles.
