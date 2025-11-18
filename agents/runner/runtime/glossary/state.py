from __future__ import annotations

from typing import Dict, List, Optional

from typing_extensions import TypedDict

from pydantic import BaseModel, Field


class CollectedTerm(BaseModel):
    """Intermediate representation for a discovered glossary term."""

    term: str
    normalized_term: str
    occurrences: int = 0
    source_files: List[str] = Field(default_factory=list)


class GlossaryEntry(BaseModel):
    """Final glossary entry surfaced to FlowKit."""

    term: str
    description: str
    occurrences: int
    source_files: List[str] = Field(default_factory=list)


class GlossaryStats(BaseModel):
    files_scanned: int = 0
    unique_terms: int = 0
    total_occurrences: int = 0


class GlossaryReport(BaseModel):
    run_id: str
    flow_name: str
    docs_path: str
    max_terms: int
    stats: GlossaryStats
    entries: List[GlossaryEntry] = Field(default_factory=list)
    summary: str
    notes: List[str] = Field(default_factory=list)


class GlossaryState(BaseModel):
    """Persisted state returned to FlowKit clients for the docs glossary flow."""

    run_id: str
    flow_name: str
    workspace_root: str
    docs_path: str
    max_terms: int
    min_term_length: int = 4

    files_scanned: int = 0
    collected_terms: List[CollectedTerm] = Field(default_factory=list)
    glossary_report: Optional[GlossaryReport] = None


class GlossaryGraphState(TypedDict, total=False):
    """LangGraph-friendly dictionary representation with optional fields."""

    run_id: str
    flow_name: str
    workspace_root: str
    docs_path: str
    max_terms: int
    min_term_length: int
    files_scanned: int
    collected_terms: List[CollectedTerm]
    glossary_report: GlossaryReport


