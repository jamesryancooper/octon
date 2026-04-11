# Closure Certification Plan

## What certification means

Certification for this proposal does not mean every machine already has every
tool installed. It means Octon has landed a correct architecture for declaring,
provisioning, resolving, and evidencing host tools in a portable way.

## Mandatory closure criteria

1. all promoted `/.octon/**` targets exist;
2. host-tool resolution stays outside repo authority roots;
3. `repo-hygiene` is bound to the subsystem;
4. validator coverage exists and passes;
5. multi-repo shared-cache behavior is tested;
6. bootstrap docs preserve repo-versus-host separation.

## Pass / fail logic

### Pass when

- all implementation acceptance gates are met;
- no repo-local surface depends on proposal paths;
- no host binaries are vendored into the repo;
- retained evidence proves at least one successful provisioning cycle.

### Fail when

- `/init` silently installs host tools;
- host actual state is stored inside `/.octon/**`;
- commands still require ad hoc temp installs as the practical architecture;
- multiple repos on one host cannot share or disambiguate tool installs.
