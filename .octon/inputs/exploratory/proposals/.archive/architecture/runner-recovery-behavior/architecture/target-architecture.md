# Target Architecture

The runner recovery loop:

1. receives a blocker or validator diagnostic;
2. classifies it as routine-autonomous, soft-blocker, or hard-blocker;
3. selects the minimal allowed recovery action;
4. applies only in-scope repairs or delegates cleanup;
5. reruns the failed validator or gate;
6. records compact recovery evidence;
7. resumes after bounded step exhaustion in end-to-end mode;
8. escalates only hard blockers or exhausted safe recovery.

Routine examples include accepted enum normalization, stale receipt refresh,
review digest refresh, publication freshness refresh, generated projection
refresh, repo-hygiene cleanup delegation, and continuable step-budget resume.
