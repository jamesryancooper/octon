from __future__ import annotations

import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Dict, Iterable, List, Sequence

import yaml
from langgraph.graph import END, StateGraph

from .state import (
    CollectedTerm,
    GlossaryEntry,
    GlossaryGraphState,
    GlossaryReport,
    GlossaryStats,
)


def _iter_markdown_files(root_path: Path, docs_path: str) -> Iterable[Path]:
    docs_root = root_path / docs_path
    if not docs_root.exists():
        return []
    return (path for path in sorted(docs_root.rglob("*.md")) if path.is_file())


def _normalize_term(value: str) -> str:
    normalized = re.sub(r"\s+", " ", value.strip())
    return normalized.lower()


def _extract_terms(content: str, min_term_length: int) -> List[str]:
    terms: List[str] = []
    heading_pattern = re.compile(r"^(#{1,2})\s+(.+)$", re.MULTILINE)
    bold_pattern = re.compile(r"\*\*([^*]+)\*\*")
    definition_pattern = re.compile(r"^([A-Z][\w\s\-/]{%d,})\s*[:–-]\s+.+$" % min_term_length, re.MULTILINE)

    for match in heading_pattern.finditer(content):
        terms.append(match.group(2).strip())
    for match in bold_pattern.finditer(content):
        terms.append(match.group(1).strip())
    for match in definition_pattern.finditer(content):
        terms.append(match.group(1).strip())

    filtered: List[str] = []
    for term in terms:
        clean = term.strip()
        if len(clean) < min_term_length:
            continue
        # Drop generic filler words
        if clean.lower() in {"overview", "introduction", "summary"}:
            continue
        filtered.append(clean)
    return filtered


def collect_terms_node(state: GlossaryGraphState) -> GlossaryGraphState:
    repo_root = Path(state.get("workspace_root", ".")).resolve()
    docs_path = state.get("docs_path", "docs/harmony")
    min_term_length = state.get("min_term_length", 4)

    counter: Counter[str] = Counter()
    sources: Dict[str, set[str]] = defaultdict(set)
    representative_term: Dict[str, str] = {}
    files_scanned = 0

    for md_file in _iter_markdown_files(repo_root, docs_path):
        try:
            content = md_file.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        relative_path = str(md_file.relative_to(repo_root))
        terms = _extract_terms(content, min_term_length)
        if not terms:
            continue
        files_scanned += 1
        file_terms = set()
        for term in terms:
            normalized = _normalize_term(term)
            if not normalized:
                continue
            counter[normalized] += 1
            representative_term.setdefault(normalized, term)
            if normalized not in file_terms:
                sources[normalized].add(relative_path)
                file_terms.add(normalized)

    collected_terms = [
        CollectedTerm(
            term=representative_term[norm],
            normalized_term=norm,
            occurrences=counter[norm],
            source_files=sorted(sources[norm])[:5],
        )
        for norm in counter
    ]

    collected_terms.sort(
        key=lambda entry: (-entry.occurrences, entry.term.lower())
    )

    return {
        "files_scanned": files_scanned,
        "collected_terms": collected_terms,
    }


def _build_description(entry: CollectedTerm) -> str:
    files_preview = ", ".join(entry.source_files[:3]) if entry.source_files else "docs/harmony"
    return (
        f"{entry.term} appears {entry.occurrences} times across {len(entry.source_files)} "
        f"files (for example, {files_preview})."
    )


def summarize_glossary_node(state: GlossaryGraphState) -> GlossaryGraphState:
    collected_terms: Sequence[CollectedTerm] = state.get("collected_terms", []) or []
    max_terms = state.get("max_terms", 25)
    files_scanned = state.get("files_scanned", 0)
    run_id = state.get("run_id", "")
    docs_path = state.get("docs_path", "docs/harmony")
    flow_name = state.get("flow_name", "docs_glossary")

    top_terms = list(collected_terms[:max_terms])
    entries: List[GlossaryEntry] = [
        GlossaryEntry(
            term=entry.term,
            description=_build_description(entry),
            occurrences=entry.occurrences,
            source_files=entry.source_files,
        )
        for entry in top_terms
    ]

    total_occurrences = sum(term.occurrences for term in collected_terms)
    stats = GlossaryStats(
        files_scanned=files_scanned,
        unique_terms=len(collected_terms),
        total_occurrences=total_occurrences,
    )

    summary = (
        f"Scanned {files_scanned} files under {docs_path}. "
        f"Discovered {stats.unique_terms} unique terms; "
        f"returning top {len(entries)} entries (max {max_terms})."
    )
    notes: List[str] = []
    if files_scanned == 0:
        notes.append("No Markdown files found under the configured docs_path.")
    elif len(entries) < max_terms:
        notes.append("Term corpus is small; consider widening docs_path or lowering min_term_length.")

    report = GlossaryReport(
        run_id=run_id,
        flow_name=flow_name,
        docs_path=docs_path,
        max_terms=max_terms,
        stats=stats,
        entries=entries,
        summary=summary,
        notes=notes,
    )

    return {"glossary_report": report}


NODE_BY_ACTION = {
    "collect_terms": collect_terms_node,
    "summarize_glossary": summarize_glossary_node,
}


def build_glossary_graph(
    repo_root: str | Path,
    workflow_manifest: str | Path,
    entrypoint: str | None = None,
):
    root_path = Path(repo_root)
    manifest_path = Path(workflow_manifest)
    if not manifest_path.is_absolute():
        manifest_path = root_path / manifest_path
    if not manifest_path.exists():
        raise ValueError(f"Workflow manifest not found at {manifest_path}")

    manifest = yaml.safe_load(manifest_path.read_text()) or {}
    steps = manifest.get("steps", [])
    if not steps:
        raise ValueError("Workflow manifest has no steps defined")

    steps_sorted = sorted(
        steps, key=lambda step: step.get("meta", {}).get("step_index", 0)
    )
    graph_builder = StateGraph(GlossaryGraphState)

    node_ids: List[str] = []
    for step in steps_sorted:
        action = step.get("meta", {}).get("action")
        node_fn = NODE_BY_ACTION.get(action)
        if node_fn is None:
            raise ValueError(f"No node registered for action '{action}'")
        node_id = step["id"]
        graph_builder.add_node(node_id, node_fn)
        node_ids.append(node_id)

    entry_id = steps_sorted[0]["id"]
    if entrypoint:
        if entrypoint not in node_ids:
            raise ValueError(f"Entrypoint '{entrypoint}' not declared in manifest")
        entry_id = entrypoint

    outgoing_edges: Dict[str, set[str]] = {node_id: set() for node_id in node_ids}

    def _record_edge(source: str, target: str) -> None:
        if source not in outgoing_edges:
            raise ValueError(f"Workflow manifest references unknown node '{source}'")
        graph_builder.add_edge(source, target)
        outgoing_edges[source].add(target)

    for index, step in enumerate(steps_sorted):
        node_id = step["id"]
        depends_on = step.get("depends_on", [])
        if depends_on:
            for dep in depends_on:
                _record_edge(dep, node_id)
        elif index > 0:
            prev_id = steps_sorted[index - 1]["id"]
            _record_edge(prev_id, node_id)

    graph_builder.set_entry_point(entry_id)

    terminal_nodes = [
        node_id for node_id, targets in outgoing_edges.items() if not targets
    ]
    if not terminal_nodes:
        raise ValueError("Workflow manifest did not produce any terminal nodes")

    for terminal in terminal_nodes:
        graph_builder.add_edge(terminal, END)

    return graph_builder.compile()


