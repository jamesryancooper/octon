mod ci_latency;

use anyhow::{anyhow, bail, Context, Result};
use clap::{Args, Parser, Subcommand};
use serde_json::{Map, Number, Value};
use sha2::{Digest, Sha256};
use std::cmp::Ordering;
use std::collections::{HashMap, HashSet};
use std::fs;
use std::path::{Path, PathBuf};

#[derive(Parser, Debug)]
#[command(name = "octon-assurance")]
#[command(about = "Octon assurance score and gate tools")]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand, Debug)]
enum Command {
    Score(ScoreArgs),
    Gate(GateArgs),
    CiLatency(ci_latency::CiLatencyArgs),
}

#[derive(Args, Debug)]
struct ScoreArgs {
    #[arg(
        long,
        default_value = ".octon/framework/assurance/governance/weights/weights.yml"
    )]
    weights: PathBuf,

    #[arg(
        long,
        default_value = ".octon/framework/assurance/governance/scores/scores.yml"
    )]
    scores: PathBuf,

    #[arg(long, default_value = ".octon/framework/assurance/governance/CHARTER.md")]
    charter: PathBuf,

    #[arg(
        long,
        default_value = ".octon/framework/assurance/governance/weights/inputs/context.yml"
    )]
    context: PathBuf,

    #[arg(
        long,
        default_value = ".octon/framework/assurance/governance/subsystem-classes.yml"
    )]
    subsystem_classes: PathBuf,

    #[arg(long, default_value = ".octon/framework/assurance/governance/overrides.yml")]
    overrides: PathBuf,

    #[arg(long)]
    profile: Option<String>,

    #[arg(long = "run-mode")]
    run_mode: Option<String>,

    #[arg(long)]
    maturity: Option<String>,

    #[arg(long)]
    repo: Option<String>,

    #[arg(long)]
    subsystems: Option<String>,

    #[arg(long)]
    baseline: Option<PathBuf>,

    #[arg(long)]
    out_dir: Option<PathBuf>,

    #[arg(long, default_value = ".octon/generated/effective/assurance")]
    effective_dir: PathBuf,

    #[arg(long, default_value = ".octon/generated/assurance/results")]
    results_dir: PathBuf,

    #[arg(long, default_value = ".octon/generated/assurance/policy/deviations")]
    deviations_dir: PathBuf,

    #[arg(long, default_value = ".octon/generated/effective/assurance")]
    lock_dir: PathBuf,
}

#[derive(Args, Debug)]
struct GateArgs {
    #[arg(long)]
    scorecard: PathBuf,

    #[arg(
        long,
        default_value = ".octon/framework/assurance/governance/weights/weights.yml"
    )]
    weights: PathBuf,

    #[arg(
        long,
        default_value = ".octon/framework/assurance/governance/scores/scores.yml"
    )]
    scores: PathBuf,

    #[arg(long, default_value = ".octon/framework/assurance/governance/CHARTER.md")]
    charter: PathBuf,

    #[arg(
        long,
        default_value = ".octon/framework/assurance/governance/subsystem-classes.yml"
    )]
    subsystem_classes: PathBuf,

    #[arg(long, default_value = ".octon/framework/assurance/governance/overrides.yml")]
    overrides: PathBuf,

    #[arg(long)]
    baseline_weights: Option<PathBuf>,

    #[arg(long)]
    baseline_scores: Option<PathBuf>,

    #[arg(long)]
    baseline_charter: Option<PathBuf>,

    #[arg(long)]
    mode: Option<String>,

    #[arg(long)]
    summary_out: Option<PathBuf>,

    #[arg(long, default_value_t = false)]
    strict_warnings: bool,
}

#[derive(Clone, Debug, Default)]
struct Policy {
    global: HashMap<String, i64>,
    run_mode: HashMap<String, HashMap<String, i64>>,
    subsystem: HashMap<String, HashMap<String, i64>>,
    maturity: HashMap<String, HashMap<String, i64>>,
    repo: HashMap<String, HashMap<String, i64>>,
}

#[derive(Clone, Debug)]
struct AttributeRec {
    score: f64,
    target_score: f64,
    criteria: Option<String>,
    evidence: Vec<String>,
    notes: Option<String>,
}

#[derive(Clone, Debug)]
struct SubsystemRec {
    owner: Option<String>,
    last_updated: Option<String>,
    notes: Option<String>,
    attributes: HashMap<String, AttributeRec>,
    conflicts: Vec<Value>,
}

#[derive(Clone, Debug)]
struct ClassRule {
    require_deviation_record: bool,
    require_adr: bool,
    require_changelog: bool,
    min_reviewers: i64,
    large_change_threshold: i64,
    require_adr_for_large_change: bool,
    warn_missing_expiry_without_permanent: bool,
}

#[derive(Clone, Debug)]
struct SubsystemClassPolicy {
    enforcement_phase: String,
    allowed_reason_categories: HashSet<String>,
    classes: HashMap<String, ClassRule>,
    subsystem_class: HashMap<String, String>,
}

#[derive(Clone, Debug)]
struct OverrideDecl {
    id: String,
    repo: String,
    profile: Option<String>,
    subsystem: String,
    attribute: String,
    old_value: i64,
    new_value: i64,
    reason_category: Option<String>,
    reason: Option<String>,
    adr: Option<String>,
    changelog_version: Option<String>,
    owner: Option<String>,
    created_at: Option<String>,
    temporary: bool,
    expires_at: Option<String>,
    permanent_justification: Option<String>,
    approved_by: Vec<String>,
    evidence: Vec<String>,
}

#[derive(Clone, Debug)]
struct OverrideRegistry {
    enforcement_phase: String,
    declarations: Vec<OverrideDecl>,
}

#[derive(Clone, Debug)]
struct CharterPriority {
    id: String,
    name: String,
}

#[derive(Clone, Debug)]
struct CharterSpec {
    reference_path: String,
    version: Option<String>,
    priority_chain: Vec<CharterPriority>,
    tie_break_rule: String,
    tradeoff_rules: Vec<String>,
    required_references: HashMap<String, String>,
    attribute_umbrella_map: HashMap<String, String>,
    priority_rank: HashMap<String, i64>,
}

#[derive(Clone, Debug)]
struct CharterDoc {
    priority_chain: Vec<String>,
    tradeoff_rules: Vec<String>,
}

#[derive(Clone, Debug, Default)]
struct UmbrellaAccumulator {
    weighted_sum: f64,
    weight_total: f64,
    sample_count: i64,
    critical_floor: Option<f64>,
}

fn main() {
    if let Err(err) = run() {
        eprintln!("{err}");
        std::process::exit(1);
    }
}

fn run() -> Result<()> {
    let cli = Cli::parse();
    match cli.command {
        Command::Score(args) => run_score(args),
        Command::Gate(args) => run_gate(args),
        Command::CiLatency(args) => ci_latency::run(args),
    }
}

fn run_score(args: ScoreArgs) -> Result<()> {
    let weights = load_yaml_json(&args.weights)?;
    let scores_raw = load_yaml_json(&args.scores)?;
    let charter_text = load_text(&args.charter)?;
    let context = load_yaml_json(&args.context)?;
    let subsystem_classes_raw = load_yaml_json_optional(&args.subsystem_classes)?;
    let overrides_raw = load_yaml_json_optional(&args.overrides)?;

    let (attribute_ids, attribute_names) = parse_attribute_catalog(&weights)?;
    let charter_doc = parse_charter_doc(&charter_text)?;
    let charter_spec = parse_charter_spec(&weights, &attribute_ids)?;
    validate_charter_alignment(
        &charter_spec,
        &charter_doc,
        &args.charter,
        &attribute_ids,
        None,
    )?;
    let normalized_scores = normalize_scores(&scores_raw, &attribute_ids)?;
    let class_policy = parse_subsystem_class_policy(subsystem_classes_raw.as_ref())?;
    let override_registry = parse_override_registry(overrides_raw.as_ref(), &class_policy)?;

    let context_map = as_object(context.get("context"))
        .cloned()
        .unwrap_or_default();
    let compare_map = as_object(context.get("comparison"))
        .cloned()
        .unwrap_or_default();

    let run_mode = args
        .run_mode
        .or_else(|| get_string_obj(&context_map, "run_mode"))
        .unwrap_or_else(|| "ci".to_string());
    let maturity = args
        .maturity
        .or_else(|| get_string_obj(&context_map, "maturity"))
        .unwrap_or_else(|| "beta".to_string());
    let repo = args
        .repo
        .or_else(|| get_string_obj(&context_map, "repo"))
        .unwrap_or_else(|| "octon".to_string());
    let explicit_profile = args
        .profile
        .or_else(|| get_string_obj(&context_map, "profile"));

    let profile = resolve_profile(&weights, explicit_profile.as_deref(), &run_mode, &maturity)?;
    let policy = resolve_profile_policy(&weights, &profile)?;

    let subsystem_filter: Option<HashSet<String>> = args.subsystems.as_ref().map(|csv| {
        csv.split(',')
            .map(|part| part.trim().to_string())
            .filter(|s| !s.is_empty())
            .collect()
    });

    let baseline_path = args
        .baseline
        .clone()
        .or_else(|| get_string_obj(&compare_map, "baseline_scorecard").map(PathBuf::from));
    let baseline = match baseline_path.as_ref() {
        Some(path) => Some(load_yaml_json(path)?),
        None => None,
    };

    let now = chrono_like_now();
    let out_dir = args
        .out_dir
        .clone()
        .unwrap_or_else(|| default_out_dir(&now));
    ensure_dir(&out_dir)?;
    ensure_dir(&args.effective_dir)?;
    ensure_dir(&args.results_dir)?;
    ensure_dir(&args.deviations_dir)?;

    let run_id = now.run_id.clone();
    let generated_at = now.iso.clone();

    let baseline_subsystems = as_object(baseline.as_ref().and_then(|b| b.get("subsystems")))
        .cloned()
        .unwrap_or_default();

    let mut subsystems_out = Map::new();
    let mut effective_weights_all = Map::new();
    let mut subsystem_scores: Vec<f64> = Vec::new();

    let mut backlog_drivers: Vec<Value> = Vec::new();
    let mut regression_drivers: Vec<Value> = Vec::new();
    let mut hard_regressions: Vec<Value> = Vec::new();
    let mut soft_regressions: Vec<Value> = Vec::new();
    let mut policy_deviations: Vec<Value> = Vec::new();
    let mut umbrella_rollup_acc: HashMap<String, UmbrellaAccumulator> = HashMap::new();

    let mut subsystem_names: Vec<String> = normalized_scores.keys().cloned().collect();
    subsystem_names.sort();

    for subsystem in subsystem_names {
        if let Some(filter) = subsystem_filter.as_ref() {
            if !filter.contains(&subsystem) {
                continue;
            }
        }

        let subsystem_cfg = normalized_scores
            .get(&subsystem)
            .ok_or_else(|| anyhow!("missing subsystem cfg"))?;

        let (effective_weights, applied_overrides) = build_effective_weights(
            &policy,
            &attribute_ids,
            &run_mode,
            &subsystem,
            &maturity,
            &repo,
        )?;
        let baseline_without_repo = build_effective_weights_without_repo(
            &policy,
            &attribute_ids,
            &run_mode,
            &subsystem,
            &maturity,
        )?;

        policy_deviations.extend(compute_policy_deviations_for_subsystem(
            &weights,
            Some(&charter_spec),
            &class_policy,
            &override_registry,
            &profile,
            &repo,
            &subsystem,
            &baseline_without_repo,
            &effective_weights,
            policy.repo.get(&repo),
            policy.subsystem.get(&subsystem),
        ));

        effective_weights_all.insert(subsystem.clone(), json_obj_from_i64_map(&effective_weights));

        let baseline_attrs_obj = as_object(
            baseline_subsystems
                .get(&subsystem)
                .and_then(|s| s.get("attributes")),
        )
        .cloned()
        .unwrap_or_default();

        let mut numerator = 0.0_f64;
        let mut denominator = 0.0_f64;
        let mut attrs_out = Map::new();

        for attr in &attribute_ids {
            let weight = *effective_weights
                .get(attr)
                .ok_or_else(|| anyhow!("missing effective weight for {attr}"))?;
            let rec = subsystem_cfg
                .attributes
                .get(attr)
                .ok_or_else(|| anyhow!("missing normalized score for {subsystem}.{attr}"))?;

            let measured = clamp(rec.score, 0.0, 5.0);
            let target = clamp(rec.target_score, 0.0, 5.0);

            let weighted_value = measured * weight as f64;
            let max_weighted_value = 5.0 * weight as f64;
            numerator += weighted_value;
            denominator += max_weighted_value;

            let delta = baseline
                .as_ref()
                .and_then(|_| baseline_attrs_obj.get(attr))
                .map(baseline_value)
                .map(|prev| round3(measured - prev));

            let impact = delta.map(|d| round3(d * weight as f64));
            let gap = round3((target - measured).max(0.0));
            let priority = round3(gap * weight as f64);
            let umbrella = charter_spec
                .attribute_umbrella_map
                .get(attr)
                .cloned()
                .unwrap_or_else(|| "unmapped".to_string());
            let umbrella_rank = charter_spec
                .priority_rank
                .get(&umbrella)
                .copied()
                .unwrap_or(i64::MAX);

            let entry = umbrella_rollup_acc.entry(umbrella.clone()).or_default();
            entry.weighted_sum += measured * weight as f64;
            entry.weight_total += weight as f64;
            entry.sample_count += 1;
            if umbrella == "assurance" && is_assurance_critical(attr) {
                entry.critical_floor =
                    Some(entry.critical_floor.map_or(measured, |v| v.min(measured)));
            }

            let criteria = rec.criteria.clone();
            let evidence = rec.evidence.clone();
            let notes = rec.notes.clone();

            let mut attr_map = Map::new();
            attr_map.insert("weight".to_string(), Value::Number(Number::from(weight)));
            attr_map.insert("measured".to_string(), num(round3(measured)));
            attr_map.insert("target".to_string(), num(round3(target)));
            attr_map.insert("gap".to_string(), num(gap));
            attr_map.insert("priority".to_string(), num(priority));
            attr_map.insert("weighted_value".to_string(), num(round3(weighted_value)));
            attr_map.insert(
                "max_weighted_value".to_string(),
                num(round3(max_weighted_value)),
            );
            attr_map.insert("delta".to_string(), opt_num(delta));
            attr_map.insert("impact".to_string(), opt_num(impact));
            attr_map.insert("umbrella".to_string(), Value::String(umbrella.clone()));
            attr_map.insert(
                "umbrella_rank".to_string(),
                Value::Number(Number::from(umbrella_rank)),
            );
            attr_map.insert("criteria".to_string(), opt_string(criteria.clone()));
            attr_map.insert(
                "evidence".to_string(),
                Value::Array(evidence.iter().cloned().map(Value::String).collect()),
            );
            attr_map.insert("notes".to_string(), opt_string(notes));
            attrs_out.insert(attr.clone(), Value::Object(attr_map));

            backlog_drivers.push(Value::Object({
                let mut m = Map::new();
                m.insert("subsystem".to_string(), Value::String(subsystem.clone()));
                m.insert("attribute".to_string(), Value::String(attr.clone()));
                m.insert("weight".to_string(), Value::Number(Number::from(weight)));
                m.insert("measured".to_string(), num(round3(measured)));
                m.insert("target".to_string(), num(round3(target)));
                m.insert("gap".to_string(), num(gap));
                m.insert("priority".to_string(), num(priority));
                m.insert("umbrella".to_string(), Value::String(umbrella.clone()));
                m.insert(
                    "umbrella_rank".to_string(),
                    Value::Number(Number::from(umbrella_rank)),
                );
                m.insert(
                    "evidence".to_string(),
                    Value::Array(evidence.iter().cloned().map(Value::String).collect()),
                );
                m.insert(
                    "suggested_action".to_string(),
                    Value::String(suggest_action(
                        attr,
                        measured,
                        target,
                        delta,
                        criteria.is_some(),
                        !evidence.is_empty(),
                    )),
                );
                m
            }));

            if let Some(delta_val) = delta {
                let impact_val = round3(delta_val * weight as f64);
                regression_drivers.push(Value::Object({
                    let mut m = Map::new();
                    m.insert("subsystem".to_string(), Value::String(subsystem.clone()));
                    m.insert("attribute".to_string(), Value::String(attr.clone()));
                    m.insert("weight".to_string(), Value::Number(Number::from(weight)));
                    m.insert("measured".to_string(), num(round3(measured)));
                    m.insert("delta".to_string(), num(delta_val));
                    m.insert("impact".to_string(), num(impact_val));
                    m.insert("abs_impact".to_string(), num(impact_val.abs()));
                    m.insert("umbrella".to_string(), Value::String(umbrella.clone()));
                    m.insert(
                        "umbrella_rank".to_string(),
                        Value::Number(Number::from(umbrella_rank)),
                    );
                    m
                }));

                if weight >= 5 && delta_val <= -0.5 {
                    hard_regressions.push(regression_rec(
                        &subsystem,
                        attr,
                        &umbrella,
                        umbrella_rank,
                        weight,
                        delta_val,
                        impact_val,
                        "w>=5 and delta<=-0.5",
                    ));
                } else if weight >= 4 && delta_val <= -1.0 {
                    hard_regressions.push(regression_rec(
                        &subsystem,
                        attr,
                        &umbrella,
                        umbrella_rank,
                        weight,
                        delta_val,
                        impact_val,
                        "w>=4 and delta<=-1.0",
                    ));
                } else if weight >= 4 && delta_val <= -0.5 {
                    soft_regressions.push(regression_rec(
                        &subsystem,
                        attr,
                        &umbrella,
                        umbrella_rank,
                        weight,
                        delta_val,
                        impact_val,
                        "w>=4 and -1.0<delta<=-0.5",
                    ));
                }
            }
        }

        let score = if denominator > 0.0 {
            numerator / denominator
        } else {
            0.0
        };
        subsystem_scores.push(score);

        let mut subsystem_out = Map::new();
        subsystem_out.insert("score".to_string(), num(round6(score)));
        subsystem_out.insert("score_percent".to_string(), num(round2(score * 100.0)));
        subsystem_out.insert(
            "weights_source".to_string(),
            Value::Object({
                let mut m = Map::new();
                m.insert("profile".to_string(), Value::String(profile.clone()));
                m.insert(
                    "overrides_applied".to_string(),
                    Value::Array(applied_overrides.into_iter().map(Value::String).collect()),
                );
                m
            }),
        );
        subsystem_out.insert("owner".to_string(), opt_string(subsystem_cfg.owner.clone()));
        subsystem_out.insert(
            "last_updated".to_string(),
            opt_string(subsystem_cfg.last_updated.clone()),
        );
        subsystem_out.insert("notes".to_string(), opt_string(subsystem_cfg.notes.clone()));
        subsystem_out.insert("attributes".to_string(), Value::Object(attrs_out));
        subsystem_out.insert(
            "conflicts".to_string(),
            Value::Array(subsystem_cfg.conflicts.clone()),
        );

        subsystems_out.insert(subsystem, Value::Object(subsystem_out));
    }

    if subsystems_out.is_empty() {
        bail!("no subsystems matched selection");
    }

    let system_score = if subsystem_scores.is_empty() {
        0.0
    } else {
        subsystem_scores.iter().sum::<f64>() / subsystem_scores.len() as f64
    };
    let umbrella_rollups = compute_umbrella_rollups(&charter_spec, &umbrella_rollup_acc);

    backlog_drivers.sort_by(|a, b| {
        cmp_num(b.get("priority"), a.get("priority"))
            .then_with(|| cmp_num(a.get("umbrella_rank"), b.get("umbrella_rank")))
            .then_with(|| cmp_num(b.get("weight"), a.get("weight")))
    });
    let top_backlog: Vec<Value> = backlog_drivers
        .into_iter()
        .filter(|v| value_f64(v.get("priority")) > 0.0)
        .take(20)
        .collect();
    let tie_break_resolutions = detect_tie_break_resolutions(&top_backlog);

    regression_drivers.sort_by(|a, b| {
        cmp_num(b.get("abs_impact"), a.get("abs_impact"))
            .then_with(|| cmp_num(a.get("umbrella_rank"), b.get("umbrella_rank")))
            .then_with(|| cmp_num(b.get("weight"), a.get("weight")))
    });
    let top_regressions: Vec<Value> = regression_drivers
        .into_iter()
        .filter(|v| value_f64(v.get("abs_impact")) > 0.0)
        .take(20)
        .collect();

    let slug = context_slug(&repo, &run_mode, &maturity, &profile);

    let mut scorecard = Map::new();
    scorecard.insert(
        "meta".to_string(),
        Value::Object({
            let mut m = Map::new();
            m.insert(
                "tool".to_string(),
                Value::String("compute-assurance-score".to_string()),
            );
            m.insert(
                "tool_version".to_string(),
                Value::String("0.3.0".to_string()),
            );
            m.insert(
                "generated_at".to_string(),
                Value::String(generated_at.clone()),
            );
            m.insert("run_id".to_string(), Value::String(run_id.clone()));
            m.insert(
                "source_hash".to_string(),
                Value::String(source_hash(&[
                    args.weights.clone(),
                    args.scores.clone(),
                    args.charter.clone(),
                    args.context.clone(),
                    args.subsystem_classes.clone(),
                    args.overrides.clone(),
                ])?),
            );
            m
        }),
    );
    scorecard.insert(
        "context".to_string(),
        Value::Object({
            let mut m = Map::new();
            m.insert("profile".to_string(), Value::String(profile.clone()));
            m.insert("run_mode".to_string(), Value::String(run_mode.clone()));
            m.insert("maturity".to_string(), Value::String(maturity.clone()));
            m.insert("repo".to_string(), Value::String(repo.clone()));
            m.insert("context_slug".to_string(), Value::String(slug.clone()));
            m.insert(
                "baseline_present".to_string(),
                Value::Bool(baseline.is_some()),
            );
            m.insert(
                "baseline_scorecard".to_string(),
                baseline_path
                    .as_ref()
                    .map(|p| Value::String(p.to_string_lossy().to_string()))
                    .unwrap_or(Value::Null),
            );
            m
        }),
    );
    scorecard.insert(
        "charter".to_string(),
        Value::Object({
            let mut m = Map::new();
            m.insert(
                "reference".to_string(),
                Value::String(charter_spec.reference_path.clone()),
            );
            m.insert(
                "version".to_string(),
                charter_spec
                    .version
                    .as_ref()
                    .map(|v| Value::String(v.clone()))
                    .unwrap_or(Value::Null),
            );
            m.insert(
                "priority_chain".to_string(),
                Value::Array(
                    charter_spec
                        .priority_chain
                        .iter()
                        .map(|item| {
                            Value::Object({
                                let mut item_map = Map::new();
                                item_map.insert("id".to_string(), Value::String(item.id.clone()));
                                item_map
                                    .insert("name".to_string(), Value::String(item.name.clone()));
                                item_map
                            })
                        })
                        .collect(),
                ),
            );
            m.insert(
                "priority_chain_source".to_string(),
                Value::Array(
                    charter_doc
                        .priority_chain
                        .iter()
                        .cloned()
                        .map(Value::String)
                        .collect(),
                ),
            );
            m.insert(
                "tradeoff_rules".to_string(),
                Value::Array(
                    charter_spec
                        .tradeoff_rules
                        .iter()
                        .cloned()
                        .map(Value::String)
                        .collect(),
                ),
            );
            m.insert(
                "tradeoff_rules_source".to_string(),
                Value::Array(
                    charter_doc
                        .tradeoff_rules
                        .iter()
                        .cloned()
                        .map(Value::String)
                        .collect(),
                ),
            );
            m.insert(
                "tie_break_rule".to_string(),
                Value::String(charter_spec.tie_break_rule.clone()),
            );
            m.insert(
                "tie_break_resolutions".to_string(),
                Value::Array(tie_break_resolutions.clone()),
            );
            m
        }),
    );
    scorecard.insert(
        "overall".to_string(),
        Value::Object({
            let mut m = Map::new();
            m.insert("system_score".to_string(), num(round6(system_score)));
            m.insert(
                "system_score_percent".to_string(),
                num(round2(system_score * 100.0)),
            );
            m.insert(
                "subsystem_count".to_string(),
                Value::Number(Number::from(subsystems_out.len() as i64)),
            );
            m
        }),
    );
    scorecard.insert(
        "umbrellas".to_string(),
        Value::Array(umbrella_rollups.clone()),
    );
    scorecard.insert(
        "subsystems".to_string(),
        Value::Object(subsystems_out.clone()),
    );
    scorecard.insert(
        "drivers".to_string(),
        Value::Object({
            let mut m = Map::new();
            m.insert("top_backlog".to_string(), Value::Array(top_backlog.clone()));
            m.insert(
                "top_regressions".to_string(),
                Value::Array(top_regressions.clone()),
            );
            m
        }),
    );
    scorecard.insert(
        "regressions".to_string(),
        Value::Object({
            let mut m = Map::new();
            m.insert(
                "baseline_present".to_string(),
                Value::Bool(baseline.is_some()),
            );
            m.insert("hard".to_string(), Value::Array(hard_regressions.clone()));
            m.insert("soft".to_string(), Value::Array(soft_regressions.clone()));
            m
        }),
    );
    scorecard.insert(
        "effective_weights".to_string(),
        Value::Object(effective_weights_all.clone()),
    );
    scorecard.insert(
        "policy_deviations".to_string(),
        Value::Object({
            let mut m = Map::new();
            let mut sorted = policy_deviations;
            sorted.sort_by(|a, b| {
                cmp_string(a.get("subsystem"), b.get("subsystem"))
                    .then_with(|| cmp_string(a.get("attribute"), b.get("attribute")))
            });
            let total = sorted.len();
            let permitted = sorted
                .iter()
                .filter(|v| {
                    v.get("policy_permitted")
                        .and_then(|x| x.as_bool())
                        .unwrap_or(false)
                })
                .count();
            m.insert(
                "enforcement_phase".to_string(),
                Value::String(override_registry.enforcement_phase.clone()),
            );
            m.insert(
                "total".to_string(),
                Value::Number(Number::from(total as i64)),
            );
            m.insert(
                "permitted".to_string(),
                Value::Number(Number::from(permitted as i64)),
            );
            m.insert(
                "items".to_string(),
                Value::Array(sorted.into_iter().collect::<Vec<Value>>()),
            );
            m
        }),
    );

    let scorecard_value = Value::Object(scorecard.clone());
    let scorecard_yml = out_dir.join("scorecard.yml");
    let scorecard_md = out_dir.join("scorecard.md");
    let regressions_md = out_dir.join("regressions.md");
    let effective_weights_yml = out_dir.join("effective-weights.yml");

    write_yaml(&scorecard_yml, &scorecard_value)?;
    write_text(&scorecard_md, &render_scorecard_md(&scorecard_value)?)?;
    write_text(&regressions_md, &render_regressions_md(&scorecard_value)?)?;
    write_yaml(
        &effective_weights_yml,
        &Value::Object({
            let mut m = Map::new();
            m.insert(
                "effective_weights".to_string(),
                Value::Object(effective_weights_all.clone()),
            );
            m
        }),
    )?;

    let effective_md_path = args.effective_dir.join(format!("{slug}.md"));
    let results_md_path = args.results_dir.join(format!("{slug}.md"));
    let deviations_md_path = args.deviations_dir.join(format!("{slug}.md"));
    write_text(
        &effective_md_path,
        &render_effective_md(
            &profile,
            &repo,
            &run_mode,
            &maturity,
            &attribute_ids,
            &attribute_names,
            &effective_weights_all,
            &charter_spec,
            &tie_break_resolutions,
        ),
    )?;
    write_text(&results_md_path, &render_results_md(&scorecard_value)?)?;
    write_text(
        &deviations_md_path,
        &render_deviations_md(&scorecard_value)?,
    )?;
    write_yaml(
        &out_dir.join("deviations.yml"),
        scorecard_value
            .get("policy_deviations")
            .unwrap_or(&Value::Null),
    )?;
    write_text(
        &out_dir.join("deviations.md"),
        &render_deviations_md(&scorecard_value)?,
    )?;

    ensure_dir(&args.lock_dir)?;
    write_yaml(
        &args.lock_dir.join("active-weight-context.lock.yml"),
        &Value::Object({
            let mut m = Map::new();
            m.insert(
                "context".to_string(),
                Value::Object({
                    let mut c = Map::new();
                    c.insert("profile".to_string(), Value::String(profile.clone()));
                    c.insert("run_mode".to_string(), Value::String(run_mode.clone()));
                    c.insert("maturity".to_string(), Value::String(maturity.clone()));
                    c.insert("repo".to_string(), Value::String(repo.clone()));
                    c.insert("context_slug".to_string(), Value::String(slug.clone()));
                    c
                }),
            );
            m.insert(
                "generated_at".to_string(),
                Value::String(generated_at.clone()),
            );
            m.insert("run_id".to_string(), Value::String(run_id.clone()));
            m
        }),
    )?;
    write_yaml(
        &args.lock_dir.join("effective-weights.lock.yml"),
        &Value::Object({
            let mut m = Map::new();
            m.insert("generated_at".to_string(), Value::String(generated_at));
            m.insert("run_id".to_string(), Value::String(run_id));
            m.insert("context_slug".to_string(), Value::String(slug));
            m.insert(
                "effective_weights".to_string(),
                Value::Object(effective_weights_all),
            );
            m
        }),
    )?;

    println!("scorecard: {}", scorecard_yml.display());
    println!("summary: {}", scorecard_md.display());
    println!("effective weights: {}", effective_weights_yml.display());
    println!("regressions: {}", regressions_md.display());
    println!("effective matrix: {}", effective_md_path.display());
    println!("assurance results: {}", results_md_path.display());
    println!("policy deviations: {}", deviations_md_path.display());

    Ok(())
}

