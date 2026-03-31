# Commands Log

- `cargo test -p octon_authority_engine`
- `cargo test -p octon_kernel pipeline:: -- --nocapture`
- `bash .octon/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-target-live-claims.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-phase4-proof-lab-enforcement.sh`
- `cargo run --manifest-path framework/engine/runtime/crates/Cargo.toml -p octon_kernel -- workflow list`
- `cargo run --manifest-path framework/engine/runtime/crates/Cargo.toml -p octon_kernel -- workflow run validate-proposal --run-id uec-validate-proposal-20260331-b --set proposal_path=.octon/inputs/exploratory/proposals/design/studio-graph-ux-design-package`
- `cargo run --manifest-path framework/engine/runtime/crates/Cargo.toml -p octon_kernel -- workflow run validate-proposal --run-id uec-validate-proposal-20260331-success --set proposal_path=.octon/inputs/exploratory/proposals/design/studio-graph-ux-design-package`
- `cargo run --manifest-path framework/engine/runtime/crates/Cargo.toml -p octon_kernel -- workflow run validate-proposal --run-id uec-validate-proposal-20260331-success-2 --set proposal_path=.octon/inputs/exploratory/proposals/design/studio-graph-ux-design-package`
- `cargo run --manifest-path framework/engine/runtime/crates/Cargo.toml -p octon_kernel -- workflow run validate-proposal --run-id uec-validate-proposal-20260331-success-3 --set proposal_path=.octon/inputs/exploratory/proposals/design/studio-graph-ux-design-package`
- `cargo run --manifest-path framework/engine/runtime/crates/Cargo.toml -p octon_kernel -- workflow run validate-proposal --run-id uec-validate-proposal-20260331-archive-success --set proposal_path=.octon/inputs/exploratory/proposals/.archive/architecture/execution-constitution-completion-closeout`
- `cargo run --manifest-path framework/engine/runtime/crates/Cargo.toml -p octon_kernel -- workflow run audit-architecture-proposal --run-id uec-audit-architecture-20260331 --set proposal_path=.octon/inputs/exploratory/proposals/.archive/architecture/execution-constitution-completion-closeout`
- `cargo run --manifest-path framework/engine/runtime/crates/Cargo.toml -p octon_kernel -- workflow run audit-architecture-proposal --run-id uec-audit-architecture-20260331-2 --set proposal_path=.octon/inputs/exploratory/proposals/.archive/architecture/execution-constitution-completion-closeout`
