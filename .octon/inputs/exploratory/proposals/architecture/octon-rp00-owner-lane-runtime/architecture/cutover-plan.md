# Cutover Plan

1. Revise, independently review, implement, validate, and land this inert
   correction while RP-00 candidate `46e9900...` remains unreferenced.
2. Rebuild the RP-00 candidate on the corrected main so the staged runtime is
   trusted base code, never candidate-controlled provider code.
3. Re-run RP-00 publication, local validation, exact-tree discovery, and
   candidate freeze.
4. Materialize a fresh pre-issuance authorization and operation plan for the
   regenerated exact candidate. This packet and prior chat do not substitute.
5. The operator performs the sole token issuance attempt and supplies nonsecret
   capture metadata plus the token through the inherited FD boundary.
6. Invoke the staged owner lane. Require durable issuance/lifecycle evidence,
   live admission, admitted manifest/attestation, exact prefix/PR reconcile,
   typed suffix construction, merge post-read, and credential retirement.
7. Require landed-main and SI-00 proof before retrying the program DAG.

No step may fall back to ambient `gh`, SSH, browser automation, classic PAT,
GitHub App, `GITHUB_TOKEN`, keychain, manual merge, predicted PR identity, or
manifest rewriting.