fn run_gate(args: GateArgs) -> Result<()> {
    let scorecard = load_yaml_json(&args.scorecard)?;
    let weights = load_yaml_json(&args.weights)?;
    let scores = load_yaml_json(&args.scores)?;
    let subsystem_classes_raw = load_yaml_json_optional(&args.subsystem_classes)?;
    let overrides_raw = load_yaml_json_optional(&args.overrides)?;
    let class_policy = parse_subsystem_class_policy(subsystem_classes_raw.as_ref())?;
    let override_registry = parse_override_registry(overrides_raw.as_ref(), &class_policy)?;
    let (attribute_ids, _attribute_names) = parse_attribute_catalog(&weights)?;

    let baseline_weights = match args.baseline_weights.as_ref() {
        Some(p) => Some(load_yaml_json(p)?),
        None => None,
    };
    let baseline_scores = match args.baseline_scores.as_ref() {
        Some(p) => Some(load_yaml_json(p)?),
        None => None,
    };
    let baseline_charter = match args.baseline_charter.as_ref() {
        Some(p) => Some(load_text(p)?),
        None => None,
    };

    let context = as_object(scorecard.get("context"))
        .cloned()
        .unwrap_or_default();
    let mode = args
        .mode
        .clone()
        .or_else(|| get_string_obj(&context, "run_mode"))
        .unwrap_or_else(|| "ci".to_string());
    let maturity = get_string_obj(&context, "maturity").unwrap_or_else(|| "beta".to_string());
    let repo = get_string_obj(&context, "repo").unwrap_or_else(|| "octon".to_string());
    let profile = get_string_obj(&context, "profile")
        .or_else(|| resolve_profile(&weights, None, &mode, &maturity).ok())
        .unwrap_or_else(|| "global-default".to_string());

    let mut findings: Vec<Finding> = Vec::new();
    let mut charter_spec_opt: Option<CharterSpec> = None;
    let mut charter_doc_opt: Option<CharterDoc> = None;

    if !args.charter.exists() {
        findings.push(Finding::hard(
            "charter-missing",
            "policy",
            "charter",
            &format!(
                "Required charter file is missing: {}",
                args.charter.display()
            ),
        ));
    } else {
        match load_text(&args.charter) {
            Ok(text) => match parse_charter_doc(&text) {
                Ok(doc) => {
                    charter_doc_opt = Some(doc);
                }
                Err(err) => findings.push(Finding::hard(
                    "charter-parse-failed",
                    "policy",
                    "charter",
                    &format!("Failed to parse charter content: {err}"),
                )),
            },
            Err(err) => findings.push(Finding::hard(
                "charter-read-failed",
                "policy",
                "charter",
                &format!("Failed to read charter file: {err}"),
            )),
        }

        match parse_charter_spec(&weights, &attribute_ids) {
            Ok(spec) => {
                charter_spec_opt = Some(spec);
            }
            Err(err) => findings.push(Finding::hard(
                "weights-charter-contract-missing",
                "policy",
                "weights",
                &format!("weights.yml charter contract is invalid: {err}"),
            )),
        }

        if let (Some(spec), Some(doc)) = (charter_spec_opt.as_ref(), charter_doc_opt.as_ref()) {
            if let Err(err) = validate_charter_alignment(
                spec,
                doc,
                &args.charter,
                &attribute_ids,
                Some(&mut findings),
            ) {
                findings.push(Finding::hard(
                    "charter-validation-failed",
                    "policy",
                    "charter",
                    &format!("Charter alignment check failed: {err}"),
                ));
            }
        }
    }

    let subsystems = as_object(scorecard.get("subsystems"))
        .cloned()
        .unwrap_or_default();

    for (subsystem, subsystem_data) in sorted_object_iter(&subsystems) {
        let attrs = as_object(subsystem_data.get("attributes"))
            .cloned()
            .unwrap_or_default();

        for (attribute, rec) in sorted_object_iter(&attrs) {
            let weight = value_i64(rec.get("weight"));
            if weight < 1 {
                continue;
            }
            let umbrella = value_string(rec.get("umbrella")).unwrap_or_default();
            let umbrella_rank = value_i64(rec.get("umbrella_rank"));
            let assurance_priority = umbrella_rank == 1;

            let criteria = value_string(rec.get("criteria"));
            let evidence = value_string_array(rec.get("evidence"));
            let has_criteria = criteria
                .as_ref()
                .map(|s| !s.trim().is_empty())
                .unwrap_or(false);
            let has_evidence = !evidence.is_empty();

            if weight >= 5 {
                if !has_criteria {
                    findings.push(Finding::hard(
                        "missing-criteria-w5",
                        subsystem,
                        attribute,
                        "Missing acceptance criteria for weight 5 attribute.",
                    ));
                }
                if matches!(mode.as_str(), "ci" | "release" | "prod-runtime") && !has_evidence {
                    findings.push(Finding::hard(
                        "missing-evidence-w5",
                        subsystem,
                        attribute,
                        "Missing evidence for weight 5 attribute in strict mode.",
                    ));
                } else if mode == "local" && !has_evidence {
                    findings.push(Finding::warn(
                        "missing-evidence-w5-local",
                        subsystem,
                        attribute,
                        "Missing evidence for weight 5 attribute in local mode.",
                    ));
                }
            } else if weight == 4 {
                if !has_criteria {
                    if matches!(mode.as_str(), "release" | "prod-runtime")
                        && matches!(maturity.as_str(), "prod" | "critical")
                    {
                        findings.push(Finding::hard(
                            "missing-criteria-w4-prod",
                            subsystem,
                            attribute,
                            "Missing criteria for weight 4 attribute in prod/critical release mode.",
                        ));
                    } else {
                        findings.push(Finding::warn(
                            "missing-criteria-w4",
                            subsystem,
                            attribute,
                            "Missing criteria for weight 4 attribute.",
                        ));
                    }
                }

                if !has_evidence {
                    if matches!(mode.as_str(), "release" | "prod-runtime")
                        && matches!(maturity.as_str(), "prod" | "critical")
                    {
                        findings.push(Finding::hard(
                            "missing-evidence-w4-prod",
                            subsystem,
                            attribute,
                            "Missing evidence for weight 4 attribute in prod/critical release mode.",
                        ));
                    } else if mode == "ci"
                        && matches!(maturity.as_str(), "beta" | "prod" | "critical")
                    {
                        findings.push(Finding::warn(
                            "missing-evidence-w4-ci",
                            subsystem,
                            attribute,
                            "Missing evidence for weight 4 attribute in CI at beta+ maturity.",
                        ));
                    }
                }
            }

            if assurance_priority && weight == 3 {
                if !has_criteria {
                    findings.push(if matches!(mode.as_str(), "release" | "prod-runtime") {
                        Finding::hard(
                            "missing-criteria-assurance-priority",
                            subsystem,
                            attribute,
                            "Assurance-priority attribute (w=3) requires acceptance criteria in release/prod-runtime modes.",
                        )
                    } else {
                        Finding::warn(
                            "missing-criteria-assurance-priority",
                            subsystem,
                            attribute,
                            "Assurance-priority attribute (w=3) should define acceptance criteria.",
                        )
                    });
                }

                if !has_evidence {
                    findings.push(if matches!(mode.as_str(), "release" | "prod-runtime") {
                        Finding::hard(
                            "missing-evidence-assurance-priority",
                            subsystem,
                            attribute,
                            "Assurance-priority attribute (w=3) requires evidence in release/prod-runtime modes.",
                        )
                    } else {
                        Finding::warn(
                            "missing-evidence-assurance-priority",
                            subsystem,
                            attribute,
                            "Assurance-priority attribute (w=3) should include evidence pointers.",
                        )
                    });
                }
            }

            let delta = rec.get("delta").map(|v| value_f64(Some(v))).unwrap_or(0.0);
            if rec.get("delta").is_some() {
                if weight >= 5 && delta <= -0.5 {
                    findings.push(if mode == "local" {
                        Finding::warn(
                            "regression-w5",
                            subsystem,
                            attribute,
                            &format!("Regression delta={delta} exceeds threshold for weight 5."),
                        )
                    } else {
                        Finding::hard(
                            "regression-w5",
                            subsystem,
                            attribute,
                            &format!("Regression delta={delta} exceeds threshold for weight 5."),
                        )
                    });
                } else if weight >= 4 && delta <= -1.0 {
                    findings.push(if mode == "local" {
                        Finding::warn(
                            "regression-w4-hard",
                            subsystem,
                            attribute,
                            &format!(
                                "Regression delta={delta} exceeds hard threshold for weight 4+."
                            ),
                        )
                    } else {
                        Finding::hard(
                            "regression-w4-hard",
                            subsystem,
                            attribute,
                            &format!(
                                "Regression delta={delta} exceeds hard threshold for weight 4+."
                            ),
                        )
                    });
                } else if weight >= 4 && delta <= -0.5 {
                    findings.push(Finding::warn(
                        "regression-w4-warn",
                        subsystem,
                        attribute,
                        &format!(
                            "Regression delta={delta} exceeds warning threshold for weight 4+."
                        ),
                    ));
                } else if assurance_priority && weight == 3 && delta <= -0.5 {
                    findings.push(Finding::warn(
                        "regression-assurance-priority-w3",
                        subsystem,
                        attribute,
                        &format!(
                            "Assurance-priority regression delta={delta} exceeds warning threshold for umbrella rank 1 (w=3)."
                        ),
                    ));
                }
            }

            let measured = value_f64(rec.get("measured"));
            if measured <= 2.0 && !has_evidence {
                findings.push(classified(
                    &mode,
                    "missing-evidence-low-score",
                    subsystem,
                    attribute,
                    "Score <= 2 requires evidence pointer(s).",
                ));
            }

            if rec.get("delta").is_some()
                && delta < 0.0
                && (weight >= 4 || (assurance_priority && weight == 3))
                && !has_evidence
            {
                findings.push(classified(
                    &mode,
                    "missing-evidence-regression-high-weight",
                    subsystem,
                    attribute,
                    &format!(
                        "High-priority regression requires evidence pointer(s) (umbrella='{}', rank={}).",
                        umbrella, umbrella_rank
                    ),
                ));
            }
        }

        let conflicts = value_array(subsystem_data.get("conflicts"));
        for conflict in conflicts {
            let attrs_pair = value_string_array(conflict.get("attributes"));
            if attrs_pair.len() != 2 {
                continue;
            }
            let a = attrs_pair[0].clone();
            let b = attrs_pair[1].clone();
            let aw = value_i64(attrs.get(&a).and_then(|x| x.get("weight")));
            let bw = value_i64(attrs.get(&b).and_then(|x| x.get("weight")));
            let adr = value_string(conflict.get("adr"));
            if aw == 5 && bw == 5 && !is_non_empty_text(adr.as_deref()) {
                findings.push(if mode == "local" {
                    Finding::warn(
                        "missing-adr-5v5",
                        subsystem,
                        &format!("{a},{b}"),
                        "Missing ADR for unresolved 5 vs 5 attribute conflict.",
                    )
                } else {
                    Finding::hard(
                        "missing-adr-5v5",
                        subsystem,
                        &format!("{a},{b}"),
                        "Missing ADR for unresolved 5 vs 5 attribute conflict.",
                    )
                });
            }
        }
    }

    let policy = resolve_profile_policy(&weights, &profile)?;
    let mut subsystem_names: Vec<String> = subsystems.keys().cloned().collect();
    subsystem_names.sort();
    let mut deviations: Vec<Value> = Vec::new();
    for subsystem in subsystem_names {
        let full =
            build_effective_weights(&policy, &attribute_ids, &mode, &subsystem, &maturity, &repo)?
                .0;
        let without_repo = build_effective_weights_without_repo(
            &policy,
            &attribute_ids,
            &mode,
            &subsystem,
            &maturity,
        )?;
        deviations.extend(compute_policy_deviations_for_subsystem(
            &weights,
            charter_spec_opt.as_ref(),
            &class_policy,
            &override_registry,
            &profile,
            &repo,
            &subsystem,
            &without_repo,
            &full,
            policy.repo.get(&repo),
            policy.subsystem.get(&subsystem),
        ));
    }
    apply_deviation_findings(
        &mut findings,
        &deviations,
        &override_registry.enforcement_phase,
        &mode,
    );
    if let Some(spec) = charter_spec_opt.as_ref() {
        apply_top_driver_tie_break_findings(&mut findings, &scorecard, spec);
    }

    let current_policy_hash = extract_policy_fingerprint(&weights)?;
    let baseline_policy_hash = match baseline_weights.as_ref() {
        Some(w) => Some(extract_policy_fingerprint(w)?),
        None => None,
    };
    let policy_changed = baseline_policy_hash
        .as_ref()
        .map(|h| h != &current_policy_hash)
        .unwrap_or(false);
    let current_charter_hash = if args.charter.exists() {
        Some(sha256_hex(load_text(&args.charter)?.as_bytes()))
    } else {
        None
    };
    let charter_changed = match (current_charter_hash.as_ref(), baseline_charter.as_ref()) {
        (Some(current), Some(base)) => current != &sha256_hex(base.as_bytes()),
        _ => false,
    };
    let current_version =
        value_string(weights.get("meta").and_then(|m| m.get("version"))).unwrap_or_default();
    let baseline_version = baseline_weights
        .as_ref()
        .and_then(|w| value_string(w.get("meta").and_then(|m| m.get("version"))))
        .unwrap_or_default();

    if baseline_weights.is_none() {
        findings.push(Finding::warn(
            "baseline-weights-missing",
            "policy",
            "weights",
            "Baseline weights not provided; change-governance checks are limited.",
        ));
    }
    if baseline_charter.is_none() {
        findings.push(Finding::warn(
            "baseline-charter-missing",
            "policy",
            "charter",
            "Baseline charter not provided; charter drift detection is limited.",
        ));
    }

    if policy_changed || charter_changed {
        if current_version == baseline_version {
            findings.push(Finding::hard(
                if charter_changed {
                    "charter-version-bump-missing"
                } else {
                    "weights-version-bump-missing"
                },
                "policy",
                if charter_changed {
                    "charter"
                } else {
                    "weights"
                },
                if charter_changed {
                    "Charter changed without policy version bump in weights meta."
                } else {
                    "Policy weights changed without version bump in weights meta."
                },
            ));
        }

        if current_version.trim().is_empty() {
            findings.push(Finding::hard(
                "weights-version-empty",
                "policy",
                "weights",
                "Policy weights changed but current weights meta.version is empty.",
            ));
        } else {
            let changelog_entry = find_changelog_entry(&weights, &current_version);
            if changelog_entry.is_none() {
                findings.push(Finding::hard(
                    "weights-changelog-entry-missing",
                    "policy",
                    "weights",
                    &format!(
                        "Policy weights changed but changelog lacks entry for version {current_version}."
                    ),
                ));
            } else if let Some(entry) = changelog_entry {
                let rationale = value_string(entry.get("rationale"));
                let adr = value_string(entry.get("adr"));
                if !is_non_empty_text(rationale.as_deref()) {
                    findings.push(Finding::hard(
                        "weights-rationale-missing",
                        "policy",
                        "weights",
                        "Policy weights changed but changelog rationale is missing.",
                    ));
                }
                if !adr_is_valid(adr.as_deref()) {
                    findings.push(Finding::hard(
                        "weights-adr-missing",
                        "policy",
                        "weights",
                        "Policy weights changed but changelog ADR reference is missing/invalid.",
                    ));
                }
                let charter_ref = value_string(entry.get("charter_ref"));
                if !is_non_empty_text(charter_ref.as_deref()) {
                    findings.push(Finding::hard(
                        "weights-charter-reference-missing",
                        "policy",
                        "weights",
                        "Governed policy/charter changes require changelog charter_ref.",
                    ));
                } else if let Some(spec) = charter_spec_opt.as_ref() {
                    let expected = spec.reference_path.trim();
                    let found = charter_ref.unwrap_or_default();
                    if normalize_text_key(&found) != normalize_text_key(expected) {
                        findings.push(Finding::hard(
                            "weights-charter-reference-mismatch",
                            "policy",
                            "weights",
                            &format!(
                                "changelog charter_ref '{}' does not match expected '{}'.",
                                found, expected
                            ),
                        ));
                    }
                }
            }
        }
    }

    if policy_changed {
        if let Some(base_weights) = baseline_weights.as_ref() {
            let changed_repo_entries = changed_repo_overrides(&weights, base_weights)?;
            for entry in changed_repo_entries {
                if !has_declaration_for_repo_override_change(
                    &override_registry.declarations,
                    &entry.profile,
                    &entry.repo,
                    &entry.attribute,
                    entry.new_value,
                ) {
                    let msg = format!(
                        "Repo override change {}:{}:{} {}->{} is not captured in overrides.yml deviation records.",
                        entry.profile, entry.repo, entry.attribute, entry.old_value, entry.new_value
                    );
                    findings.push(classified_by_phase(
                        &override_registry.enforcement_phase,
                        "override-change-missing-deviation-record",
                        "policy",
                        "overrides",
                        &msg,
                    ));
                }
            }
        }
    }

    let scores_changed = if let Some(base_scores) = baseline_scores.as_ref() {
        canonical_hash(&scores) != canonical_hash(base_scores)
    } else {
        findings.push(Finding::warn(
            "baseline-scores-missing",
            "policy",
            "scores",
            "Baseline scores not provided; score-drift detection is limited.",
        ));
        false
    };

    let hard_count = findings
        .iter()
        .filter(|f| f.severity == "HARD_FAIL")
        .count();
    let warn_count = findings
        .iter()
        .filter(|f| f.severity == "SOFT_WARN")
        .count();

    let mut status = if hard_count > 0 {
        "FAIL"
    } else if warn_count > 0 {
        "WARN"
    } else {
        "PASS"
    }
    .to_string();

    if args.strict_warnings && warn_count > 0 && hard_count == 0 {
        status = "FAIL".to_string();
    }

    let summary = render_gate_summary(
        &status,
        &mode,
        &maturity,
        &findings,
        &scorecard,
        policy_changed,
        charter_changed,
        scores_changed,
    )?;
    let summary_path = args.summary_out.clone().unwrap_or_else(|| {
        args.scorecard
            .parent()
            .unwrap_or(Path::new("."))
            .join("gate-summary.md")
    });
    write_text(&summary_path, &summary)?;

    println!("gate-summary: {}", summary_path.display());
    println!("status: {status}");
    println!("policy-changed: {policy_changed}");
    println!("charter-changed: {charter_changed}");
    println!("scores-changed: {scores_changed}");
    println!("hard-findings: {hard_count}");
    println!("warn-findings: {warn_count}");

    if status == "FAIL" {
        bail!("gate failed");
    }

    Ok(())
}

