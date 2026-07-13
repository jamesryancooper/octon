# Risk and Evidence Register

| Risk | Owner/gate | Fail-closed posture |
| --- | --- | --- |
| two issuers or candidate authority | RP-01 / PG-01 | deny launch |
| two writers or resurrected file authority | RP-03 / PG-03 | effects disabled; certified store recovery |
| credential/IPC impersonation | RP-02/RP-04 / PG-02, PG-04 | no broker effect |
| candidate-controlled privileged Git or candidate-held provider credential | RP-00/RP-05 / PG-00, PG-05 | disable publication; preserve candidate; do not presume PR safe |
| incomplete grant/verdict or shallow/circular checks | RP-01/RP-06 / PG-01, PG-06 | deny before effect; preserve candidate |
| missing true expected-old CAS or provider protection incompatibility | RP-05 / PG-05 | disable production no-PR; no bypass or check-then-push substitute |
| incomplete PR base/head/review tuple or false `S -> Q` proof | RP-06 / PG-06 | deny/stop PR effect; preserve source candidate |
| verifier/publisher overlap or stale provider projection | RP-06 / PG-06 | disable autonomous publication |
| unsigned/full-disk/incomplete evidence | RP-07 / PG-07 | no autonomous success claim |
| blind retry, route switching, false attribution, unsafe cleanup, or universal exactly-once | RP-08 / PG-08 | UNKNOWN/manual intervention; preserve work; never report false cleaned |
| same-change self-certification | RP-09 / PG-09 | candidate inert/prior certified version |
| project/Harness metadata widening authority | RP-10/RP-11 / PG-10, PG-11 | deny launch; no direct provider fallback |
| unsigned/revoked/incompatible extension | RP-12 / PG-12 | quarantine/disable |
| persistent/unbounded/credentialed child | RP-13 / PG-13 | child launch disabled/cancelled/retired |
| unequal-floor dogfood, false PR escalation, stale claim, ceremony/maintenance burden | RP-14 / PG-14 | claim demoted; route failure to owner |

Current evidence is planning/static inspection only unless a child says
otherwise. All dynamic, adversarial, fault, provider, dogfood, burden, and
support evidence is future and remains `UNVERIFIED` until exact-commit execution.
