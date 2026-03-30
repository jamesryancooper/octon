# Commands

- `sed -n '1,260p' .octon/instance/ingress/AGENTS.md`
- `sed -n '1,260p' .octon/framework/scaffolding/practices/prompts/unified-execution-constitution-atomic-cutover.prompt.md`
- `sed -n '1,260p' .octon/framework/constitution/charter.yml`
- `sed -n '1,260p' .octon/instance/governance/support-targets.yml`
- `sed -n '1,260p' .octon/framework/engine/runtime/crates/kernel/src/{main.rs,pipeline.rs,authorization.rs}`
- `sed -n '1,260p' .github/workflows/{ai-review-gate.yml,pr-auto-merge.yml}`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-assurance-disclosure-expansion.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-execution-constitution-closeout.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,mission-autonomy`
- `cargo build --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p policy_engine --bin octon-policy`
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel`
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel -- --test-threads=1`