#[derive(Clone, Debug)]
struct Finding {
    severity: String,
    code: String,
    subsystem: String,
    attribute: String,
    message: String,
}

impl Finding {
    fn hard(code: &str, subsystem: &str, attribute: &str, message: &str) -> Self {
        Self {
            severity: "HARD_FAIL".to_string(),
            code: code.to_string(),
            subsystem: subsystem.to_string(),
            attribute: attribute.to_string(),
            message: message.to_string(),
        }
    }

    fn warn(code: &str, subsystem: &str, attribute: &str, message: &str) -> Self {
        Self {
            severity: "SOFT_WARN".to_string(),
            code: code.to_string(),
            subsystem: subsystem.to_string(),
            attribute: attribute.to_string(),
            message: message.to_string(),
        }
    }
}

fn classified(mode: &str, code: &str, subsystem: &str, attribute: &str, message: &str) -> Finding {
    if mode == "local" {
        Finding::warn(code, subsystem, attribute, message)
    } else {
        Finding::hard(code, subsystem, attribute, message)
    }
}

fn normalize_scores(
    input: &Value,
    attribute_ids: &[String],
) -> Result<HashMap<String, SubsystemRec>> {
    let defaults = as_object(input.get("defaults"))
        .cloned()
        .ok_or_else(|| anyhow!("scores input missing 'defaults' mapping"))?;
    let defaults_attributes = as_object(defaults.get("attributes"))
        .cloned()
        .ok_or_else(|| anyhow!("scores input missing 'defaults.attributes' mapping"))?;

    let mut default_attr_map: HashMap<String, AttributeRec> = HashMap::new();

    for attr in attribute_ids {
        let base = defaults_attributes.get(attr);

        let score = base
            .and_then(|v| v.get("score"))
            .map(|v| value_f64(Some(v)))
            .unwrap_or(0.0);

        let target = base
            .and_then(|v| v.get("target_score"))
            .map(|v| value_f64(Some(v)))
            .unwrap_or(5.0);

        let criteria = base.and_then(|v| value_string(v.get("acceptance_criteria")));

        let evidence = base
            .map(|v| value_string_array(v.get("evidence")))
            .unwrap_or_default();

        let notes = base.and_then(|v| value_string(v.get("notes")));

        default_attr_map.insert(
            attr.clone(),
            AttributeRec {
                score: clamp(score, 0.0, 5.0),
                target_score: clamp(target, 0.0, 5.0),
                criteria: trim_opt(criteria),
                evidence: trim_vec(evidence),
                notes: trim_opt(notes),
            },
        );
    }

    let subsystems = as_object(input.get("subsystems"))
        .cloned()
        .ok_or_else(|| anyhow!("scores input has no subsystems"))?;

    let mut out: HashMap<String, SubsystemRec> = HashMap::new();

    for (subsystem, cfg) in sorted_object_iter(&subsystems) {
        let attributes_new = as_object(cfg.get("attributes")).cloned().ok_or_else(|| {
            anyhow!("scores subsystem '{subsystem}' missing 'attributes' mapping")
        })?;

        let mut attrs: HashMap<String, AttributeRec> = HashMap::new();

        for attr in attribute_ids {
            let mut rec = default_attr_map
                .get(attr)
                .cloned()
                .ok_or_else(|| anyhow!("missing default attr record"))?;

            if let Some(new_obj) = as_object(attributes_new.get(attr)) {
                if new_obj.contains_key("score") {
                    rec.score = clamp(value_f64(new_obj.get("score")), 0.0, 5.0);
                }
                if new_obj.contains_key("target_score") {
                    rec.target_score = clamp(value_f64(new_obj.get("target_score")), 0.0, 5.0);
                }
                if new_obj.contains_key("acceptance_criteria") {
                    rec.criteria = trim_opt(value_string(new_obj.get("acceptance_criteria")));
                }
                if new_obj.contains_key("evidence") {
                    rec.evidence = trim_vec(value_string_array(new_obj.get("evidence")));
                }
                if new_obj.contains_key("notes") {
                    rec.notes = trim_opt(value_string(new_obj.get("notes")));
                }
            }

            attrs.insert(attr.clone(), rec);
        }

        let owner = trim_opt(
            value_string(cfg.get("owner")).or_else(|| value_string(defaults.get("owner"))),
        );
        let last_updated = trim_opt(
            value_string(cfg.get("last_updated"))
                .or_else(|| value_string(input.get("meta").and_then(|m| m.get("updated_at")))),
        );
        let notes = trim_opt(value_string(cfg.get("notes")));
        let conflicts = value_array(cfg.get("conflicts"));

        out.insert(
            subsystem.to_string(),
            SubsystemRec {
                owner,
                last_updated,
                notes,
                attributes: attrs,
                conflicts,
            },
        );
    }

    Ok(out)
}

fn parse_attribute_catalog(weights: &Value) -> Result<(Vec<String>, HashMap<String, String>)> {
    let mut ids = Vec::new();
    let mut names = HashMap::new();

    let catalog = weights
        .get("attributes")
        .and_then(|v| v.as_array())
        .ok_or_else(|| anyhow!("weights registry missing 'attributes' list"))?;

    for entry in catalog {
        let Some(obj) = entry.as_object() else {
            continue;
        };
        let Some(id) = obj.get("id").and_then(|v| v.as_str()) else {
            continue;
        };
        let id = id.trim();
        if id.is_empty() {
            continue;
        }
        ids.push(id.to_string());
        let name = obj
            .get("name")
            .and_then(|v| v.as_str())
            .map(|s| s.trim())
            .filter(|s| !s.is_empty())
            .unwrap_or(id)
            .to_string();
        names.insert(id.to_string(), name);
    }

    if ids.is_empty() {
        bail!("weights registry has no valid attribute IDs");
    }

    Ok((ids, names))
}

fn parse_charter_spec(weights: &Value, attribute_ids: &[String]) -> Result<CharterSpec> {
    let charter = as_object(weights.get("charter"))
        .cloned()
        .ok_or_else(|| anyhow!("weights.yml missing required 'charter' section"))?;

    let reference_path = trim_opt(value_string(charter.get("ref")))
        .ok_or_else(|| anyhow!("weights.yml charter.ref is required"))?;
    let version = trim_opt(value_string(charter.get("version")));
    let tie_break_rule = trim_opt(value_string(charter.get("tie_break_rule")))
        .ok_or_else(|| anyhow!("weights.yml charter.tie_break_rule is required"))?;
    let tradeoff_rules = trim_vec(value_string_array(charter.get("tradeoff_rules")));
    if tradeoff_rules.is_empty() {
        bail!("weights.yml charter.tradeoff_rules must include at least one rule");
    }

    let priorities = charter
        .get("priority_chain")
        .and_then(|v| v.as_array())
        .ok_or_else(|| anyhow!("weights.yml charter.priority_chain is required"))?;
    let mut priority_chain: Vec<CharterPriority> = Vec::new();
    let mut priority_rank: HashMap<String, i64> = HashMap::new();
    for (idx, item) in priorities.iter().enumerate() {
        let obj = item
            .as_object()
            .ok_or_else(|| anyhow!("charter.priority_chain entries must be mappings"))?;
        let id = trim_opt(value_string(obj.get("id")))
            .ok_or_else(|| anyhow!("charter.priority_chain.id is required"))?;
        let name = trim_opt(value_string(obj.get("name"))).unwrap_or_else(|| id.clone());
        if priority_rank.contains_key(&id) {
            bail!("duplicate charter priority id: {id}");
        }
        priority_rank.insert(id.clone(), (idx as i64) + 1);
        priority_chain.push(CharterPriority { id, name });
    }
    if priority_chain.is_empty() {
        bail!("charter.priority_chain cannot be empty");
    }

    let mut required_references: HashMap<String, String> = HashMap::new();
    if let Some(refs) = as_object(charter.get("required_references")) {
        for (key, value) in refs {
            if let Some(path) = trim_opt(value_string(Some(value))) {
                required_references.insert(key.clone(), path);
            }
        }
    }
    if required_references.is_empty() {
        bail!("weights.yml charter.required_references must be provided");
    }

    let umbrella_map_raw = as_object(charter.get("attribute_umbrella_map"))
        .cloned()
        .ok_or_else(|| anyhow!("weights.yml charter.attribute_umbrella_map is required"))?;
    let mut attribute_umbrella_map: HashMap<String, String> = HashMap::new();
    for attr in attribute_ids {
        let umbrella = trim_opt(value_string(umbrella_map_raw.get(attr))).ok_or_else(|| {
            anyhow!("charter.attribute_umbrella_map missing mapping for attribute '{attr}'")
        })?;
        if !priority_rank.contains_key(&umbrella) {
            bail!("charter.attribute_umbrella_map.{attr} references unknown umbrella '{umbrella}'");
        }
        attribute_umbrella_map.insert(attr.clone(), umbrella);
    }

    Ok(CharterSpec {
        reference_path,
        version,
        priority_chain,
        tie_break_rule,
        tradeoff_rules,
        required_references,
        attribute_umbrella_map,
        priority_rank,
    })
}

