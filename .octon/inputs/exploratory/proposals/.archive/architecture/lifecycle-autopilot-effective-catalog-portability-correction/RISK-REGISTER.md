# Risk Register

_Status: Draft proposal risk register_

| Risk | Severity | Mitigation |
| --- | ---: | --- |
| Fix accepts unsafe lifecycle contracts | High | Add negative tests where non-empty lifecycle contracts without the `lifecycle-contract` capability profile still fail closed. |
| Fix only patches the observed parent program | High | Require reusable lifecycle discovery tests with a minimal effective catalog fixture. |
| Proposal standard validator remains shell-version fragile | Medium | Make shell requirements explicit or invoke the generator through the current Bash interpreter with a version guard. |
| Registry sync passes but runtime route remains blocked | High | Require a `proposal-program` lifecycle plan smoke test against the parent program path. |
| Fallback creation remains invisible to durable evidence | Medium | Define retained evidence expectations for fallback/manual lifecycle creation. |
| Documentation claims full Autopilot behavior before route proof exists | Medium | Update product/support wording only to match tested runtime behavior. |
| Generated effective catalog is edited directly | High | Require regeneration/publication evidence; generated files remain derived-only. |
| Tooling correction is confused with GWR implementation | High | Keep explicit non-goals and runtime non-implementation statements in this packet and validation evidence. |
