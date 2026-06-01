# Target Architecture

Workflow leaf execution creates a unique canonical workflow run id for each new
dispatch attempt. Resume of an existing workflow run is a separate path that
requires same-input, same-authority, same-target, and replay-safe evidence.