fn parse_charter_doc(text: &str) -> Result<CharterDoc> {
    let lines: Vec<&str> = text.lines().collect();
    let priorities = extract_numbered_bold_section(&lines, "primary focus and priority chain");
    if priorities.is_empty() {
        bail!("CHARTER.md missing parseable numbered priority chain in section 1");
    }
    let tradeoff_rules = extract_numbered_bold_section(&lines, "trade-off rules");
    if tradeoff_rules.is_empty() {
        bail!("CHARTER.md missing parseable trade-off rule list in section 4");
    }
    Ok(CharterDoc {
        priority_chain: priorities,
        tradeoff_rules,
    })
}

fn extract_numbered_bold_section(lines: &[&str], heading_fragment: &str) -> Vec<String> {
    let target = normalize_text_key(heading_fragment);
    let mut in_section = false;
    let mut out: Vec<String> = Vec::new();
    for line in lines {
        let t = line.trim();
        if !in_section {
            if t.starts_with("## ") && normalize_text_key(t).contains(&target) {
                in_section = true;
            }
            continue;
        }
        if t.starts_with("## ") {
            break;
        }
        if let Some(item) = parse_numbered_bold_line(t) {
            out.push(item);
        }
    }
    out
}

fn parse_numbered_bold_line(line: &str) -> Option<String> {
    let trimmed = line.trim();
    let bytes = trimmed.as_bytes();
    let mut idx = 0usize;
    while idx < bytes.len() && bytes[idx].is_ascii_digit() {
        idx += 1;
    }
    if idx == 0 || idx >= bytes.len() || bytes[idx] != b'.' {
        return None;
    }
    let rest = trimmed[idx + 1..].trim_start();
    if !rest.starts_with("**") {
        return None;
    }
    let after_open = &rest[2..];
    let close = after_open.find("**")?;
    let value = after_open[..close].trim();
    if value.is_empty() {
        return None;
    }
    Some(value.to_string())
}

fn validate_charter_alignment(
    spec: &CharterSpec,
    doc: &CharterDoc,
    charter_path: &Path,
    attribute_ids: &[String],
    mut findings: Option<&mut Vec<Finding>>,
) -> Result<()> {
    let mut issues: Vec<(String, String, String)> = Vec::new();

    if !paths_equivalent(&spec.reference_path, &charter_path.to_string_lossy()) {
        issues.push((
            "charter-reference-mismatch".to_string(),
            "weights".to_string(),
            format!(
                "weights.yml charter.ref '{}' must match active charter path '{}'.",
                spec.reference_path,
                charter_path.display()
            ),
        ));
    }

    let spec_chain: Vec<String> = spec
        .priority_chain
        .iter()
        .map(|p| normalize_text_key(&p.name))
        .collect();
    let doc_chain: Vec<String> = doc
        .priority_chain
        .iter()
        .map(|p| normalize_text_key(p))
        .collect();
    if spec_chain != doc_chain {
        issues.push((
            "charter-priority-chain-mismatch".to_string(),
            "weights".to_string(),
            "weights.yml charter.priority_chain does not match CHARTER.md section 1.".to_string(),
        ));
    }

    let spec_tradeoff: Vec<String> = spec
        .tradeoff_rules
        .iter()
        .map(|r| normalize_text_key(r))
        .collect();
    let doc_tradeoff: Vec<String> = doc
        .tradeoff_rules
        .iter()
        .map(|r| normalize_text_key(r))
        .collect();
    if spec_tradeoff != doc_tradeoff {
        issues.push((
            "charter-tradeoff-rules-mismatch".to_string(),
            "weights".to_string(),
            "weights.yml charter.tradeoff_rules does not match CHARTER.md section 4.".to_string(),
        ));
    }

    for (key, path) in &spec.required_references {
        if !Path::new(path).exists() {
            issues.push((
                "charter-required-reference-missing".to_string(),
                "weights".to_string(),
                format!(
                    "weights.yml charter.required_references.{} points to missing path '{}'.",
                    key, path
                ),
            ));
        }
    }

    for attr in attribute_ids {
        if !spec.attribute_umbrella_map.contains_key(attr) {
            issues.push((
                "charter-umbrella-map-missing".to_string(),
                "weights".to_string(),
                format!("charter.attribute_umbrella_map is missing '{attr}'."),
            ));
        }
    }

    if issues.is_empty() {
        return Ok(());
    }

    if let Some(list) = findings.as_deref_mut() {
        for (code, attribute, message) in issues {
            list.push(Finding::hard(&code, "policy", &attribute, &message));
        }
        return Ok(());
    }

    let summary = issues
        .into_iter()
        .map(|(_, _, msg)| msg)
        .collect::<Vec<_>>()
        .join("; ");
    bail!("{summary}");
}

fn resolve_profile(
    weights: &Value,
    explicit: Option<&str>,
    run_mode: &str,
    maturity: &str,
) -> Result<String> {
    let profiles = as_object(weights.get("profiles"))
        .cloned()
        .unwrap_or_default();

    if let Some(pid) = explicit {
        if !profiles.contains_key(pid) {
            bail!("unknown profile: {pid}");
        }
        return Ok(pid.to_string());
    }

    let selection = as_object(weights.get("selection_defaults"))
        .cloned()
        .unwrap_or_default();
    if let Some(run_defaults) = as_object(selection.get("run_mode")) {
        if let Some(found) = value_string(run_defaults.get(run_mode)) {
            return Ok(found);
        }
    }

    if let Some(maturity_defaults) = as_object(selection.get("maturity")) {
        if let Some(found) = value_string(maturity_defaults.get(maturity)) {
            return Ok(found);
        }
    }

    if let Some(fallback) = value_string(selection.get("fallback_profile")) {
        if profiles.contains_key(&fallback) {
            return Ok(fallback);
        }
    }

    if profiles.contains_key("global-default") {
        return Ok("global-default".to_string());
    }

    let mut keys: Vec<String> = profiles.keys().cloned().collect();
    keys.sort();
    if let Some(first) = keys.first() {
        return Ok(first.clone());
    }

    bail!("weights registry has no profiles")
}

fn resolve_profile_policy(weights: &Value, profile_id: &str) -> Result<Policy> {
    let profiles = as_object(weights.get("profiles"))
        .cloned()
        .unwrap_or_default();
    if !profiles.contains_key(profile_id) {
        bail!("profile not found: {profile_id}");
    }

    fn resolve_rec(
        profiles: &Map<String, Value>,
        current: &str,
        visiting: &mut HashSet<String>,
    ) -> Result<Policy> {
        if visiting.contains(current) {
            bail!("profile inheritance cycle detected at: {current}");
        }
        visiting.insert(current.to_string());

        let profile = as_object(profiles.get(current))
            .cloned()
            .ok_or_else(|| anyhow!("profile not found: {current}"))?;

        let own = normalize_profile_policy(&profile)?;

        let merged = if let Some(base_id) = value_string(profile.get("base")) {
            if !profiles.contains_key(&base_id) {
                bail!("profile '{current}' references unknown base '{base_id}'");
            }
            let inherited = resolve_rec(profiles, &base_id, visiting)?;
            merge_policy(inherited, own)
        } else {
            own
        };

        visiting.remove(current);
        Ok(merged)
    }

    let mut visiting = HashSet::new();
    resolve_rec(&profiles, profile_id, &mut visiting)
}

fn normalize_profile_policy(profile: &Map<String, Value>) -> Result<Policy> {
    let mut policy = Policy::default();
    let weights = as_object(profile.get("weights"))
        .cloned()
        .unwrap_or_default();
    if weights.is_empty() {
        return Ok(policy);
    }

    let has_layered = ["global", "run_mode", "subsystem", "maturity", "repo"]
        .iter()
        .any(|k| weights.contains_key(*k));

    if has_layered {
        policy.global = map_string_i64(as_object(weights.get("global")));
        policy.run_mode = map_string_map_i64(as_object(weights.get("run_mode")));
        policy.subsystem = map_string_map_i64(as_object(weights.get("subsystem")));
        policy.maturity = map_string_map_i64(as_object(weights.get("maturity")));
        policy.repo = map_string_map_i64(as_object(weights.get("repo")));
        Ok(policy)
    } else {
        bail!("profile.weights must use layered format: global/run_mode/subsystem/maturity/repo");
    }
}

fn merge_policy(mut base: Policy, override_policy: Policy) -> Policy {
    for (k, v) in override_policy.global {
        base.global.insert(k, v);
    }

    merge_level(&mut base.run_mode, override_policy.run_mode);
    merge_level(&mut base.subsystem, override_policy.subsystem);
    merge_level(&mut base.maturity, override_policy.maturity);
    merge_level(&mut base.repo, override_policy.repo);

    base
}

fn merge_level(
    target: &mut HashMap<String, HashMap<String, i64>>,
    source: HashMap<String, HashMap<String, i64>>,
) {
    for (scope, attrs) in source {
        let entry = target.entry(scope).or_default();
        for (attr, val) in attrs {
            entry.insert(attr, val);
        }
    }
}

fn build_effective_weights(
    policy: &Policy,
    attribute_ids: &[String],
    run_mode: &str,
    subsystem: &str,
    maturity: &str,
    repo: &str,
) -> Result<(HashMap<String, i64>, Vec<String>)> {
    let mut merged = policy.global.clone();
    let mut applied = vec!["global".to_string()];

    if let Some(layer) = policy.run_mode.get(run_mode) {
        for (k, v) in layer {
            merged.insert(k.clone(), *v);
        }
        applied.push(format!("run-mode:{run_mode}"));
    }

    if let Some(layer) = policy.subsystem.get(subsystem) {
        for (k, v) in layer {
            merged.insert(k.clone(), *v);
        }
        applied.push(format!("subsystem:{subsystem}"));
    }

    if let Some(layer) = policy.maturity.get(maturity) {
        for (k, v) in layer {
            merged.insert(k.clone(), *v);
        }
        applied.push(format!("maturity:{maturity}"));
    }

    if let Some(layer) = policy.repo.get(repo) {
        for (k, v) in layer {
            merged.insert(k.clone(), *v);
        }
        applied.push(format!("repo:{repo}"));
    }

    for attr in attribute_ids {
        let Some(weight) = merged.get(attr) else {
            bail!("effective weights for subsystem '{subsystem}': missing weight for '{attr}'");
        };
        if *weight < 1 || *weight > 5 {
            bail!("effective weights for subsystem '{subsystem}': '{attr}' out of range [1,5]");
        }
    }

    Ok((merged, applied))
}

fn build_effective_weights_without_repo(
    policy: &Policy,
    attribute_ids: &[String],
    run_mode: &str,
    subsystem: &str,
    maturity: &str,
) -> Result<HashMap<String, i64>> {
    let mut merged = policy.global.clone();

    if let Some(layer) = policy.run_mode.get(run_mode) {
        for (k, v) in layer {
            merged.insert(k.clone(), *v);
        }
    }
    if let Some(layer) = policy.subsystem.get(subsystem) {
        for (k, v) in layer {
            merged.insert(k.clone(), *v);
        }
    }
    if let Some(layer) = policy.maturity.get(maturity) {
        for (k, v) in layer {
            merged.insert(k.clone(), *v);
        }
    }

    for attr in attribute_ids {
        let Some(weight) = merged.get(attr) else {
            bail!(
                "effective weights (without repo) for subsystem '{subsystem}': missing weight for '{attr}'"
            );
        };
        if *weight < 1 || *weight > 5 {
            bail!(
                "effective weights (without repo) for subsystem '{subsystem}': '{attr}' out of range [1,5]"
            );
        }
    }

    Ok(merged)
}

fn parse_subsystem_class_policy(input: Option<&Value>) -> Result<SubsystemClassPolicy> {
    let mut classes: HashMap<String, ClassRule> = HashMap::new();
    classes.insert(
        "control-plane".to_string(),
        ClassRule {
            require_deviation_record: true,
            require_adr: true,
            require_changelog: true,
            min_reviewers: 2,
            large_change_threshold: 1,
            require_adr_for_large_change: true,
            warn_missing_expiry_without_permanent: true,
        },
    );
    classes.insert(
        "productivity".to_string(),
        ClassRule {
            require_deviation_record: false,
            require_adr: false,
            require_changelog: false,
            min_reviewers: 1,
            large_change_threshold: 2,
            require_adr_for_large_change: true,
            warn_missing_expiry_without_permanent: true,
        },
    );

    let mut subsystem_class: HashMap<String, String> = HashMap::new();
    subsystem_class.insert("runtime".to_string(), "control-plane".to_string());
    subsystem_class.insert("assurance".to_string(), "control-plane".to_string());
    subsystem_class.insert("continuity".to_string(), "control-plane".to_string());
    subsystem_class.insert("agency".to_string(), "control-plane".to_string());
    subsystem_class.insert("capabilities".to_string(), "productivity".to_string());
    subsystem_class.insert("orchestration".to_string(), "productivity".to_string());
    subsystem_class.insert("cognition".to_string(), "productivity".to_string());
    subsystem_class.insert("scaffolding".to_string(), "productivity".to_string());
    subsystem_class.insert("output".to_string(), "productivity".to_string());
    subsystem_class.insert("ideation".to_string(), "productivity".to_string());

    let mut allowed_reason_categories: HashSet<String> = [
        "regulated",
        "incident-response",
        "experimental",
        "performance",
        "security",
        "reliability",
        "portability",
        "developer-experience",
        "compatibility",
        "governance",
    ]
    .iter()
    .map(|s| s.to_string())
    .collect();
    let mut enforcement_phase = "phase0".to_string();

    if let Some(raw) = input {
        let root = as_object(Some(raw)).cloned().unwrap_or_default();
        if let Some(meta) = as_object(root.get("meta")) {
            if let Some(phase) = value_string(meta.get("enforcement_phase")) {
                if !phase.trim().is_empty() {
                    enforcement_phase = phase.trim().to_ascii_lowercase();
                }
            }
        }

        let provided_reasons = value_string_array(root.get("allowed_reason_categories"));
        if !provided_reasons.is_empty() {
            allowed_reason_categories = provided_reasons
                .into_iter()
                .map(|v| v.to_ascii_lowercase())
                .collect();
        }

        if let Some(classes_raw) = as_object(root.get("classes")) {
            for (name, cfg) in classes_raw {
                let strict = as_object(cfg.get("strictness"))
                    .cloned()
                    .unwrap_or_default();
                let existing = classes.get(name).cloned().unwrap_or(ClassRule {
                    require_deviation_record: false,
                    require_adr: false,
                    require_changelog: false,
                    min_reviewers: 1,
                    large_change_threshold: 2,
                    require_adr_for_large_change: true,
                    warn_missing_expiry_without_permanent: true,
                });

                let updated = ClassRule {
                    require_deviation_record: strict
                        .get("require_deviation_record")
                        .and_then(|v| v.as_bool())
                        .unwrap_or(existing.require_deviation_record),
                    require_adr: strict
                        .get("require_adr")
                        .and_then(|v| v.as_bool())
                        .unwrap_or(existing.require_adr),
                    require_changelog: strict
                        .get("require_changelog")
                        .and_then(|v| v.as_bool())
                        .unwrap_or(existing.require_changelog),
                    min_reviewers: strict
                        .get("min_reviewers")
                        .map(|v| value_i64(Some(v)))
                        .unwrap_or(existing.min_reviewers)
                        .max(1),
                    large_change_threshold: strict
                        .get("large_change_threshold")
                        .map(|v| value_i64(Some(v)))
                        .unwrap_or(existing.large_change_threshold)
                        .max(1),
                    require_adr_for_large_change: strict
                        .get("require_adr_for_large_change")
                        .and_then(|v| v.as_bool())
                        .unwrap_or(existing.require_adr_for_large_change),
                    warn_missing_expiry_without_permanent: strict
                        .get("warn_missing_expiry_without_permanent")
                        .and_then(|v| v.as_bool())
                        .unwrap_or(existing.warn_missing_expiry_without_permanent),
                };
                classes.insert(name.clone(), updated);
            }
        }

        if let Some(subsystems_raw) = as_object(root.get("subsystems")) {
            for (subsystem, class_name) in subsystems_raw {
                if let Some(c) = value_string(Some(class_name)) {
                    subsystem_class.insert(subsystem.clone(), c);
                }
            }
        }
    }

    Ok(SubsystemClassPolicy {
        enforcement_phase,
        allowed_reason_categories,
        classes,
        subsystem_class,
    })
}

fn parse_override_registry(
    input: Option<&Value>,
    class_policy: &SubsystemClassPolicy,
) -> Result<OverrideRegistry> {
    let mut enforcement_phase = class_policy.enforcement_phase.clone();
    let mut declarations = Vec::new();

    let Some(raw) = input else {
        return Ok(OverrideRegistry {
            enforcement_phase,
            declarations,
        });
    };
    let root = as_object(Some(raw)).cloned().unwrap_or_default();
    if let Some(meta) = as_object(root.get("meta")) {
        if let Some(phase) = value_string(meta.get("enforcement_phase")) {
            if !phase.trim().is_empty() {
                enforcement_phase = phase.trim().to_ascii_lowercase();
            }
        }
    }

    let items = value_array(root.get("deviations"));
    for item in items {
        let Some(obj) = item.as_object() else {
            continue;
        };

        let repo = value_string(obj.get("repo")).unwrap_or_default();
        let subsystem = value_string(obj.get("subsystem")).unwrap_or_default();
        let attribute = value_string(obj.get("attribute")).unwrap_or_default();
        if repo.trim().is_empty() || subsystem.trim().is_empty() || attribute.trim().is_empty() {
            continue;
        }

        let decl = OverrideDecl {
            id: value_string(obj.get("id")).unwrap_or_default(),
            repo: repo.trim().to_string(),
            profile: trim_opt(value_string(obj.get("profile"))),
            subsystem: subsystem.trim().to_string(),
            attribute: attribute.trim().to_string(),
            old_value: value_i64(obj.get("old_value")),
            new_value: value_i64(obj.get("new_value")),
            reason_category: trim_opt(value_string(obj.get("reason_category"))),
            reason: trim_opt(value_string(obj.get("reason"))),
            adr: trim_opt(value_string(obj.get("adr"))),
            changelog_version: trim_opt(value_string(obj.get("changelog_version"))),
            owner: trim_opt(value_string(obj.get("owner"))),
            created_at: trim_opt(value_string(obj.get("created_at"))),
            temporary: obj
                .get("temporary")
                .and_then(|v| v.as_bool())
                .unwrap_or(false),
            expires_at: trim_opt(value_string(obj.get("expires_at"))),
            permanent_justification: trim_opt(value_string(obj.get("permanent_justification"))),
            approved_by: trim_vec(value_string_array(obj.get("approved_by"))),
            evidence: trim_vec(value_string_array(obj.get("evidence"))),
        };
        declarations.push(decl);
    }

    Ok(OverrideRegistry {
        enforcement_phase,
        declarations,
    })
}

