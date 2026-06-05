# Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Template becomes too large for routine use | Operators avoid it or truncate evidence | Keep full report required for explicit postmortems only, and allow compact summaries as derived views. |
| Recommendations are mistaken for approval | Authority leak | Include non-authority statement in template and schema. |
| Invariant evolution recommendations are mistaken for amendments | Constitutional drift | Require change-control bar fields and route all invariant changes through separate governance. |
| Findings duplicate review dispositions | Confusing control semantics | Emit findings as evidence; require separate disposition records for blocking semantics. |
| Template overfits proposal lifecycle | Poor fit for other lifecycle types | Keep lifecycle kind generic and Octon-specific review conditional. |
