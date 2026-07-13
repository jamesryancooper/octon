# Risk and Evidence Register

| Risk | Owner/gate | Fail-closed posture |
| --- | --- | --- |
| two issuers or candidate authority | RP-01 / PG-01 | deny launch |
| two writers or resurrected file authority | RP-03 / PG-03 | effects disabled; certified store recovery |
| credential/IPC impersonation | RP-02/RP-04 / PG-02, PG-04 | no broker effect |
| candidate-controlled privileged Git | RP-05 / PG-05 | protected PR |
| verifier/publisher overlap or stale provider projection | RP-06 / PG-06 | disable autonomous publication |
| unsigned/full-disk/incomplete evidence | RP-07 / PG-07 | no autonomous success claim |
| blind retry/false attribution/universal exactly-once | RP-08 / PG-08 | UNKNOWN/manual intervention; preserve work |
| same-change self-certification | RP-09 / PG-09 | candidate inert/prior certified version |
| project/Harness metadata widening authority | RP-10/RP-11 / PG-10, PG-11 | deny launch; no direct provider fallback |
| unsigned/revoked/incompatible extension | RP-12 / PG-12 | quarantine/disable |
| persistent/unbounded/credentialed child | RP-13 / PG-13 | child launch disabled/cancelled/retired |
| selective dogfood, stale claim, ceremony/maintenance burden | RP-14 / PG-14 | claim demoted; route failure to owner |

Current evidence is planning/static inspection only unless a child says
otherwise. All dynamic, adversarial, fault, provider, dogfood, burden, and
support evidence is future and remains `UNVERIFIED` until exact-commit execution.