#[allow(clippy::too_many_arguments)]
fn compute_policy_deviations_for_subsystem(
    weights: &Value,
    charter_spec: Option<&CharterSpec>,
    class_policy: &SubsystemClassPolicy,
    override_registry: &OverrideRegistry,
    profile: &str,
    repo: &str,
    subsystem: &str,
    baseline_without_repo: &HashMap<String, i64>,
    effective_with_repo: &HashMap<String, i64>,
    repo_layer: Option<&HashMap<String, i64>>,
    subsystem_layer: Option<&HashMap<String, i64>>,
) -> Vec<Value> {
    let repo_layer = repo_layer.cloned().unwrap_or_default();
    if repo_layer.is_empty() {
        return Vec::new();
    }

    let subsystem_layer = subsystem_layer.cloned().unwrap_or_default();
    let class_name = class_policy
        .subsystem_class
        .get(subsystem)
        .cloned()
        .unwrap_or_else(|| "productivity".to_string());
    let class_rule = class_policy
        .classes
        .get(&class_name)
        .cloned()
        .unwrap_or(ClassRule {
            require_deviation_record: false,
            require_adr: false,
            require_changelog: false,
            min_reviewers: 1,
            large_change_threshold: 2,
            require_adr_for_large_change: true,
            warn_missing_expiry_without_permanent: true,
        });

    let today = chrono_like_now().iso[..10].to_string();
    let mut attrs: Vec<String> = repo_layer.keys().cloned().collect();
    attrs.sort();

    let mut out: Vec<Value> = Vec::new();
    for attr in attrs {
        if !subsystem_layer.contains_key(&attr) {
            continue;
        }

        let old_value = *baseline_without_repo.get(&attr).unwrap_or(&0);
        let new_value = *effective_with_repo.get(&attr).unwrap_or(&0);
        if old_value == new_value {
            continue;
        }
        let umbrella = charter_spec
            .and_then(|c| c.attribute_umbrella_map.get(&attr))
            .cloned();
        let umbrella_rank = umbrella
            .as_ref()
            .and_then(|o| charter_spec.and_then(|c| c.priority_rank.get(o)))
            .copied();
        let umbrella_priority_deviation = matches!(umbrella_rank, Some(1)) && new_value < old_value;

        let decl = find_matching_override_decl(
            &override_registry.declarations,
            profile,
            repo,
            subsystem,
            &attr,
            old_value,
            new_value,
        );

        let declared = decl.is_some();
        let adr_present = decl
            .as_ref()
            .and_then(|d| d.adr.as_deref())
            .map(|v| adr_is_valid(Some(v)))
            .unwrap_or(false);
        let changelog_present = decl
            .as_ref()
            .and_then(|d| d.changelog_version.clone())
            .and_then(|v| find_changelog_entry(weights, &v).map(|_| v))
            .is_some();
        let reason_category = decl
            .as_ref()
            .and_then(|d| d.reason_category.clone())
            .map(|v| v.to_ascii_lowercase());
        let reason_allowed = reason_category
            .as_ref()
            .map(|r| class_policy.allowed_reason_categories.contains(r))
            .unwrap_or(false);
        let owner_present = decl
            .as_ref()
            .and_then(|d| d.owner.as_deref())
            .map(|s| !s.trim().is_empty())
            .unwrap_or(false);
        let reviewer_count = decl
            .as_ref()
            .map(|d| d.approved_by.len() as i64)
            .unwrap_or(0);
        let temporary = decl.as_ref().map(|d| d.temporary).unwrap_or(false);
        let expires_at = decl.as_ref().and_then(|d| d.expires_at.clone());
        let permanent_justified = decl
            .as_ref()
            .and_then(|d| d.permanent_justification.as_deref())
            .map(|s| !s.trim().is_empty())
            .unwrap_or(false);
        let expired = expires_at
            .as_ref()
            .map(|d| is_date_expired(d, &today))
            .unwrap_or(false);
        let missing_expiry_without_permanent = class_rule.warn_missing_expiry_without_permanent
            && expires_at.is_none()
            && !permanent_justified;
        let delta_abs = (new_value - old_value).abs();
        let large_change = delta_abs >= class_rule.large_change_threshold.max(1);

        let mut hard_issues: Vec<String> = Vec::new();
        let mut warn_issues: Vec<String> = Vec::new();

        if class_rule.require_deviation_record && !declared {
            hard_issues.push("missing_deviation_record".to_string());
        }
        if declared {
            if class_rule.require_adr && !adr_present {
                hard_issues.push("missing_adr".to_string());
            }
            if class_rule.require_changelog && !changelog_present {
                hard_issues.push("missing_changelog_reference".to_string());
            }
            if class_rule.require_deviation_record && !reason_allowed {
                hard_issues.push("reason_category_not_permitted".to_string());
            }
            if class_rule.require_deviation_record && !owner_present {
                hard_issues.push("missing_owner".to_string());
            }
            if reviewer_count < class_rule.min_reviewers {
                hard_issues.push("insufficient_reviewers".to_string());
            }
            if expired {
                hard_issues.push("expired_override".to_string());
            }
            if class_rule.require_adr_for_large_change && large_change && !adr_present {
                hard_issues.push("large_change_missing_adr".to_string());
            }
            if missing_expiry_without_permanent {
                warn_issues.push("missing_expiry_without_permanent_justification".to_string());
            }
        }

        let policy_permitted = hard_issues.is_empty();
        let evidence = decl
            .as_ref()
            .map(|d| d.evidence.clone())
            .unwrap_or_default();

        out.push(Value::Object({
            let mut m = Map::new();
            m.insert("profile".to_string(), Value::String(profile.to_string()));
            m.insert("repo".to_string(), Value::String(repo.to_string()));
            m.insert(
                "subsystem".to_string(),
                Value::String(subsystem.to_string()),
            );
            m.insert(
                "subsystem_class".to_string(),
                Value::String(class_name.clone()),
            );
            m.insert("attribute".to_string(), Value::String(attr.clone()));
            m.insert(
                "umbrella".to_string(),
                umbrella
                    .as_ref()
                    .cloned()
                    .map(Value::String)
                    .unwrap_or(Value::Null),
            );
            m.insert(
                "umbrella_rank".to_string(),
                umbrella_rank
                    .map(|r| Value::Number(Number::from(r)))
                    .unwrap_or(Value::Null),
            );
            m.insert(
                "umbrella_priority_deviation".to_string(),
                Value::Bool(umbrella_priority_deviation),
            );
            m.insert(
                "old_value".to_string(),
                Value::Number(Number::from(old_value)),
            );
            m.insert(
                "new_value".to_string(),
                Value::Number(Number::from(new_value)),
            );
            m.insert(
                "delta".to_string(),
                Value::Number(Number::from(new_value - old_value)),
            );
            m.insert("declared".to_string(), Value::Bool(declared));
            m.insert(
                "declaration_id".to_string(),
                decl.as_ref()
                    .map(|d| Value::String(d.id.clone()))
                    .unwrap_or(Value::Null),
            );
            m.insert(
                "reason_category".to_string(),
                reason_category.map(Value::String).unwrap_or(Value::Null),
            );
            m.insert(
                "reason".to_string(),
                decl.as_ref()
                    .and_then(|d| d.reason.clone())
                    .map(Value::String)
                    .unwrap_or(Value::Null),
            );
            m.insert("reason_allowed".to_string(), Value::Bool(reason_allowed));
            m.insert(
                "adr".to_string(),
                decl.as_ref()
                    .and_then(|d| d.adr.clone())
                    .map(Value::String)
                    .unwrap_or(Value::Null),
            );
            m.insert("adr_present".to_string(), Value::Bool(adr_present));
            m.insert(
                "changelog_version".to_string(),
                decl.as_ref()
                    .and_then(|d| d.changelog_version.clone())
                    .map(Value::String)
                    .unwrap_or(Value::Null),
            );
            m.insert(
                "changelog_present".to_string(),
                Value::Bool(changelog_present),
            );
            m.insert(
                "owner".to_string(),
                decl.as_ref()
                    .and_then(|d| d.owner.clone())
                    .map(Value::String)
                    .unwrap_or(Value::Null),
            );
            m.insert("owner_present".to_string(), Value::Bool(owner_present));
            m.insert(
                "created_at".to_string(),
                decl.as_ref()
                    .and_then(|d| d.created_at.clone())
                    .map(Value::String)
                    .unwrap_or(Value::Null),
            );
            m.insert("temporary".to_string(), Value::Bool(temporary));
            m.insert(
                "expires_at".to_string(),
                expires_at.clone().map(Value::String).unwrap_or(Value::Null),
            );
            m.insert(
                "permanent_justification".to_string(),
                decl.as_ref()
                    .and_then(|d| d.permanent_justification.clone())
                    .map(Value::String)
                    .unwrap_or(Value::Null),
            );
            m.insert("expired".to_string(), Value::Bool(expired));
            m.insert(
                "missing_expiry_without_permanent".to_string(),
                Value::Bool(missing_expiry_without_permanent),
            );
            m.insert(
                "reviewer_count".to_string(),
                Value::Number(Number::from(reviewer_count)),
            );
            m.insert(
                "required_reviewers".to_string(),
                Value::Number(Number::from(class_rule.min_reviewers.max(1))),
            );
            m.insert("large_change".to_string(), Value::Bool(large_change));
            m.insert(
                "large_change_threshold".to_string(),
                Value::Number(Number::from(class_rule.large_change_threshold.max(1))),
            );
            m.insert(
                "policy_permitted".to_string(),
                Value::Bool(policy_permitted),
            );
            m.insert(
                "evidence".to_string(),
                Value::Array(evidence.into_iter().map(Value::String).collect()),
            );
            m.insert(
                "hard_issues".to_string(),
                Value::Array(hard_issues.into_iter().map(Value::String).collect()),
            );
            m.insert(
                "warn_issues".to_string(),
                Value::Array(warn_issues.into_iter().map(Value::String).collect()),
            );
            m
        }));
    }

    out
}

fn find_matching_override_decl<'a>(
    decls: &'a [OverrideDecl],
    profile: &str,
    repo: &str,
    subsystem: &str,
    attribute: &str,
    old_value: i64,
    new_value: i64,
) -> Option<&'a OverrideDecl> {
    let mut best_exact: Option<&OverrideDecl> = None;
    let mut best_relaxed: Option<&OverrideDecl> = None;

    for decl in decls {
        if decl.repo != repo
            || decl.subsystem != subsystem
            || decl.attribute != attribute
            || decl.new_value != new_value
        {
            continue;
        }

        if let Some(p) = decl.profile.as_deref() {
            if p != profile {
                continue;
            }
        }

        if decl.old_value == old_value {
            best_exact = Some(decl);
            break;
        }
        if best_relaxed.is_none() {
            best_relaxed = Some(decl);
        }
    }

    best_exact.or(best_relaxed)
}

fn apply_deviation_findings(
    findings: &mut Vec<Finding>,
    deviations: &[Value],
    enforcement_phase: &str,
    mode: &str,
) {
    for dev in deviations {
        let subsystem = value_string(dev.get("subsystem")).unwrap_or_default();
        let attribute = value_string(dev.get("attribute")).unwrap_or_default();
        let class_name = value_string(dev.get("subsystem_class")).unwrap_or_default();
        let declared = dev
            .get("declared")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);
        let adr_present = dev
            .get("adr_present")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);
        let changelog_present = dev
            .get("changelog_present")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);
        let permitted = dev
            .get("policy_permitted")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);
        let expired = dev
            .get("expired")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);
        let large_change = dev
            .get("large_change")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);
        let missing_expiry = dev
            .get("missing_expiry_without_permanent")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);
        let umbrella_priority_deviation = dev
            .get("umbrella_priority_deviation")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);

        if umbrella_priority_deviation && (!declared || !adr_present) {
            findings.push(Finding::warn(
                "umbrella-priority-deviation-unjustified",
                &subsystem,
                &attribute,
                "Repo override reduces a top-priority umbrella without explicit declaration + ADR.",
            ));
        }

        if class_name == "control-plane" {
            if !declared {
                findings.push(classified_by_phase(
                    enforcement_phase,
                    "control-plane-override-missing-declaration",
                    &subsystem,
                    &attribute,
                    "Control-plane repo override requires explicit deviation declaration.",
                ));
            }
            if declared && !adr_present {
                findings.push(classified_by_phase(
                    enforcement_phase,
                    "control-plane-override-missing-adr",
                    &subsystem,
                    &attribute,
                    "Control-plane repo override requires ADR reference.",
                ));
            }
            if declared && !changelog_present {
                findings.push(classified_by_phase(
                    enforcement_phase,
                    "control-plane-override-missing-changelog",
                    &subsystem,
                    &attribute,
                    "Control-plane repo override requires changelog-linked declaration.",
                ));
            }
            if declared && !permitted {
                findings.push(classified_by_phase(
                    enforcement_phase,
                    "control-plane-override-class-violation",
                    &subsystem,
                    &attribute,
                    "Control-plane repo override violates strictness rules.",
                ));
            }
            if declared && expired {
                findings.push(classified_by_phase(
                    enforcement_phase,
                    "control-plane-override-expired",
                    &subsystem,
                    &attribute,
                    "Control-plane override is expired and must be renewed or removed.",
                ));
            }
            if declared && missing_expiry {
                findings.push(Finding::warn(
                    "control-plane-override-missing-expiry",
                    &subsystem,
                    &attribute,
                    "Control-plane override has no expires_at and no permanent justification.",
                ));
            }
            continue;
        }

        if !declared {
            findings.push(Finding::warn(
                "productivity-override-missing-declaration",
                &subsystem,
                &attribute,
                "Productivity repo override should declare policy deviation.",
            ));
        }
        if large_change && !adr_present {
            findings.push(classified_by_phase(
                enforcement_phase,
                "productivity-override-large-change-missing-adr",
                &subsystem,
                &attribute,
                "Large productivity override requires ADR.",
            ));
        }
        if declared && missing_expiry {
            findings.push(Finding::warn(
                "productivity-override-missing-expiry",
                &subsystem,
                &attribute,
                "Productivity override has no expires_at and no permanent justification.",
            ));
        }
        if mode == "local" && !declared {
            findings.push(Finding::warn(
                "productivity-override-local-missing-declaration",
                &subsystem,
                &attribute,
                "Local run: declaration missing for productivity override.",
            ));
        }
    }
}

fn classified_by_phase(
    enforcement_phase: &str,
    code: &str,
    subsystem: &str,
    attribute: &str,
    message: &str,
) -> Finding {
    if normalize_phase(enforcement_phase) == "phase0" {
        Finding::warn(code, subsystem, attribute, message)
    } else {
        Finding::hard(code, subsystem, attribute, message)
    }
}

fn normalize_phase(phase: &str) -> String {
    let p = phase.trim().to_ascii_lowercase();
    match p.as_str() {
        "phase0" | "phase-0" | "0" => "phase0".to_string(),
        "phase1" | "phase-1" | "1" => "phase1".to_string(),
        "phase2" | "phase-2" | "2" => "phase2".to_string(),
        _ => "phase0".to_string(),
    }
}

#[derive(Clone, Debug)]
struct RepoOverrideChange {
    profile: String,
    repo: String,
    attribute: String,
    old_value: i64,
    new_value: i64,
}

fn changed_repo_overrides(current: &Value, baseline: &Value) -> Result<Vec<RepoOverrideChange>> {
    let current_map = collect_repo_override_entries(current)?;
    let baseline_map = collect_repo_override_entries(baseline)?;

    let mut keys: HashSet<String> = HashSet::new();
    keys.extend(current_map.keys().cloned());
    keys.extend(baseline_map.keys().cloned());

    let mut out = Vec::new();
    let mut sorted_keys: Vec<String> = keys.into_iter().collect();
    sorted_keys.sort();
    for key in sorted_keys {
        let curr = current_map.get(&key).cloned();
        let base = baseline_map.get(&key).cloned();
        if curr == base {
            continue;
        }
        let Some(new_value) = curr else {
            continue;
        };
        let old_value = base.unwrap_or(new_value);
        let parts: Vec<&str> = key.split('|').collect();
        if parts.len() != 3 {
            continue;
        }
        out.push(RepoOverrideChange {
            profile: parts[0].to_string(),
            repo: parts[1].to_string(),
            attribute: parts[2].to_string(),
            old_value,
            new_value,
        });
    }

    Ok(out)
}

fn collect_repo_override_entries(weights: &Value) -> Result<HashMap<String, i64>> {
    let profiles = as_object(weights.get("profiles"))
        .cloned()
        .unwrap_or_default();
    let mut out = HashMap::new();
    let mut profile_ids: Vec<String> = profiles.keys().cloned().collect();
    profile_ids.sort();
    for pid in profile_ids {
        let policy = resolve_profile_policy(weights, &pid)?;
        for (repo, attrs) in policy.repo {
            for (attr, value) in attrs {
                out.insert(format!("{pid}|{repo}|{attr}"), value);
            }
        }
    }
    Ok(out)
}

fn has_declaration_for_repo_override_change(
    decls: &[OverrideDecl],
    profile: &str,
    repo: &str,
    attribute: &str,
    new_value: i64,
) -> bool {
    decls.iter().any(|d| {
        if d.repo != repo || d.attribute != attribute || d.new_value != new_value {
            return false;
        }
        match d.profile.as_deref() {
            Some(p) => p == profile,
            None => true,
        }
    })
}

fn is_date_expired(date_text: &str, today: &str) -> bool {
    let d = date_text.trim();
    if d.len() != 10 {
        return false;
    }
    d < today
}

fn extract_policy_fingerprint(weights: &Value) -> Result<String> {
    let profiles = as_object(weights.get("profiles"))
        .cloned()
        .unwrap_or_default();
    let mut profile_ids: Vec<String> = profiles.keys().cloned().collect();
    profile_ids.sort();

    let mut tokens: Vec<String> = Vec::new();

    for pid in profile_ids {
        let policy = resolve_profile_policy(weights, &pid)?;

        let mut global_attrs: Vec<String> = policy.global.keys().cloned().collect();
        global_attrs.sort();
        for attr in global_attrs {
            if let Some(val) = policy.global.get(&attr) {
                tokens.push(format!("{pid}|global|{attr}|{val}"));
            }
        }

        collect_policy_tokens(&mut tokens, &pid, "run_mode", &policy.run_mode);
        collect_policy_tokens(&mut tokens, &pid, "subsystem", &policy.subsystem);
        collect_policy_tokens(&mut tokens, &pid, "maturity", &policy.maturity);
        collect_policy_tokens(&mut tokens, &pid, "repo", &policy.repo);
    }

    Ok(sha256_hex(tokens.join("\n").as_bytes()))
}

