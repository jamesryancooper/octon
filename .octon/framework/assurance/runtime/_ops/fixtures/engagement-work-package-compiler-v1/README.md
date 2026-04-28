# Engagement Work Package Compiler Fixtures

Fixture set for `validate-engagement-work-package-compiler.sh`.

By default the runtime test generates this compact fixture in a temp directory
from the live promoted contracts and policies, then mutates individual facts for
negative controls. A static `valid/` fixture can be supplied for regression
debugging by setting `OCTON_USE_STATIC_ENGAGEMENT_FIXTURE=1`.
