"""Alembic migration template with explicit enums and constraints.

Pattern: Define enums at module level, create with checkfirst=True in
upgrade(), drop with checkfirst=True in downgrade(). Use explicit
constraints, indexes, and server defaults.

Replace the example table and columns with your actual schema.
"""

"""Create initial metadata tables.

Revision ID: {{REVISION_ID}}
Revises:
Create Date: {{CREATE_DATE}}
"""

from __future__ import annotations

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "{{REVISION_ID}}"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

# --- Define enums at module level ---

resource_status = sa.Enum(
    "accepted", "queued", "running", "succeeded", "failed", "canceled",
    name="resource_status",
)

resource_stage = sa.Enum(
    "intake", "processing", "publishing",
    name="resource_stage",
)


def upgrade() -> None:
    # Create enums first
    resource_status.create(op.get_bind(), checkfirst=True)
    resource_stage.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "resources",
        sa.Column("id", sa.BigInteger, primary_key=True, autoincrement=True),
        sa.Column("resource_id", sa.String(64), nullable=False, unique=True),
        sa.Column("tenant_id", sa.String(128), nullable=False),
        sa.Column("status", resource_status, nullable=False, server_default="accepted"),
        sa.Column("stage", resource_stage, nullable=False, server_default="intake"),
        sa.Column(
            "progress",
            sa.Float,
            nullable=False,
            server_default="0",
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("error_code", sa.String(128), nullable=True),
        sa.Column("error_message", sa.Text, nullable=True),
        sa.Column("metadata_json", sa.JSON, nullable=True),
        sa.CheckConstraint("progress >= 0 AND progress <= 1", name="ck_resources_progress_range"),
    )

    # Indexes for operational query patterns
    op.create_index(
        "ix_resources_tenant_created_at",
        "resources",
        ["tenant_id", "created_at"],
    )
    op.create_index(
        "ix_resources_status_stage_updated_at",
        "resources",
        ["status", "stage", "updated_at"],
    )
    op.create_index(
        "ix_resources_completed_at",
        "resources",
        ["completed_at"],
    )


def downgrade() -> None:
    op.drop_table("resources")
    resource_stage.drop(op.get_bind(), checkfirst=True)
    resource_status.drop(op.get_bind(), checkfirst=True)