fn collect_policy_tokens(
    tokens: &mut Vec<String>,
    profile: &str,
    level: &str,
    map: &HashMap<String, HashMap<String, i64>>,
) {
    let mut keys: Vec<String> = map.keys().cloned().collect();
    keys.sort();
    for key in keys {
        if let Some(attrs) = map.get(&key) {
            let mut attr_ids: Vec<String> = attrs.keys().cloned().collect();
            attr_ids.sort();
            for attr in attr_ids {
                if let Some(val) = attrs.get(&attr) {
                    tokens.push(format!("{profile}|{level}|{key}|{attr}|{val}"));
                }
            }
        }
    }
}

fn detect_tie_break_resolutions(items: &[Value]) -> Vec<Value> {
    let mut out: Vec<Value> = Vec::new();
    if items.len() < 2 {
        return out;
    }

    for idx in 1..items.len() {
        let winner = &items[idx - 1];
        let loser = &items[idx];
        if !is_priority_tie(winner, loser) {
            continue;
        }
        let winner_rank = value_i64(winner.get("umbrella_rank"));
        let loser_rank = value_i64(loser.get("umbrella_rank"));
        if winner_rank <= 0 || loser_rank <= 0 {
            continue;
        }
        if winner_rank < loser_rank {
            out.push(Value::Object({
                let mut m = Map::new();
                m.insert(
                    "priority".to_string(),
                    num(value_f64(winner.get("priority"))),
                );
                m.insert(
                    "winner".to_string(),
                    Value::String(format!(
                        "{}:{}",
                        value_string(winner.get("subsystem")).unwrap_or_default(),
                        value_string(winner.get("attribute")).unwrap_or_default()
                    )),
                );
                m.insert(
                    "loser".to_string(),
                    Value::String(format!(
                        "{}:{}",
                        value_string(loser.get("subsystem")).unwrap_or_default(),
                        value_string(loser.get("attribute")).unwrap_or_default()
                    )),
                );
                m.insert(
                    "winner_umbrella".to_string(),
                    winner.get("umbrella").cloned().unwrap_or(Value::Null),
                );
                m.insert(
                    "loser_umbrella".to_string(),
                    loser.get("umbrella").cloned().unwrap_or(Value::Null),
                );
                m.insert(
                    "explanation".to_string(),
                    Value::String(
                        "Equal weighted priority resolved by Charter priority-chain tie-break."
                            .to_string(),
                    ),
                );
                m
            }));
        }
    }

    out
}

fn is_priority_tie(a: &Value, b: &Value) -> bool {
    (value_f64(a.get("priority")) - value_f64(b.get("priority"))).abs() < 0.0005
}

fn apply_top_driver_tie_break_findings(
    findings: &mut Vec<Finding>,
    scorecard: &Value,
    charter_spec: &CharterSpec,
) {
    let top = value_array(scorecard.get("drivers").and_then(|d| d.get("top_backlog")));
    if top.len() < 2 {
        return;
    }

    for idx in 1..top.len() {
        let prev = &top[idx - 1];
        let curr = &top[idx];
        if !is_priority_tie(prev, curr) {
            continue;
        }
        let prev_rank = value_i64(prev.get("umbrella_rank"));
        let curr_rank = value_i64(curr.get("umbrella_rank"));
        if prev_rank <= 0 || curr_rank <= 0 {
            findings.push(Finding::warn(
                "top-driver-umbrella-rank-missing",
                "policy",
                "charter",
                "Top driver tie has missing umbrella rank metadata.",
            ));
            continue;
        }
        if prev_rank > curr_rank {
            let prev_umbrella = value_string(prev.get("umbrella")).unwrap_or_default();
            let curr_umbrella = value_string(curr.get("umbrella")).unwrap_or_default();
            let prev_name = umbrella_name(charter_spec, &prev_umbrella);
            let curr_name = umbrella_name(charter_spec, &curr_umbrella);
            findings.push(Finding::warn(
                "top-driver-umbrella-tie-break-violated",
                "policy",
                "charter",
                &format!(
                    "Top-driver tie-break violated: umbrella '{}' (rank {}) appears before '{}' (rank {}).",
                    prev_name, prev_rank, curr_name, curr_rank
                ),
            ));
        }
    }
}

fn umbrella_name(charter_spec: &CharterSpec, umbrella_id: &str) -> String {
    charter_spec
        .priority_chain
        .iter()
        .find(|p| p.id == umbrella_id)
        .map(|p| p.name.clone())
        .unwrap_or_else(|| umbrella_id.to_string())
}

fn is_assurance_critical(attribute_id: &str) -> bool {
    matches!(
        attribute_id,
        "security"
            | "safety"
            | "reliability"
            | "recoverability"
            | "dependability"
            | "functional_suitability"
    )
}

fn compute_umbrella_rollups(
    charter_spec: &CharterSpec,
    accumulators: &HashMap<String, UmbrellaAccumulator>,
) -> Vec<Value> {
    charter_spec
        .priority_chain
        .iter()
        .map(|umbrella| {
            let acc = accumulators.get(&umbrella.id).cloned().unwrap_or_default();
            let weighted_mean = if acc.weight_total > 0.0 {
                round6(acc.weighted_sum / acc.weight_total)
            } else {
                0.0
            };
            let critical_floor = if umbrella.id == "assurance" {
                Some(round6(acc.critical_floor.unwrap_or(weighted_mean)))
            } else {
                None
            };
            let score = if umbrella.id == "assurance" {
                let floor = critical_floor.unwrap_or(weighted_mean);
                round6((weighted_mean * 0.7) + (floor * 0.3))
            } else {
                weighted_mean
            };

            Value::Object({
                let mut m = Map::new();
                m.insert("id".to_string(), Value::String(umbrella.id.clone()));
                m.insert("name".to_string(), Value::String(umbrella.name.clone()));
                m.insert(
                    "rank".to_string(),
                    Value::Number(Number::from(
                        charter_spec
                            .priority_rank
                            .get(&umbrella.id)
                            .copied()
                            .unwrap_or(i64::MAX),
                    )),
                );
                m.insert("weighted_mean".to_string(), num(weighted_mean));
                m.insert(
                    "critical_floor".to_string(),
                    critical_floor.map(num).unwrap_or(Value::Null),
                );
                m.insert("score".to_string(), num(score));
                m.insert(
                    "score_percent".to_string(),
                    num(round2((score / 5.0) * 100.0)),
                );
                m.insert(
                    "sample_count".to_string(),
                    Value::Number(Number::from(acc.sample_count)),
                );
                m.insert("weight_total".to_string(), num(round3(acc.weight_total)));
                m.insert(
                    "formula".to_string(),
                    Value::String(if umbrella.id == "assurance" {
                        "0.7*weighted_mean + 0.3*critical_floor".to_string()
                    } else {
                        "weighted_mean".to_string()
                    }),
                );
                m
            })
        })
        .collect()
}

fn render_scorecard_md(scorecard: &Value) -> Result<String> {
    let context = as_object(scorecard.get("context"))
        .cloned()
        .unwrap_or_default();
    let meta = as_object(scorecard.get("meta"))
        .cloned()
        .unwrap_or_default();
    let overall = as_object(scorecard.get("overall"))
        .cloned()
        .unwrap_or_default();
    let subsystems = as_object(scorecard.get("subsystems"))
        .cloned()
        .unwrap_or_default();
    let top_drivers = value_array(scorecard.get("drivers").and_then(|d| d.get("top_backlog")));
    let umbrella_rollups = value_array(scorecard.get("umbrellas"));

    let mut lines: Vec<String> = vec![
        "# Assurance Engine Scorecard".to_string(),
        "".to_string(),
        format!(
            "- Generated: `{}`",
            value_string(meta.get("generated_at")).unwrap_or_default()
        ),
        format!(
            "- Run ID: `{}`",
            value_string(meta.get("run_id")).unwrap_or_default()
        ),
        format!(
            "- Profile: `{}`",
            value_string(context.get("profile")).unwrap_or_default()
        ),
        format!(
            "- Run mode: `{}`",
            value_string(context.get("run_mode")).unwrap_or_default()
        ),
        format!(
            "- Maturity: `{}`",
            value_string(context.get("maturity")).unwrap_or_default()
        ),
        format!(
            "- Repo: `{}`",
            value_string(context.get("repo")).unwrap_or_default()
        ),
        "".to_string(),
        "## Overall".to_string(),
        "".to_string(),
        format!(
            "- System score: `{:.2}%`",
            value_f64(overall.get("system_score_percent"))
        ),
        format!(
            "- Baseline present: `{}`",
            scorecard
                .get("context")
                .and_then(|c| c.get("baseline_present"))
                .and_then(|v| v.as_bool())
                .unwrap_or(false)
        ),
        "".to_string(),
        "## Umbrella Rollups".to_string(),
        "".to_string(),
        "| Umbrella | Rank | Score | Weighted Mean | Critical Floor | Samples |".to_string(),
        "|---|---:|---:|---:|---:|---:|".to_string(),
    ];

    if umbrella_rollups.is_empty() {
        lines.push("| `n/a` | 0 | 0 | 0 | 0 | 0 |".to_string());
    } else {
        for item in &umbrella_rollups {
            lines.push(format!(
                "| `{}` | {} | `{:.2}%` | {} | {} | {} |",
                value_string(item.get("name"))
                    .or_else(|| value_string(item.get("id")))
                    .unwrap_or_default(),
                value_i64(item.get("rank")),
                value_f64(item.get("score_percent")),
                value_f64(item.get("weighted_mean")),
                item.get("critical_floor")
                    .and_then(|v| v.as_f64())
                    .map(|v| format!("{v:.3}"))
                    .unwrap_or_else(|| "n/a".to_string()),
                value_i64(item.get("sample_count")),
            ));
        }
    }

    lines.extend(vec![
        "".to_string(),
        "## Subsystem Scores".to_string(),
        "".to_string(),
        "| Subsystem | Score |".to_string(),
        "|---|---:|".to_string(),
    ]);

    for (name, rec) in sorted_object_iter(&subsystems) {
        let pct = value_f64(rec.get("score_percent"));
        lines.push(format!("| `{name}` | `{pct:.2}%` |"));
    }

    lines.push("".to_string());
    lines.push("## Top Backlog Drivers".to_string());
    lines.push("".to_string());
    lines.push(
        "| Subsystem | Attribute | Umbrella | Rank | Weight | Score | Target | Gap | Priority |"
            .to_string(),
    );
    lines.push("|---|---|---|---:|---:|---:|---:|---:|---:|".to_string());

    if top_drivers.is_empty() {
        lines.push("| `n/a` | `n/a` | `n/a` | 0 | 0 | 0 | 0 | 0 | 0 |".to_string());
    } else {
        for driver in top_drivers.iter().take(20) {
            lines.push(format!(
                "| `{}` | `{}` | `{}` | {} | {} | {} | {} | {} | {} |",
                value_string(driver.get("subsystem")).unwrap_or_default(),
                value_string(driver.get("attribute")).unwrap_or_default(),
                value_string(driver.get("umbrella")).unwrap_or_default(),
                value_i64(driver.get("umbrella_rank")),
                value_i64(driver.get("weight")),
                value_f64(driver.get("measured")),
                value_f64(driver.get("target")),
                value_f64(driver.get("gap")),
                value_f64(driver.get("priority")),
            ));
        }
    }

    Ok(lines.join("\n") + "\n")
}

fn render_regressions_md(scorecard: &Value) -> Result<String> {
    let hard = value_array(scorecard.get("regressions").and_then(|r| r.get("hard")));
    let soft = value_array(scorecard.get("regressions").and_then(|r| r.get("soft")));

    let mut lines: Vec<String> = vec![
        "# Assurance Regression Summary".to_string(),
        "".to_string(),
        format!("- Hard regressions: `{}`", hard.len()),
        format!("- Soft regressions: `{}`", soft.len()),
        "".to_string(),
    ];

    append_regression_section(&mut lines, "Hard", &hard);
    append_regression_section(&mut lines, "Soft", &soft);

    Ok(lines.join("\n") + "\n")
}

fn append_regression_section(lines: &mut Vec<String>, title: &str, items: &[Value]) {
    lines.push(format!("## {title}"));
    lines.push("".to_string());

    if items.is_empty() {
        lines.push("None.".to_string());
        lines.push("".to_string());
        return;
    }

    lines.push(
        "| Subsystem | Attribute | Umbrella | Rank | Weight | Delta | Impact | Rule |".to_string(),
    );
    lines.push("|---|---|---|---:|---:|---:|---:|---|".to_string());

    for item in items {
        lines.push(format!(
            "| `{}` | `{}` | `{}` | {} | {} | {} | {} | `{}` |",
            value_string(item.get("subsystem")).unwrap_or_default(),
            value_string(item.get("attribute")).unwrap_or_default(),
            value_string(item.get("umbrella")).unwrap_or_default(),
            value_i64(item.get("umbrella_rank")),
            value_i64(item.get("weight")),
            value_f64(item.get("delta")),
            value_f64(item.get("impact")),
            value_string(item.get("rule")).unwrap_or_default(),
        ));
    }

    lines.push("".to_string());
}

fn render_effective_md(
    profile: &str,
    repo: &str,
    run_mode: &str,
    maturity: &str,
    attribute_ids: &[String],
    attribute_names: &HashMap<String, String>,
    effective_weights: &Map<String, Value>,
    charter_spec: &CharterSpec,
    tie_break_resolutions: &[Value],
) -> String {
    let mut subsystems: Vec<String> = effective_weights.keys().cloned().collect();
    subsystems.sort();

    let mut lines = vec![
        "# Effective Weights".to_string(),
        "".to_string(),
        format!("- Profile: `{profile}`"),
        format!("- Repo: `{repo}`"),
        format!("- Run mode: `{run_mode}`"),
        format!("- Maturity: `{maturity}`"),
        "".to_string(),
        "## Charter Metadata".to_string(),
        "".to_string(),
        format!("- Charter: `{}`", charter_spec.reference_path),
        format!(
            "- Umbrella chain: `{}`",
            charter_spec
                .priority_chain
                .iter()
                .map(|p| p.name.clone())
                .collect::<Vec<_>>()
                .join(" > ")
        ),
        format!("- Tie-break rule: {}", charter_spec.tie_break_rule),
        "".to_string(),
        "## Trade-off Rules".to_string(),
        "".to_string(),
    ];
    for rule in &charter_spec.tradeoff_rules {
        lines.push(format!("- {rule}"));
    }
    lines.extend(vec![
        "".to_string(),
        "## Conflict Resolution".to_string(),
        "".to_string(),
    ]);
    if tie_break_resolutions.is_empty() {
        lines.push(
            "No priority-tie conflicts required charter tie-break resolution in this run."
                .to_string(),
        );
    } else {
        lines.push(
            "Priority ties were resolved using the umbrella chain (higher-ranked umbrellas win)."
                .to_string(),
        );
        lines.push("".to_string());
        lines.push("| Priority | Winner | Loser | Winner Umbrella | Loser Umbrella |".to_string());
        lines.push("|---:|---|---|---|---|".to_string());
        for item in tie_break_resolutions.iter().take(10) {
            lines.push(format!(
                "| {} | `{}` | `{}` | `{}` | `{}` |",
                value_f64(item.get("priority")),
                value_string(item.get("winner")).unwrap_or_default(),
                value_string(item.get("loser")).unwrap_or_default(),
                value_string(item.get("winner_umbrella")).unwrap_or_default(),
                value_string(item.get("loser_umbrella")).unwrap_or_default(),
            ));
        }
    }
    lines.extend(vec![
        "".to_string(),
        "## Matrix".to_string(),
        "".to_string(),
    ]);

    let mut header = String::from("| Attribute | ");
    for (idx, subsystem) in subsystems.iter().enumerate() {
        header.push_str(&format!("`{}`", subsystem));
        if idx + 1 < subsystems.len() {
            header.push_str(" | ");
        }
    }
    header.push_str(" |");
    lines.push(header);

    let mut divider = String::from("|---|");
    for _ in &subsystems {
        divider.push_str("---:|");
    }
    lines.push(divider);

    for attr in attribute_ids {
        let mut row = format!(
            "| `{}` (`{}`) | ",
            attribute_names
                .get(attr)
                .cloned()
                .unwrap_or_else(|| attr.clone()),
            attr
        );
        for (idx, subsystem) in subsystems.iter().enumerate() {
            let value = effective_weights
                .get(subsystem)
                .and_then(|v| v.get(attr))
                .map(|v| value_i64(Some(v)))
                .unwrap_or(-1);
            if value >= 0 {
                row.push_str(&value.to_string());
            } else {
                row.push('-');
            }
            if idx + 1 < subsystems.len() {
                row.push_str(" | ");
            }
        }
        row.push_str(" |");
        lines.push(row);
    }

    lines.join("\n") + "\n"
}

fn render_results_md(scorecard: &Value) -> Result<String> {
    let context = as_object(scorecard.get("context"))
        .cloned()
        .unwrap_or_default();
    let charter = as_object(scorecard.get("charter"))
        .cloned()
        .unwrap_or_default();
    let overall = as_object(scorecard.get("overall"))
        .cloned()
        .unwrap_or_default();
    let subsystems = as_object(scorecard.get("subsystems"))
        .cloned()
        .unwrap_or_default();
    let umbrella_rollups = value_array(scorecard.get("umbrellas"));
    let top = value_array(scorecard.get("drivers").and_then(|d| d.get("top_backlog")));
    let charter_priorities = value_array(charter.get("priority_chain"));
    let tradeoff_rules = value_string_array(charter.get("tradeoff_rules"));
    let tie_breaks = value_array(charter.get("tie_break_resolutions"));

    let mut lines = vec![
        "# Assurance Engine Results".to_string(),
        "".to_string(),
        format!(
            "- Profile: `{}`",
            value_string(context.get("profile")).unwrap_or_default()
        ),
        format!(
            "- Repo: `{}`",
            value_string(context.get("repo")).unwrap_or_default()
        ),
        format!(
            "- Run mode: `{}`",
            value_string(context.get("run_mode")).unwrap_or_default()
        ),
        format!(
            "- Maturity: `{}`",
            value_string(context.get("maturity")).unwrap_or_default()
        ),
        format!(
            "- System score: `{:.2}%`",
            value_f64(overall.get("system_score_percent"))
        ),
        "".to_string(),
        "## Charter Metadata".to_string(),
        "".to_string(),
        format!(
            "- Charter: `{}`",
            value_string(charter.get("reference")).unwrap_or_default()
        ),
        format!(
            "- Version: `{}`",
            value_string(charter.get("version")).unwrap_or_else(|| "n/a".to_string())
        ),
        format!(
            "- Umbrella chain: `{}`",
            if charter_priorities.is_empty() {
                "n/a".to_string()
            } else {
                charter_priorities
                    .iter()
                    .map(|p| {
                        let id = value_string(p.get("id")).unwrap_or_default();
                        let name = value_string(p.get("name")).unwrap_or_default();
                        if name.is_empty() {
                            id
                        } else {
                            format!("{name} ({id})")
                        }
                    })
                    .collect::<Vec<_>>()
                    .join(" > ")
            }
        ),
        format!(
            "- Tie-break rule: {}",
            value_string(charter.get("tie_break_rule")).unwrap_or_default()
        ),
        "".to_string(),
        "## Trade-off Rules".to_string(),
        "".to_string(),
    ];
    for rule in tradeoff_rules {
        lines.push(format!("- {rule}"));
    }
    lines.extend(vec![
        "".to_string(),
        "## Conflict Resolution".to_string(),
        "".to_string(),
    ]);
    if tie_breaks.is_empty() {
        lines.push("No equal-priority conflicts required umbrella tie-breaks.".to_string());
    } else {
        lines.push("Equal-priority conflicts were resolved by umbrella chain order.".to_string());
        lines.push("".to_string());
        lines.push("| Priority | Winner | Loser | Winner Umbrella | Loser Umbrella |".to_string());
        lines.push("|---:|---|---|---|---|".to_string());
        for item in tie_breaks.iter().take(10) {
            lines.push(format!(
                "| {} | `{}` | `{}` | `{}` | `{}` |",
                value_f64(item.get("priority")),
                value_string(item.get("winner")).unwrap_or_default(),
                value_string(item.get("loser")).unwrap_or_default(),
                value_string(item.get("winner_umbrella")).unwrap_or_default(),
                value_string(item.get("loser_umbrella")).unwrap_or_default(),
            ));
        }
    }

    lines.extend(vec![
        "".to_string(),
        "## Umbrella Rollups".to_string(),
        "".to_string(),
        "| Umbrella | Rank | Score | Weighted Mean | Critical Floor | Samples | Formula |"
            .to_string(),
        "|---|---:|---:|---:|---:|---:|---|".to_string(),
    ]);
    if umbrella_rollups.is_empty() {
        lines.push("| `n/a` | 0 | 0 | 0 | 0 | 0 | n/a |".to_string());
    } else {
        for item in umbrella_rollups {
            lines.push(format!(
                "| `{}` | {} | `{:.2}%` | {} | {} | {} | `{}` |",
                value_string(item.get("name"))
                    .or_else(|| value_string(item.get("id")))
                    .unwrap_or_default(),
                value_i64(item.get("rank")),
                value_f64(item.get("score_percent")),
                value_f64(item.get("weighted_mean")),
                item.get("critical_floor")
                    .and_then(|v| v.as_f64())
                    .map(|v| format!("{v:.3}"))
                    .unwrap_or_else(|| "n/a".to_string()),
                value_i64(item.get("sample_count")),
                value_string(item.get("formula")).unwrap_or_default(),
            ));
        }
    }

    lines.extend(vec![
        "".to_string(),
        "## Subsystem Totals".to_string(),
        "".to_string(),
        "| Subsystem | Weighted Score |".to_string(),
        "|---|---:|".to_string(),
    ]);

    for (subsystem, rec) in sorted_object_iter(&subsystems) {
        lines.push(format!(
            "| `{}` | `{:.2}%` |",
            subsystem,
            value_f64(rec.get("score_percent"))
        ));
    }

    lines.push("".to_string());
    lines.push("## Top Drivers".to_string());
    lines.push("".to_string());
    lines.push(
        "Prioritization formula: `effective_weight × max(0, target_score - current_score)`"
            .to_string(),
    );
    lines.push("".to_string());
    lines.push(
        "| Subsystem | Attribute | Umbrella | Rank | Weight | Current | Target | Gap | Priority | Evidence | Suggested Action |"
            .to_string(),
    );
    lines.push("|---|---|---|---:|---:|---:|---:|---:|---:|---|---|".to_string());

    if top.is_empty() {
        lines.push("| `n/a` | `n/a` | `n/a` | 0 | 0 | 0 | 0 | 0 | 0 | none | none |".to_string());
    } else {
        for item in top.iter().take(20) {
            let evidence = value_string_array(item.get("evidence"));
            let evidence_text = if evidence.is_empty() {
                "none".to_string()
            } else {
                evidence.join(", ")
            };

            lines.push(format!(
                "| `{}` | `{}` | `{}` | {} | {} | {} | {} | {} | {} | {} | {} |",
                value_string(item.get("subsystem")).unwrap_or_default(),
                value_string(item.get("attribute")).unwrap_or_default(),
                value_string(item.get("umbrella")).unwrap_or_default(),
                value_i64(item.get("umbrella_rank")),
                value_i64(item.get("weight")),
                value_f64(item.get("measured")),
                value_f64(item.get("target")),
                value_f64(item.get("gap")),
                value_f64(item.get("priority")),
                evidence_text,
                value_string(item.get("suggested_action")).unwrap_or_default(),
            ));
        }
    }

    let hard_count = value_array(scorecard.get("regressions").and_then(|r| r.get("hard"))).len();
    let soft_count = value_array(scorecard.get("regressions").and_then(|r| r.get("soft"))).len();

    lines.push("".to_string());
    lines.push("## Regressions".to_string());
    lines.push("".to_string());
    lines.push(format!("- Hard: `{hard_count}`"));
    lines.push(format!("- Soft: `{soft_count}`"));

    Ok(lines.join("\n") + "\n")
}

fn render_deviations_md(scorecard: &Value) -> Result<String> {
    let context = as_object(scorecard.get("context"))
        .cloned()
        .unwrap_or_default();
    let policy = as_object(scorecard.get("policy_deviations"))
        .cloned()
        .unwrap_or_default();
    let items = value_array(policy.get("items"));

    let mut lines = vec![
        "# Policy Deviations".to_string(),
        "".to_string(),
        format!(
            "- Profile: `{}`",
            value_string(context.get("profile")).unwrap_or_default()
        ),
        format!(
            "- Repo: `{}`",
            value_string(context.get("repo")).unwrap_or_default()
        ),
        format!(
            "- Run mode: `{}`",
            value_string(context.get("run_mode")).unwrap_or_default()
        ),
        format!(
            "- Maturity: `{}`",
            value_string(context.get("maturity")).unwrap_or_default()
        ),
        format!(
            "- Enforcement phase: `{}`",
            value_string(policy.get("enforcement_phase")).unwrap_or_default()
        ),
        format!("- Total deviations: `{}`", value_i64(policy.get("total"))),
        format!("- Permitted: `{}`", value_i64(policy.get("permitted"))),
        "".to_string(),
        "## Deviations".to_string(),
        "".to_string(),
        "| Subsystem | Class | Attribute | Umbrella | Rank | Assurance-First Deviation | Old | New | Declared | Permitted | Expired | ADR | Changelog | Evidence | Issues |".to_string(),
        "|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|".to_string(),
    ];

    if items.is_empty() {
        lines.push("| `n/a` | `n/a` | `n/a` | `n/a` | 0 | false | 0 | 0 | false | true | false | false | false | none | none |".to_string());
        return Ok(lines.join("\n") + "\n");
    }

    for item in items {
        let evidence = value_string_array(item.get("evidence"));
        let issues_hard = value_string_array(item.get("hard_issues"));
        let issues_warn = value_string_array(item.get("warn_issues"));
        let mut issue_texts = Vec::new();
        if !issues_hard.is_empty() {
            issue_texts.push(format!("hard: {}", issues_hard.join(", ")));
        }
        if !issues_warn.is_empty() {
            issue_texts.push(format!("warn: {}", issues_warn.join(", ")));
        }
        let issues = if issue_texts.is_empty() {
            "none".to_string()
        } else {
            issue_texts.join(" | ")
        };

        lines.push(format!(
            "| `{}` | `{}` | `{}` | `{}` | {} | {} | {} | {} | {} | {} | {} | {} | {} | {} | {} |",
            value_string(item.get("subsystem")).unwrap_or_default(),
            value_string(item.get("subsystem_class")).unwrap_or_default(),
            value_string(item.get("attribute")).unwrap_or_default(),
            value_string(item.get("umbrella")).unwrap_or_default(),
            value_i64(item.get("umbrella_rank")),
            item.get("umbrella_priority_deviation")
                .and_then(|v| v.as_bool())
                .unwrap_or(false),
            value_i64(item.get("old_value")),
            value_i64(item.get("new_value")),
            item.get("declared")
                .and_then(|v| v.as_bool())
                .unwrap_or(false),
            item.get("policy_permitted")
                .and_then(|v| v.as_bool())
                .unwrap_or(false),
            item.get("expired")
                .and_then(|v| v.as_bool())
                .unwrap_or(false),
            item.get("adr_present")
                .and_then(|v| v.as_bool())
                .unwrap_or(false),
            item.get("changelog_present")
                .and_then(|v| v.as_bool())
                .unwrap_or(false),
            if evidence.is_empty() {
                "none".to_string()
            } else {
                evidence.join(", ")
            },
            issues,
        ));
    }

    Ok(lines.join("\n") + "\n")
}

fn render_gate_summary(
    status: &str,
    mode: &str,
    maturity: &str,
    findings: &[Finding],
    scorecard: &Value,
    policy_changed: bool,
    charter_changed: bool,
    scores_changed: bool,
) -> Result<String> {
    let profile = scorecard
        .get("context")
        .and_then(|c| c.get("profile"))
        .and_then(|v| v.as_str())
        .unwrap_or("unknown");

    let hard: Vec<&Finding> = findings
        .iter()
        .filter(|f| f.severity == "HARD_FAIL")
        .collect();
    let soft: Vec<&Finding> = findings
        .iter()
        .filter(|f| f.severity == "SOFT_WARN")
        .collect();

    let mut lines = vec![
        "# Assurance Engine Gate Summary".to_string(),
        "".to_string(),
        format!("- Status: `{status}`"),
        format!("- Mode: `{mode}`"),
        format!("- Maturity: `{maturity}`"),
        format!("- Profile: `{profile}`"),
        format!("- Policy changed: `{policy_changed}`"),
        format!("- Charter changed: `{charter_changed}`"),
        format!("- Scores changed: `{scores_changed}`"),
        format!("- Hard findings: `{}`", hard.len()),
        format!("- Warning findings: `{}`", soft.len()),
        "".to_string(),
    ];

    append_finding_section(&mut lines, "Hard Findings", &hard);
    append_finding_section(&mut lines, "Warnings", &soft);

    Ok(lines.join("\n") + "\n")
}

fn append_finding_section(lines: &mut Vec<String>, title: &str, findings: &[&Finding]) {
    lines.push(format!("## {title}"));
    lines.push("".to_string());
    if findings.is_empty() {
        lines.push("None.".to_string());
        lines.push("".to_string());
        return;
    }

    lines.push("| Severity | Code | Subsystem | Attribute | Message |".to_string());
    lines.push("|---|---|---|---|---|".to_string());
    for f in findings {
        lines.push(format!(
            "| `{}` | `{}` | `{}` | `{}` | {} |",
            f.severity, f.code, f.subsystem, f.attribute, f.message
        ));
    }
    lines.push("".to_string());
}

fn regression_rec(
    subsystem: &str,
    attribute: &str,
    umbrella: &str,
    umbrella_rank: i64,
    weight: i64,
    delta: f64,
    impact: f64,
    rule: &str,
) -> Value {
    Value::Object({
        let mut m = Map::new();
        m.insert(
            "subsystem".to_string(),
            Value::String(subsystem.to_string()),
        );
        m.insert(
            "attribute".to_string(),
            Value::String(attribute.to_string()),
        );
        m.insert("umbrella".to_string(), Value::String(umbrella.to_string()));
        m.insert(
            "umbrella_rank".to_string(),
            Value::Number(Number::from(umbrella_rank)),
        );
        m.insert("weight".to_string(), Value::Number(Number::from(weight)));
        m.insert("delta".to_string(), num(round3(delta)));
        m.insert("impact".to_string(), num(round3(impact)));
        m.insert("rule".to_string(), Value::String(rule.to_string()));
        m
    })
}

fn find_changelog_entry<'a>(weights: &'a Value, version: &str) -> Option<&'a Map<String, Value>> {
    let entries = weights.get("changelog")?.as_array()?;
    for entry in entries {
        let obj = entry.as_object()?;
        let v = obj.get("version").and_then(|x| x.as_str()).unwrap_or("");
        if v.trim() == version {
            return Some(obj);
        }
    }
    None
}

fn adr_is_valid(value: Option<&str>) -> bool {
    let Some(raw) = value else {
        return false;
    };
    let text = raw.trim();
    if text.is_empty() {
        return false;
    }
    let lower = text.to_ascii_lowercase();
    !matches!(lower.as_str(), "tbd" | "n/a" | "none")
}

fn normalize_text_key(input: &str) -> String {
    input
        .trim()
        .to_ascii_lowercase()
        .replace('&', "and")
        .replace(['-', '_', '/', '.'], " ")
        .split_whitespace()
        .collect::<Vec<_>>()
        .join(" ")
}

fn normalize_path_key(input: &str) -> String {
    let mut text = input.trim().replace('\\', "/");
    while text.starts_with("./") {
        text = text[2..].to_string();
    }
    text
}

fn paths_equivalent(a: &str, b: &str) -> bool {
    let na = normalize_path_key(a);
    let nb = normalize_path_key(b);
    na == nb || nb.ends_with(&na) || na.ends_with(&nb)
}

fn canonical_hash(value: &Value) -> String {
    sha256_hex(canonical_string(value).as_bytes())
}

fn canonical_string(value: &Value) -> String {
    match value {
        Value::Null => "null".to_string(),
        Value::Bool(b) => b.to_string(),
        Value::Number(n) => n.to_string(),
        Value::String(s) => serde_json::to_string(s).unwrap_or_else(|_| "\"\"".to_string()),
        Value::Array(items) => {
            let mut out = String::from("[");
            for (idx, item) in items.iter().enumerate() {
                if idx > 0 {
                    out.push(',');
                }
                out.push_str(&canonical_string(item));
            }
            out.push(']');
            out
        }
        Value::Object(map) => {
            let mut keys: Vec<&String> = map.keys().collect();
            keys.sort();
            let mut out = String::from("{");
            for (idx, key) in keys.iter().enumerate() {
                if idx > 0 {
                    out.push(',');
                }
                out.push_str(&serde_json::to_string(key).unwrap_or_else(|_| "\"\"".to_string()));
                out.push(':');
                if let Some(v) = map.get(*key) {
                    out.push_str(&canonical_string(v));
                } else {
                    out.push_str("null");
                }
            }
            out.push('}');
            out
        }
    }
}

fn load_yaml_json(path: &Path) -> Result<Value> {
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read file: {}", path.display()))?;
    let yaml_value: serde_yaml::Value =
        serde_yaml::from_str(&text).with_context(|| format!("invalid YAML: {}", path.display()))?;
    let json = serde_json::to_value(yaml_value)
        .with_context(|| format!("failed to convert YAML to JSON value: {}", path.display()))?;
    if !json.is_object() {
        bail!("expected mapping at root of: {}", path.display());
    }
    Ok(json)
}

fn load_text(path: &Path) -> Result<String> {
    fs::read_to_string(path).with_context(|| format!("failed to read file: {}", path.display()))
}

fn load_yaml_json_optional(path: &Path) -> Result<Option<Value>> {
    if !path.exists() {
        return Ok(None);
    }
    Ok(Some(load_yaml_json(path)?))
}

fn write_yaml(path: &Path, value: &Value) -> Result<()> {
    if let Some(parent) = path.parent() {
        ensure_dir(parent)?;
    }
    let text = serde_yaml::to_string(value)
        .with_context(|| format!("failed to serialize YAML: {}", path.display()))?;
    fs::write(path, text).with_context(|| format!("failed to write file: {}", path.display()))
}

fn write_text(path: &Path, text: &str) -> Result<()> {
    if let Some(parent) = path.parent() {
        ensure_dir(parent)?;
    }
    fs::write(path, text).with_context(|| format!("failed to write file: {}", path.display()))
}

fn ensure_dir(path: &Path) -> Result<()> {
    fs::create_dir_all(path)
        .with_context(|| format!("failed to create directory: {}", path.display()))
}

fn source_hash(paths: &[PathBuf]) -> Result<String> {
    let mut hasher = Sha256::new();
    for path in paths {
        hasher.update(path.to_string_lossy().as_bytes());
        hasher.update(b"\n");
        if path.exists() {
            let bytes = fs::read(path)
                .with_context(|| format!("failed to read source hash input: {}", path.display()))?;
            hasher.update(&bytes);
        } else {
            hasher.update(b"<missing>");
        }
        hasher.update(b"\n");
    }
    Ok(hex::encode(hasher.finalize()))
}

fn sha256_hex(bytes: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    hex::encode(hasher.finalize())
}

fn as_object(value: Option<&Value>) -> Option<&Map<String, Value>> {
    value.and_then(|v| v.as_object())
}

fn value_array(value: Option<&Value>) -> Vec<Value> {
    match value {
        Some(Value::Array(arr)) => arr.clone(),
        Some(Value::Null) | None => Vec::new(),
        Some(v) => vec![v.clone()],
    }
}

fn value_string_array(value: Option<&Value>) -> Vec<String> {
    match value {
        Some(Value::Array(arr)) => arr
            .iter()
            .filter_map(|item| match item {
                Value::String(s) => Some(s.trim().to_string()),
                Value::Number(n) => Some(n.to_string()),
                Value::Bool(b) => Some(b.to_string()),
                _ => None,
            })
            .filter(|s| !s.is_empty())
            .collect(),
        Some(Value::String(s)) => {
            let t = s.trim();
            if t.is_empty() {
                Vec::new()
            } else {
                vec![t.to_string()]
            }
        }
        Some(v) => {
            let t = v.to_string();
            if t.trim().is_empty() {
                Vec::new()
            } else {
                vec![t]
            }
        }
        None => Vec::new(),
    }
}

fn value_string(value: Option<&Value>) -> Option<String> {
    match value {
        Some(Value::String(s)) => Some(s.clone()),
        Some(Value::Number(n)) => Some(n.to_string()),
        Some(Value::Bool(b)) => Some(b.to_string()),
        _ => None,
    }
}

fn value_f64(value: Option<&Value>) -> f64 {
    match value {
        Some(Value::Number(n)) => n.as_f64().unwrap_or(0.0),
        Some(Value::String(s)) => s.parse::<f64>().unwrap_or(0.0),
        Some(Value::Bool(true)) => 1.0,
        Some(Value::Bool(false)) => 0.0,
        _ => 0.0,
    }
}

fn value_i64(value: Option<&Value>) -> i64 {
    match value {
        Some(Value::Number(n)) => n
            .as_i64()
            .or_else(|| n.as_u64().map(|v| v as i64))
            .unwrap_or(0),
        Some(Value::String(s)) => s.parse::<i64>().unwrap_or(0),
        Some(Value::Bool(true)) => 1,
        Some(Value::Bool(false)) => 0,
        _ => 0,
    }
}

fn get_string_obj(obj: &Map<String, Value>, key: &str) -> Option<String> {
    value_string(obj.get(key))
}

fn clamp(value: f64, lo: f64, hi: f64) -> f64 {
    value.max(lo).min(hi)
}

fn round2(v: f64) -> f64 {
    (v * 100.0).round() / 100.0
}

fn round3(v: f64) -> f64 {
    (v * 1000.0).round() / 1000.0
}

fn round6(v: f64) -> f64 {
    (v * 1_000_000.0).round() / 1_000_000.0
}

fn num(value: f64) -> Value {
    Value::Number(Number::from_f64(value).unwrap_or_else(|| Number::from(0)))
}

fn opt_num(value: Option<f64>) -> Value {
    value.map(num).unwrap_or(Value::Null)
}

fn opt_string(value: Option<String>) -> Value {
    value.map(Value::String).unwrap_or(Value::Null)
}

fn map_string_i64(input: Option<&Map<String, Value>>) -> HashMap<String, i64> {
    let mut out = HashMap::new();
    if let Some(map) = input {
        for (k, v) in map {
            out.insert(k.clone(), value_i64(Some(v)));
        }
    }
    out
}

fn map_string_map_i64(input: Option<&Map<String, Value>>) -> HashMap<String, HashMap<String, i64>> {
    let mut out = HashMap::new();
    if let Some(map) = input {
        for (scope, attrs) in map {
            if let Some(attr_map) = attrs.as_object() {
                out.insert(scope.clone(), map_string_i64(Some(attr_map)));
            }
        }
    }
    out
}

fn json_obj_from_i64_map(map: &HashMap<String, i64>) -> Value {
    let mut out = Map::new();
    let mut keys: Vec<String> = map.keys().cloned().collect();
    keys.sort();
    for key in keys {
        if let Some(value) = map.get(&key) {
            out.insert(key, Value::Number(Number::from(*value)));
        }
    }
    Value::Object(out)
}

fn sorted_object_iter(map: &Map<String, Value>) -> Vec<(&String, &Value)> {
    let mut pairs: Vec<(&String, &Value)> = map.iter().collect();
    pairs.sort_by(|(a, _), (b, _)| a.cmp(b));
    pairs
}

fn cmp_num(a: Option<&Value>, b: Option<&Value>) -> Ordering {
    value_f64(a)
        .partial_cmp(&value_f64(b))
        .unwrap_or(Ordering::Equal)
}

fn cmp_string(a: Option<&Value>, b: Option<&Value>) -> Ordering {
    value_string(a)
        .unwrap_or_default()
        .cmp(&value_string(b).unwrap_or_default())
}

fn baseline_value(attr: &Value) -> f64 {
    value_f64(attr.get("measured"))
}

fn suggest_action(
    attribute: &str,
    measured: f64,
    target: f64,
    delta: Option<f64>,
    has_criteria: bool,
    has_evidence: bool,
) -> String {
    if !has_criteria {
        return format!("Define acceptance criteria for '{attribute}'.");
    }
    if !has_evidence {
        return format!("Attach evidence pointers for '{attribute}' score claims.");
    }
    if let Some(d) = delta {
        if d < 0.0 {
            return format!("Investigate regression in '{attribute}' and add mitigation plan.");
        }
    }
    if measured < target {
        return format!(
            "Raise '{attribute}' from {} to target {}.",
            round3(measured),
            round3(target)
        );
    }
    format!("Maintain '{attribute}' at current target posture.")
}

fn context_slug(repo: &str, run_mode: &str, maturity: &str, profile: &str) -> String {
    let raw = format!(
        "repo-{}__run-mode-{}__maturity-{}__profile-{}",
        repo, run_mode, maturity, profile
    );
    let mut out = String::new();
    let mut prev_dash = false;

    for ch in raw.chars() {
        let ok = ch.is_ascii_alphanumeric() || matches!(ch, '.' | '_' | '=' | '-');
        let c = if ok { ch.to_ascii_lowercase() } else { '-' };
        if c == '-' {
            if !prev_dash {
                out.push(c);
                prev_dash = true;
            }
        } else {
            out.push(c);
            prev_dash = false;
        }
    }

    out.trim_matches('-').to_string()
}

fn is_non_empty_text(value: Option<&str>) -> bool {
    value.map(|v| !v.trim().is_empty()).unwrap_or(false)
}

fn trim_opt(value: Option<String>) -> Option<String> {
    value
        .map(|v| v.trim().to_string())
        .filter(|v| !v.is_empty())
}

fn trim_vec(values: Vec<String>) -> Vec<String> {
    values
        .into_iter()
        .map(|v| v.trim().to_string())
        .filter(|v| !v.is_empty())
        .collect()
}

struct TimestampMeta {
    iso: String,
    run_id: String,
}

fn chrono_like_now() -> TimestampMeta {
    use std::time::{SystemTime, UNIX_EPOCH};

    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();
    let tm = chrono_like_from_unix(now);
    TimestampMeta {
        iso: format!(
            "{:04}-{:02}-{:02}T{:02}:{:02}:{:02}Z",
            tm.year, tm.month, tm.day, tm.hour, tm.minute, tm.second
        ),
        run_id: format!(
            "{:04}{:02}{:02}T{:02}{:02}{:02}Z",
            tm.year, tm.month, tm.day, tm.hour, tm.minute, tm.second
        ),
    }
}

fn default_out_dir(now: &TimestampMeta) -> PathBuf {
    let day = now.iso.get(0..10).unwrap_or("1970-01-01");
    PathBuf::from(format!(
        ".octon/generated/assurance/scorecards/{}/{}",
        day, now.run_id
    ))
}

struct DateParts {
    year: i32,
    month: u32,
    day: u32,
    hour: u32,
    minute: u32,
    second: u32,
}

// Small UTC converter to avoid adding chrono dependency.
fn chrono_like_from_unix(ts: u64) -> DateParts {
    let second = (ts % 60) as u32;
    let minute = ((ts / 60) % 60) as u32;
    let hour = ((ts / 3600) % 24) as u32;
    let days = (ts / 86_400) as i64;

    let (year, month, day) = civil_from_days(days);

    DateParts {
        year,
        month,
        day,
        hour,
        minute,
        second,
    }
}

fn civil_from_days(days_since_epoch: i64) -> (i32, u32, u32) {
    // Howard Hinnant algorithm; epoch 1970-01-01.
    let z = days_since_epoch + 719468;
    let era = if z >= 0 { z } else { z - 146096 } / 146097;
    let doe = z - era * 146097;
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    let y = yoe + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = mp + if mp < 10 { 3 } else { -9 };
    let year = y + if m <= 2 { 1 } else { 0 };
    (year as i32, m as u32, d as u32)
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;
    use std::fs;
    use std::path::{Path, PathBuf};
    use std::sync::Mutex;
    use std::time::{SystemTime, UNIX_EPOCH};

    static GATE_TEST_CWD_LOCK: Mutex<()> = Mutex::new(());

    fn repo_root() -> PathBuf {
        let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
        manifest_dir
            .parent()
            .and_then(Path::parent)
            .and_then(Path::parent)
            .and_then(Path::parent)
            .and_then(Path::parent)
            .and_then(Path::parent)
            .expect("assurance_tools should be under <repo>/.octon/framework/engine/runtime/crates/")
            .to_path_buf()
    }

    fn temp_dir(prefix: &str) -> PathBuf {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_nanos();
        let path = std::env::temp_dir().join(format!(
            "octon-assurance-tools-{prefix}-{}-{nanos}",
            std::process::id()
        ));
        fs::create_dir_all(&path).expect("failed to create temp dir");
        path
    }

    fn write_yaml_value(path: &Path, value: &Value) {
        let text = serde_yaml::to_string(value).expect("failed to serialize yaml");
        fs::write(path, text).expect("failed to write yaml fixture");
    }

    fn sample_scorecard(
        run_mode: &str,
        maturity: &str,
        criteria: Option<&str>,
        evidence: &[&str],
        delta: Option<f64>,
    ) -> Value {
        json!({
            "context": {
                "profile": "ci-reliability",
                "run_mode": run_mode,
                "maturity": maturity,
                "repo": "audit-test-repo"
            },
            "subsystems": {
                "testsub": {
                    "attributes": {
                        "security": {
                            "weight": 3,
                            "measured": 4.0,
                            "target": 5.0,
                            "umbrella": "assurance",
                            "umbrella_rank": 1,
                            "criteria": criteria,
                            "evidence": evidence,
                            "delta": delta
                        }
                    },
                    "conflicts": []
                }
            }
        })
    }

    fn base_gate_paths() -> (PathBuf, PathBuf, PathBuf, PathBuf, PathBuf) {
        let root = repo_root();
        (
            root.join(".octon/framework/assurance/governance/weights/weights.yml"),
            root.join(".octon/framework/assurance/governance/scores/scores.yml"),
            root.join(".octon/framework/assurance/governance/CHARTER.md"),
            root.join(".octon/framework/assurance/governance/subsystem-classes.yml"),
            root.join(".octon/framework/assurance/governance/overrides.yml"),
        )
    }

    fn run_gate_from_repo_root(args: GateArgs) -> Result<()> {
        let _guard = GATE_TEST_CWD_LOCK
            .lock()
            .map_err(|_| anyhow!("failed to acquire test cwd lock"))?;
        let original = std::env::current_dir()?;
        std::env::set_current_dir(repo_root())?;
        let outcome = run_gate(args);
        std::env::set_current_dir(original)?;
        outcome
    }

    #[test]
    fn parse_charter_spec_requires_attribute_umbrella_map() {
        let weights = json!({
            "charter": {
                "ref": ".octon/framework/assurance/governance/CHARTER.md",
                "version": "2.0.0",
                "priority_chain": [
                    {"id": "assurance", "name": "Assurance"}
                ],
                "tie_break_rule": "When tied, prefer higher umbrella rank.",
                "tradeoff_rules": ["Assurance is non-negotiable."],
                "required_references": {"charter": ".octon/framework/assurance/governance/CHARTER.md"}
            }
        });

        let err = parse_charter_spec(&weights, &["security".to_string()])
            .expect_err("missing map must fail")
            .to_string();
        assert!(err.contains("attribute_umbrella_map"));
    }

    #[test]
    fn parse_charter_spec_requires_full_attribute_coverage() {
        let weights = json!({
            "charter": {
                "ref": ".octon/framework/assurance/governance/CHARTER.md",
                "version": "2.0.0",
                "priority_chain": [
                    {"id": "assurance", "name": "Assurance"},
                    {"id": "productivity", "name": "Productivity"},
                    {"id": "integration", "name": "Integration"}
                ],
                "tie_break_rule": "When tied, prefer higher umbrella rank.",
                "tradeoff_rules": ["Assurance is non-negotiable."],
                "required_references": {"charter": ".octon/framework/assurance/governance/CHARTER.md"},
                "attribute_umbrella_map": {
                    "security": "assurance"
                }
            }
        });

        let attrs = vec!["security".to_string(), "safety".to_string()];
        let err = parse_charter_spec(&weights, &attrs)
            .expect_err("missing mapping for safety must fail")
            .to_string();
        assert!(err.contains("missing mapping for attribute 'safety'"));
    }

    #[test]
    fn compute_umbrella_rollups_uses_assurance_hybrid_formula() {
        let priority_chain = vec![
            CharterPriority {
                id: "assurance".to_string(),
                name: "Assurance".to_string(),
            },
            CharterPriority {
                id: "productivity".to_string(),
                name: "Productivity".to_string(),
            },
            CharterPriority {
                id: "integration".to_string(),
                name: "Integration".to_string(),
            },
        ];
        let mut priority_rank = HashMap::new();
        priority_rank.insert("assurance".to_string(), 1);
        priority_rank.insert("productivity".to_string(), 2);
        priority_rank.insert("integration".to_string(), 3);

        let spec = CharterSpec {
            reference_path: ".octon/framework/assurance/governance/CHARTER.md".to_string(),
            version: Some("2.0.0".to_string()),
            priority_chain,
            tie_break_rule: "When tied, prefer higher umbrella rank.".to_string(),
            tradeoff_rules: vec!["Assurance is non-negotiable.".to_string()],
            required_references: HashMap::new(),
            attribute_umbrella_map: HashMap::new(),
            priority_rank,
        };

        let mut acc = HashMap::new();
        acc.insert(
            "assurance".to_string(),
            UmbrellaAccumulator {
                weighted_sum: 40.0,
                weight_total: 10.0,
                sample_count: 5,
                critical_floor: Some(2.0),
            },
        );
        acc.insert(
            "productivity".to_string(),
            UmbrellaAccumulator {
                weighted_sum: 30.0,
                weight_total: 10.0,
                sample_count: 4,
                critical_floor: None,
            },
        );

        let rollups = compute_umbrella_rollups(&spec, &acc);
        let assurance = rollups
            .iter()
            .find(|r| value_string(r.get("id")).as_deref() == Some("assurance"))
            .expect("assurance rollup missing");
        let productivity = rollups
            .iter()
            .find(|r| value_string(r.get("id")).as_deref() == Some("productivity"))
            .expect("productivity rollup missing");

        let assurance_score = value_f64(assurance.get("score"));
        let productivity_score = value_f64(productivity.get("score"));
        assert!((assurance_score - 3.4).abs() < 0.000_001);
        assert!((productivity_score - 3.0).abs() < 0.000_001);
        assert_eq!(
            value_string(assurance.get("formula")).unwrap_or_default(),
            "0.7*weighted_mean + 0.3*critical_floor"
        );
    }

    #[test]
    fn top_driver_sort_prefers_assurance_when_priority_ties() {
        let mut drivers = vec![
            json!({
                "subsystem": "a",
                "attribute": "deployability",
                "priority": 10.0,
                "umbrella": "productivity",
                "umbrella_rank": 2,
                "weight": 5
            }),
            json!({
                "subsystem": "b",
                "attribute": "security",
                "priority": 10.0,
                "umbrella": "assurance",
                "umbrella_rank": 1,
                "weight": 4
            }),
        ];

        drivers.sort_by(|a, b| {
            cmp_num(b.get("priority"), a.get("priority"))
                .then_with(|| cmp_num(a.get("umbrella_rank"), b.get("umbrella_rank")))
                .then_with(|| cmp_num(b.get("weight"), a.get("weight")))
        });

        assert_eq!(
            value_string(drivers[0].get("umbrella")).unwrap_or_default(),
            "assurance"
        );

        let ties = detect_tie_break_resolutions(&drivers);
        assert_eq!(ties.len(), 1);
        assert_eq!(
            value_string(ties[0].get("winner_umbrella")).unwrap_or_default(),
            "assurance"
        );
        assert_eq!(
            value_string(ties[0].get("loser_umbrella")).unwrap_or_default(),
            "productivity"
        );
    }

    #[test]
    fn gate_assurance_rank_three_warns_in_ci() -> Result<()> {
        let temp = temp_dir("gate-ci");
        let scorecard_path = temp.join("scorecard.yml");
        let summary_path = temp.join("gate-summary.md");
        write_yaml_value(
            &scorecard_path,
            &sample_scorecard("ci", "beta", None, &[], None),
        );

        let (weights, scores, charter, subsystem_classes, overrides) = base_gate_paths();
        let args = GateArgs {
            scorecard: scorecard_path,
            weights: weights.clone(),
            scores: scores.clone(),
            charter: charter.clone(),
            subsystem_classes,
            overrides,
            baseline_weights: Some(weights),
            baseline_scores: Some(scores),
            baseline_charter: Some(charter),
            mode: Some("ci".to_string()),
            summary_out: Some(summary_path.clone()),
            strict_warnings: false,
        };

        run_gate_from_repo_root(args)?;
        let summary = fs::read_to_string(summary_path)?;
        assert!(summary.contains("Status: `WARN`"));
        assert!(summary.contains("missing-criteria-assurance-priority"));
        assert!(summary.contains("missing-evidence-assurance-priority"));

        let _ = fs::remove_dir_all(temp);
        Ok(())
    }

    #[test]
    fn gate_assurance_rank_three_fails_in_release() -> Result<()> {
        let temp = temp_dir("gate-release");
        let scorecard_path = temp.join("scorecard.yml");
        let summary_path = temp.join("gate-summary.md");
        write_yaml_value(
            &scorecard_path,
            &sample_scorecard("release", "prod", None, &[], None),
        );

        let (weights, scores, charter, subsystem_classes, overrides) = base_gate_paths();
        let args = GateArgs {
            scorecard: scorecard_path,
            weights: weights.clone(),
            scores: scores.clone(),
            charter: charter.clone(),
            subsystem_classes,
            overrides,
            baseline_weights: Some(weights),
            baseline_scores: Some(scores),
            baseline_charter: Some(charter),
            mode: Some("release".to_string()),
            summary_out: Some(summary_path.clone()),
            strict_warnings: false,
        };

        let err = run_gate_from_repo_root(args)
            .expect_err("release mode should fail for missing controls");
        assert!(err.to_string().contains("gate failed"));

        let summary = fs::read_to_string(summary_path)?;
        assert!(summary.contains("Status: `FAIL`"));
        assert!(summary.contains("missing-criteria-assurance-priority"));
        assert!(summary.contains("missing-evidence-assurance-priority"));

        let _ = fs::remove_dir_all(temp);
        Ok(())
    }

    #[test]
    fn gate_assurance_rank_three_regression_warns() -> Result<()> {
        let temp = temp_dir("gate-regression");
        let scorecard_path = temp.join("scorecard.yml");
        let summary_path = temp.join("gate-summary.md");
        write_yaml_value(
            &scorecard_path,
            &sample_scorecard(
                "ci",
                "beta",
                Some("Security posture remains bounded and auditable."),
                &["evidence/link.md"],
                Some(-0.6),
            ),
        );

        let (weights, scores, charter, subsystem_classes, overrides) = base_gate_paths();
        let args = GateArgs {
            scorecard: scorecard_path,
            weights: weights.clone(),
            scores: scores.clone(),
            charter: charter.clone(),
            subsystem_classes,
            overrides,
            baseline_weights: Some(weights),
            baseline_scores: Some(scores),
            baseline_charter: Some(charter),
            mode: Some("ci".to_string()),
            summary_out: Some(summary_path.clone()),
            strict_warnings: false,
        };

        run_gate_from_repo_root(args)?;
        let summary = fs::read_to_string(summary_path)?;
        assert!(summary.contains("Status: `WARN`"));
        assert!(summary.contains("regression-assurance-priority-w3"));

        let _ = fs::remove_dir_all(temp);
        Ok(())
    }
}
